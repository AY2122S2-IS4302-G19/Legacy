// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./ERC20.sol";
// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract LegacyToken {
    address legacyAccount;
    uint256 public _price;
    uint256 public comissionFee;
    ERC20 erc20Contract;
    mapping(address => bytes) public amount;

    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        legacyAccount = msg.sender;
    }

    struct legacyToken {
        uint256 value;
        address legacyAccount;
        address prevlegacyAccount;
    }

    uint256 public numTokens = 0;
    mapping(uint256 => legacyToken) public tokens;

    event transferLT(uint256 tokenId, address newlegacyAccount);

    //modifier to ensure a function is callable only by its legacyAccount
    modifier legacyAccountOnly(uint256 tokenId) {
        require(tokens[tokenId].legacyAccount == msg.sender);
        _;
    }

    modifier validTokenId(uint256 tokenId) {
        require(tokenId < numTokens);
        _;
    }

    function transfer(uint256 tokenId, address newlegacyAccount) public validTokenId(toknId) {
        tokens[tokenId].prevlegacyAccount = tokens[tokenId].legacyAccount;
        tokens[tokenId].legacyAccount = newlegacyAccount;

        emit transferLT(tokenId, newlegacyAccount);
    }

    function checkCredit() public returns(uint256) {
        uint256 credit = erc20Contract.balanceOf(msg.sender);
        emit creditChecked(credit);
        return credit;
    }

    function transferCredit(address recipient, uint256 amt) public {
        erc20Contract.transfer(recipient, amt);
    }

    function transferCreditFrom(address from, address to, uint256 amt) public {
        erc20Contract.transferFrom(from, to, amt);
    }

    function giveAllowance(address recipient, uint256 amt) public {
        erc20Contract.approve(recipient, amt);
    }

    // Buy the legacy token at the requested price
    function buy(uint256 id, uint256 price) public {
       require(price >= (_price + comissionFee));
       transferCreditFrom(msg.sender, _legacyAccount, comissionFee);
       transferCreditFrom(msg.sender, getPrevlegacyAccount(id), (price - comissionFee));
       transfer(id, msg.sender);
    }

    // getters
    function getValue(uint256 tokenId) public view validTokenId(tokenId) returns (address) {
        return tokens[tokenId].value;
    }

    function getlegacyAccount(uint256 tokenId) public view validTokenId(tokenId) returns (address) {
        return tokens[tokenId].legacyAccount;
    }

    function getPrevlegacyAccount(uint256 tokenId) public view validTokenId(tokenId) returns (address) {
        return tokens[tokenId].prevlegacyAccount;
    }
}