// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract TransactionOracle {

    function getLatestTransactionTimestamp(address add) public view returns (uint256) {
        require(add != address(0));
        return block.timestamp - 31536000;
    }
}