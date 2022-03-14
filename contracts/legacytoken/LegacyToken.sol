// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract LegacyToken {
    struct legacyToken {
        uint256 value;
        address owner;
        address prevOwner;
    }
}