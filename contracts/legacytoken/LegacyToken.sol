pragma solidity ^0.5.0;

import "./ERC20.sol";

//Requries legal authority - suppose legal authorithy have address of ___
//Since we are encouraging people to use our Token, there is no limit as to how much they can have
//2 LT = 0.01 ether, 1 ether = 200 LT
// 2% of LT token as transferFee for transferring from token other currency > token is transfered to owner. 98% of token is converted to ether sent to msg.sender


import "./ERC20.sol";
// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract LegacyToken {
    ERC20 erc20Contract;
    address payable legacyOwner;
    uint256 getCreditFee = 1;
    
    address[] users;
    uint256 interestRate;

    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        legacyOwner = msg.sender;
    }

    event getToken();
    event sellToken(uint256 tokens); 
    event toTransferToken(address toPerson, uint256 tokens); 


    function getLegacyToken() public payable {
        uint256 amt = 2 * msg.value / 10000000000000000;
        erc20Contract.mint(msg.sender, amt);

        emit getToken();
    }

    function sellLegacyToken(uint256 tokens) public payable {
        require(tokens > 0, "You need to sell at least some tokens");
        uint256 userBalance = erc20Contract.balanceOf(msg.sender);
        require(userBalance >= tokens, "Your token balance is lower than the amount you want to sell");
        uint256 toPay = erc20Contract.unmint(msg.sender, tokens);
        msg.sender.transfer(toPay);
        emit sellToken(tokens);
    }

    function transferToken(address toPerson, uint256 tokens) public returns (bool) {
        require(tokens > 0, "You need to sell at least some tokens");
        erc20Contract.transfer(toPerson,tokens);
        emit toTransferToken(toPerson, tokens);
    }


    function checkLTCredit() notOwner public view returns (uint256) {
        return erc20Contract.balanceOf(msg.sender);
    }

    function totalSupply() public view returns (uint256) {
        return erc20Contract.totalSupply();
    }

    function checkOwnerLTCredit() onlyOwner public view returns (uint256) {
        return erc20Contract.balanceOf(address(this));
    }

    function checkOwnerWei() onlyOwner public view returns (uint256) {
        return erc20Contract.getEther() ;
    }

    modifier onlyOwner() {
        require(msg.sender == legacyOwner);
        _;
    }

    modifier notOwner() {
        require(msg.sender != legacyOwner);
        _;
    }

}
