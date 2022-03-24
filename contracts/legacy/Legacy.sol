// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
// pragma experimental ABIEncoderV2; //Need to be included for Will struct to be used as parameter inside functions

import "./TrusteeSelection.sol";

contract Legacy {
    uint256 numWill;
    TrusteeSelection trusteeSelection;
    mapping(address => will) users;

    struct will {
        uint256 id;
        address trusteeAddress;
        bool trusteeTrigger; // true = trustee, false = inactivity
        bool ownWallet; // whether the user wants to store $$ in their own wallet or into legacy platform
        bool ownLegacyToken; // whether the user wants to convert to legacy token at the point of adding user
        bool convertLegacyPOW; // whether the user wants to covert to legacy token at the point of executing the will
        uint256 inactivityDays; // how many days does the wallet needs to be without activity before triggering the will.
        mapping(address => uint256) beneficiaries;
    }

    event add_will(uint256 id);

    function addWill(
        address trusteeAddress,
        bool trusteeTrigger,
        bool ownWallet,
        bool ownLegacyToken,
        bool convertLegacyPOW,
        uint256 inactivityDays,
        address[] memory beneficiariesAddress,
        uint256[] memory amount
    ) public returns (uint256) {
        require(
            users[msg.sender].id == 0,
            "Already has a will with Legacy, use update will function instead"
        );
        trusteeTrigger
            ? require(
                trusteeAddress != address(0),
                "Cannot have empty trustee address when trustee option is selected"
            )
            : require(
                inactivityDays >= 365,
                "Please set inactivity days to be at least 365 days"
            );
        require(
            beneficiariesAddress.length != 0 &&
                beneficiariesAddress.length == amount.length,
            "Please check beneficiaries and amount information"
        );

        will storage userWill = users[msg.sender];
        userWill.id = numWill++;
        userWill.trusteeAddress = trusteeAddress;
        userWill.trusteeTrigger = trusteeTrigger;
        userWill.ownWallet = ownWallet;
        userWill.ownLegacyToken = ownLegacyToken;
        userWill.convertLegacyPOW = convertLegacyPOW;
        userWill.inactivityDays = inactivityDays;
        addBeneficiares(beneficiariesAddress, amount);

        if (userWill.ownWallet) {
            // Seek approval to transfer his asset
        }
        if (userWill.ownLegacyToken) {
            // to convert $$ into Legacy token
        }

        emit add_will(numWill);
        return numWill;
    }

    function addBeneficiares(
        address[] memory beneficiariesAddress,
        uint256[] memory amount
    ) private {
        will storage userWill = users[msg.sender];
        for (uint256 i = 0; i < amount.length; i++) {
            userWill.beneficiaries[beneficiariesAddress[i]] = amount[i];
        }
    }

    function executeWill(address userAddress) private view {
        require(users[userAddress].id != 0, "User does not exist");
        will storage userWill = users[userAddress];
        if (userWill.trusteeTrigger) {
            executeTrusteeWill(userAddress);
        } else {
            executeInactivityWill(userAddress);
        }
    }

    function executeTrusteeWill(address userAddress) private view {
        //view parameter to be deleted.
        require(users[userAddress].id != 0, "User does not exist");
        require(users[userAddress].trusteeAddress == msg.sender);
        //pass
    }

    function executeInactivityWill(address userAddress) private view {
        //view parameter to be deleted.
        // TODO
        // require to be executed only by smart contract
        // require to inactivity days to be >= num of inactivity days set at point of deploying smart contract
        // Need to transfer asset from user wallet to designated address
    }

    /* function executeCustodianWill(address userAddress) private view {
        //view parameter to be deleted.
        // TODO
        // require to be executed only by smart contract
        // require to inactivity days to be >= num of inactivity days set at point of deploying smart contract
        // Legacy platform holds the asset
    } */
}
