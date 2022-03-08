// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
// pragma experimental ABIEncoderV2; //Need to be included for Will struct to be used as parameter inside functions

import "./TrusteeSelection.sol";

contract Legacy {
    
    struct Will {
        uint id;
        bool initalized; //false by default, helps to check if will exist
        string triggerType;
    }

    TrusteeSelection trusteeSelection;
    address _owner = msg.sender;
    mapping(address => Will) users;

    constructor(TrusteeSelection trusteeSelection) public {
        trusteeSelection = trusteeSelection;
    }


    modifier validUser(address user) {
        require(users[user].initalized);
        _;
    }

    function addUser() public {
        Will memory will = Will(0,true, "custodian");
        users[msg.sender] = will;
    }

    function executeWill() private {
        //pass
    }
}