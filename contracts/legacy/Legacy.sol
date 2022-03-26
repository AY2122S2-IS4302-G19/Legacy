// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./WillStorage.sol";

contract Legacy {
    WillStorage willStorage;

    constructor (WillStorage _willStorage) public {
        willStorage = _willStorage;
    }

    function createWill(
        address[] memory trustees,
        address custodian,
        uint256 custodianAccess,
        bool trusteeTrigger,
        bool ownWallet,
        bool ownLegacyToken,
        bool convertLegacyPOW,
        uint256 inactivityDays,
        address[] memory beneficiariesAddress,
        uint256[] memory amount
    ) public returns (uint256) {
        return willStorage.addWill(
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
    }

    function executeWill(address willWriter) private view {
        require(willStorage.hasWill(willWriter), "User does not exist");
        if (willStorage.isTrusteeTrigger(willWriter)) {
            executeTrusteeWill(willWriter);
        } else {
            executeInactivityWill(willWriter);
        }

        // something here if it messes up
    }

    function executeTrusteeWill(address willWriter) private view {
        //view parameter to be deleted.
        require(willStorage.hasWill(willWriter), "User does not exist");
        require(willStorage.isAuthorized(willWriter, msg.sender));
        //pass
    }

    function executeInactivityWill(address willWriter) private view {
        //view parameter to be deleted.
        // TODO
        // require to be executed only by smart contract
        // require to inactivity days to be >= num of inactivity days set at point of deploying smart contract
        // Need to transfer asset from user wallet to designated address
    }
}
