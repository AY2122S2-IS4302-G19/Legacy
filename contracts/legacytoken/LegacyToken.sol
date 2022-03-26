// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./ERC20.sol";

contract LegacyToken {
    ERC20 erc20Contract;
    uint256 currentSupply;
    address owner;

     constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        owner = 0x3897Ea9999920fc5d883b51f17496f0E0EBa13CD;
    }
}