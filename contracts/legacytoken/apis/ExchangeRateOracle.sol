// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract ExchangeRateOracle {

    function getEtherSGDExchangeRate() pure public returns (uint256) {
        return 2500000000000;
    }
} 