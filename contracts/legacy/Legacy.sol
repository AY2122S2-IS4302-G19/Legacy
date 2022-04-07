// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "./WillStorage.sol";
import "./apis/DeathOracle.sol";
import "./apis/TransactionOracle.sol";
import "../legacytoken/LegacyToken.sol";

import "../legacytoken/ERC20.sol";

contract Legacy {
    WillStorage willStorage;
    LegacyToken lt;
    uint256 totalBalances;
    DeathOracle deathOracle;
    TransactionOracle transactionOracle;
    

    constructor(
        LegacyToken legacyt,
        WillStorage ws,
        DeathOracle doracle,
        TransactionOracle toracle
    ) public {
        lt = legacyt;
        willStorage = ws;
        deathOracle = doracle;
    }

    event addingWill();
    event updatingWill();
    event deletingWill();
    event updatingBeneficiaries();
    event executingTrusteeWill(address willWriter);
    event submittedDeathCert(address deceased);
    event balance(uint256 bal);

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
        if (ownLegacyToken){
            (bool success, ) = payable(address(this)).call{value:msg.value}(
                abi.encodeWithSignature("getToken(address)", msg.sender)
            );
            require(success,"Fail to get token");
        }
        if (ownWallet) {
            // Seek approval to transfer his asset
        }
        totalBalances += msg.value;
        emit addingWill();
    }

    function getToken(address willWriter) public payable {
        require(msg.value >0,'No ether received');
        (bool success, ) = payable(address(lt)).call{value:msg.value}(
            abi.encodeWithSignature("getLegacyToken(address)", willWriter)
        );
        require(success,'token mint failed');
    }

    function checkCredit() public returns(uint256) {
        uint256 bal = lt.checkLTCredit(msg.sender);
        emit balance(bal);
        return bal;
    }

    function getLegacyTokendeposited(address add) public returns(uint256){
        uint256 bal = lt.checkDepositedBal(add);
        emit balance(bal);
        return bal;
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
