// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./WillStorage.sol";

contract Legacy {
    WillStorage willStorage;
    uint256 totalBalances;

    constructor(WillStorage ws) public {
        willStorage = ws;
    }

    event addingWill();
    event updatingWill();
    event deletingWill();
    event updatingBeneficiaries();

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
