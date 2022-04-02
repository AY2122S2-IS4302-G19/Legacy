// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./ERC20.sol";

//Requries legal authority - suppose legal authorithy have address of ___
//Since we are encouraging people to use our Token, there is no limit as to how much they can have
//1 LT = 0.1 ether, 100000000000000000 wei, 100000000 gwei
//1 LT token for transferring from other currency to token
//6 LT token for transferring from token other currency

contract LegacyToken {
    ERC20 erc20Contract;
    address legacyOwner;
    uint256 getCreditFee = 1;

    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        legacyOwner = msg.sender;
    }

    function getLegacyToken() public payable {
        uint256 amt = msg.value / 100000000000000000;
        erc20Contract.mint(msg.sender, amt);
    }

    /*
    struct legacyToken {
        uint256 value;
        address owner;
        address prevOwner;
    }*/
    
}