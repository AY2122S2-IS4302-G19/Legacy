pragma solidity ^0.5.0;

contract LegacyInvestment {

    address owner;

    modifier ownerOnly(address _owner) {
        require(owner == _owner);
        _;
    }

    // emit event
    function buy (uint value, uint stock) {

    }

    // emit event 
    function sell (uint value, uint stock) {

    }

    function withdraw(uint amt) {

    }

    //enabled money payout


    //disable monthly payout


    //connect to oracle to check earnings


    // distribute earnings 


    // set duration to payout earnings


    // set interest rate 

}