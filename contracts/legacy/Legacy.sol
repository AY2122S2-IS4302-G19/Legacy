// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
// pragma experimental ABIEncoderV2; //Need to be included for Will struct to be used as parameter inside functions

import "./TrusteeSelection.sol";

contract Legacy {
    // enum triggerType{ INACTIVITY, CUSTODIAN, TRUSTEE }
    uint256 numWills;

    TrusteeSelection trusteeSelection;
    address _owner = msg.sender;
    address[] userList;
    mapping(address => Will) users;

    
    struct Will {
        uint id;
        address owner;
        address trusteeAdd;
        bool initalized; //false by default, helps to check if will exist
        bool trustee;
        bool inactivity;
        bool ownWallet; // whether the user wants to store $$ in their own wallet or into legacy platform 
        bool ownLegacyToken; // whether the user wants to convert to legacy token at the point of adding user 
        bool convertLegacyPOW; // whether the user wants to covert to legacy token at the point of executing the will
        uint inactivityDays; // how many days does the wallet needs to be without activity before triggering the will.
        mapping(address => uint256) beneficiaries;
    }

    

    constructor(TrusteeSelection trusteeSelection) public {
        trusteeSelection = trusteeSelection;
    }


    modifier validUser(address user) {
        require(users[user].initalized);
        _;
    }

    function addUser(address trusteeAdd, bool trusteeOption, bool inactivityOption,
     bool ownWallet, bool ownLegacyToken,bool convertLegacyPOW, uint256 inactivityDays,
     address[] memory beneficiaries_address, uint256[] memory amount)  public {
        require(users[msg.sender].initalized == false, "Already has a will with Legacy, use update will function instead");
        numWills++;
        Will storage user_will = users[msg.sender];
        user_will.id = numWills;
        user_will.owner = msg.sender;
        user_will.initalized = true;
        user_will.trustee = trusteeOption;
        user_will.trusteeAdd = trusteeAdd; 
        user_will.inactivity = inactivityOption;
        user_will.ownWallet = ownWallet;
        user_will.ownLegacyToken = ownLegacyToken;
        user_will.convertLegacyPOW = convertLegacyPOW;
        user_will.inactivityDays = inactivityDays;
        addBeneficiares(beneficiaries_address, amount);

        if(user_will.ownWallet){
            // Seek approval to transfer his asset 
        }
        if(user_will.ownLegacyToken){
            // to convert $$ into Legacy token
        }
        if(user_will.trustee){
            require(trusteeAdd != address(0), "Cannot have empty trustee address, when trustee option is selected");
        }
    }


    function addBeneficiares(address[] memory beneficiaries_address, uint256[] memory amount) public returns (bool) {
        Will storage user_will = users[msg.sender];
        numWills++;
        for(uint i = 0; amount.length < i; i++) {
            address bene = beneficiaries_address[i];
            uint256 amt = amount[i];
            user_will.beneficiaries[bene] = amt;
        }
        return true;
    }


    function executeWill(address userAddress) private view {
        require(users[userAddress].owner != address(0), "User does not exist");
        Will storage will = users[userAddress];
        if(will.trustee) {
            executeTrusteeWill(userAddress);
        }else if (will.inactivity){
            executeInactivityWill(userAddress);
        }else{
            executeCustodianWill(userAddress);
        }
    }

    function executeTrusteeWill(address userAddress) private view { //view parameter to be deleted. 
        require(users[userAddress].owner != address(0), "User does not exist");
        require(users[userAddress].trusteeAdd == msg.sender);
        //pass
    }

    function executeInactivityWill(address userAddress) private view {  //view parameter to be deleted.
        // TODO
        // require to be executed only by smart contract
        // require to inactivity days to be >= num of inactivity days set at point of deploying smart contract
        // Need to transfer asset from user wallet to designated address
    }

    function executeCustodianWill(address userAddress) private view {  //view parameter to be deleted.
        // TODO
        // require to be executed only by smart contract
        // require to inactivity days to be >= num of inactivity days set at point of deploying smart contract
        // Legacy platform holds the asset
    }

}