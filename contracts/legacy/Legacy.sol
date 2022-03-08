// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
// pragma experimental ABIEncoderV2; //Need to be included for Will struct to be used as parameter inside functions

import "./TrusteeSelection.sol";

contract Legacy {
    // enum triggerType{ INACTIVITY, CUSTODIAN }
    uint256 numWills;

    TrusteeSelection trusteeSelection;
    address _owner = msg.sender;
    address[] userList;
    mapping(address => Will) users;

    
    struct Will {
        uint id;
        address owner;
        address trustee;
        bool initalized; //false by default, helps to check if will exist
        string triggerType;
        mapping(address => uint256) beneficiaries;
    }

    

    constructor(TrusteeSelection trusteeSelection) public {
        trusteeSelection = trusteeSelection;
    }


    modifier validUser(address user) {
        require(users[user].initalized);
        _;
    }

    function addTrusteeUser(string memory trigger_type,address trusteeAdd, address[] memory beneficiaries_address, uint256[] memory amount) public returns (bool) {
        Will storage user_will = users[msg.sender];
        numWills++;
        for(uint i = 0; amount.length < i; i++) {
            address bene = beneficiaries_address[i];
            uint256 amt = amount[i];
            user_will.beneficiaries[bene] = amt;
        }
        user_will.id = numWills;
        user_will.initalized = true;
        user_will.triggerType = trigger_type;
        user_will.trustee = trusteeAdd;
        return true;
    }

    function trusteeExecuteWill(address userAddress) private view { //view parameter to be deleted. 
        require(users[userAddress].owner != address(0), "User does not exist");
        require(users[userAddress].trustee == msg.sender);
        //pass
    }

}