pragma solidity ^0.5.0;

import "../legacytoken/LegacyToken.sol";

contract LegacyInvestment is Ownable {

    LegacyToken legacyToken;
    address owner;
    uint256 interestRate;
    mapping(address => uint256) buyPrices;
    mapping(address => uint256) sellPrices;

    struct Investment {
        uint256 id,
        string stockCode,
        uint256 buyPrice,
        uint256 sellPrice,
    }

    constructor(LegacyToken lt) public {
        legacyToken = lt;
        owner = msg.sender;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "You are not the owner of the contract");
        _;
    }

     // set interest rate 
    function setInterestRate(uint256 rate) public ownerOnly() {
        interestRate = rate;
    }

    // emit event
    function buy (uint value, uint stock) {

    }

    // emit event 
    function sell (uint value, uint stock) {

    }

    function withdraw(uint amt) ownerOnly() {

    }

    //enabled money payout


    //disable monthly payout


    //connect to oracle to check earnings


    // distribute earnings 


    // set duration to payout earnings


}