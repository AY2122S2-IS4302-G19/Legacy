// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./WillStorage.sol";
import "./apis/DeathOracle.sol";
import "./apis/TransactionOracle.sol";

contract Legacy {
    WillStorage willStorage;
    DeathOracle deathOracle;
    TransactionOracle transactionOracle;

    constructor(
        WillStorage ws,
        DeathOracle doracle,
        TransactionOracle toracle
    ) public {
        willStorage = ws;
        deathOracle = doracle;
        transactionOracle = toracle;
    }

    event addingWill();
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
        uint256[] memory amount
    ) public {
        willStorage.addWill(
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
        emit addingWill();
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
