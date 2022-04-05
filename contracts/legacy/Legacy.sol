// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./WillStorage.sol";
import "./apis/DeathOracle.sol";
import "./apis/TransactionOracle.sol";

contract Legacy {
    WillStorage willStorage;
    uint256 totalBalances;
    DeathOracle deathOracle;
    TransactionOracle transactionOracle;

    constructor(
        WillStorage ws,
        DeathOracle doracle,
        TransactionOracle toracle
    ) public {
        willStorage = ws;
        deathOracle = doracle;
    }

    event addingWill();
    event updatingWill();
    event deletingWill();
    event updatingBeneficiaries();
    event executingTrusteeWill(address willWriter);
    event submittedDeathCert(address deceased);

    modifier hasWill(address add) {
        require(willStorage.hasWill(add), "Please create a Will first");
        _;
    }

    function createWill(
        address[] memory trustees,
        address custodian,
        uint256 custodianAccess,
        bool trusteeTrigger,
        bool ownWallet,
        bool ownLegacyToken,
        bool convertLegacyPOW,
        uint16 inactivityDays,
        address[] memory beneficiariesAddress,
        uint256[] memory weights
    ) public payable {
        require((ownWallet == false) && (msg.value > 0), "No ether received when legacy platform as custodian is chosen");
        willStorage.addWill(
            msg.sender,
            msg.value,
            trustees,
            custodian,
            custodianAccess,
            trusteeTrigger,
            ownWallet,
            ownLegacyToken,
            convertLegacyPOW,
            inactivityDays,
            beneficiariesAddress,
            weights
        );
        totalBalances += msg.value;
        emit addingWill();
    }
    
    function getBalances() public view returns(uint256){
        return address(this).balance;
    }

    function updateBeneficiaries(address[] memory beneficiariesAddress,uint256[] memory weights) public {
        willStorage.updateBeneficiares(msg.sender, beneficiariesAddress, weights);
        emit updatingBeneficiaries();
    }


    function updateWill(
        address[] memory trustees,
        address custodian,
        uint8 custodianAccess,
        bool trusteeTrigger,
        bool ownWallet,
        bool ownLegacyToken,
        bool convertLegacyPOW,
        uint16 inactivityDays,
        address[] memory beneficiariesAddress,
        uint256[] memory amount
    ) public {
        willStorage.updateWill(
            msg.sender,
            trustees,
            custodian,
            custodianAccess,
            trusteeTrigger,
            ownWallet,
            ownLegacyToken,
            convertLegacyPOW,
            inactivityDays,
            beneficiariesAddress,
            amount
        );
        emit updatingWill();
    }

    function deleteWill() public{
        willStorage.removeWill(msg.sender);
        emit deletingWill();
    }

    function executeWill(address willWriter) private view hasWill(willWriter) {
        if (willStorage.isTrusteeTrigger(willWriter)) {
            require(
                willStorage.isAuthorized(willWriter, msg.sender),
                "You are not authorized to execute the trustee will"
            );
            require(
                deathOracle.isDead(willWriter),
                "User does not have a verified death certificate"
            );
        }

        // Perform the transferring of assets here
    }

    function submitDeathCertificate(address willWriter, string memory url)
        public
        hasWill(willWriter)
    {
        deathOracle.submit(willWriter, url);
        emit submittedDeathCert(willWriter);
    }

    // just throw this method into the most used function and
    // that's how inactivity wills will get triggered
    function triggerInactivityWills() private view {
        for (uint256 i = 1; i <= willStorage.getNumWill(); i++) {
            address add = willStorage.getAddressById(i);
            if (!willStorage.isTrusteeTrigger(add)) {
                if (
                    block.timestamp - willStorage.getInactivityDays(add) >
                    transactionOracle.getLatestTransactionTimestamp(add)
                ) {
                    executeWill(add);
                }
            }
        }
    }
}
