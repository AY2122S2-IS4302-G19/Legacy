// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
// pragma experimental ABIEncoderV2; //Need to be included for Will struct to be used as parameter inside functions

contract Legacy {
    
    struct Will {
        uint id;
        bool initalized; //false by default, helps to check if will exist
    }

    mapping(address => Will) users;
    address _owner;


    modifier validUser(address user) {
        require(users[user].initalized);
        _;
    }

    function addUser() public {
        Will memory will = Will(0,true);
        users[msg.sender] = will;
    }
}