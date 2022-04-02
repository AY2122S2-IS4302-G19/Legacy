// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "contracts/legacytoken/ERC20.sol";
import "contracts/legacy/Legacy.sol";

//Requries legal authority - suppose legal authorithy have address of ___
//Since we are encouraging people to use our Token, there is no limit as to how much they can have
//2 LT = 1 ether, 100000000000000000 wei, 100000000 gwei
// 2% of LT token as transferFee for transferring from token other currency > token is transfered to owner. 98% of token is converted to ether sent to msg.sender


contract LegacyToken {
    ERC20 erc20Contract;
    Legacy legacy;
    address legacyOwner;
    uint256 getCreditFee = 1;

    constructor(Legacy legacyAddress) public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        legacyOwner = msg.sender;
        legacy = legacyAddress;
    }


    function getLegacyToken() public payable {
        uint256 amt = 2 * msg.value / 1000000000000000000;
        erc20Contract.mint(msg.sender, amt);
    }

    function sellLegacyToken(uint256 tokens) public payable {
        erc20Contract.unmint(msg.sender, tokens);
    }

}