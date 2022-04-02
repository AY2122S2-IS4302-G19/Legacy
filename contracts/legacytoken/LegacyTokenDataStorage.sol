pragma solidity ^0.5.0;

contract LegacyTokenDataStorage {
     mapping(address => bytes32) public tokenAmount;

    function getAmount(address user) public view returns (bytes32) {
        return tokenAmount[user];
    }

    function setAmount(address user, bytes32 newAmount) public {
        tokenAmount[user] = newAmount;
    }
}