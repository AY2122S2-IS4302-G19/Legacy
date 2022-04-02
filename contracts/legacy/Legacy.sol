// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./WillStorage.sol";
import "./apis/DeathOracle.sol";

contract Legacy {
    WillStorage willStorage;
    DeathOracle deathOracle;

    constructor(WillStorage ws, DeathOracle doracle) public {
        willStorage = ws;
        deathOracle = doracle;
    }

    event addingWill();
    event executingTrusteeWill(address willWriter);
    event submittedDeathCert(address deceased);

    function createWill(
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

    function executeWill(address willWriter) private view {
        require(willStorage.hasWill(willWriter), "User does not have will");
        if (willStorage.isTrusteeTrigger(willWriter)) {
            executeTrusteeWill(willWriter);
        } else {
            executeInactivityWill(willWriter);
        }

        // something here if it messes up
    }

    function submitDeathCertificate(address willWriter, string memory url) public {
        require(willStorage.hasWill(willWriter), "User does not have will");
        deathOracle.submit(willWriter, url);
        emit submittedDeathCert(willWriter);
    }

    function executeTrusteeWill(address willWriter) private view {
        //view parameter to be deleted.
        require(willStorage.hasWill(willWriter), "User does not have will");
        require(willStorage.isAuthorized(willWriter, msg.sender), "You are not authorized to execute the trustee will");
        require(deathOracle.isDead(willWriter), "User does not have a verified death certificate");
        //pass
    }

    function executeInactivityWill(address willWriter) private view {
        require(willStorage.hasWill(willWriter), "User does not have will");
        require(deathOracle.isDead(willWriter), "User does not have a verified death certificate");
        //view parameter to be deleted.
        // TODO
        // require to be executed only by smart contract
        // require to inactivity days to be >= num of inactivity days set at point of deploying smart contract
        // Need to transfer asset from user wallet to designated address
    }
}
