pragma solidity >=0.5.0;

import "./ERC20.sol";

//Requries legal authority - suppose legal authorithy have address of ___
//Since we are encouraging people to use our Token, there is no limit as to how much they can have
//2 LT = 0.01 ether, 1 ether = 200 LT
// 2% of LT token as transferFee for transferring from token other currency > token is transfered to owner. 98% of token is converted to ether sent to msg.sender


contract LegacyToken {
    ERC20 erc20Contract;
    address payable legacyOwner;
    uint256 getCreditFee = 1;
    
    mapping(address => uint256) users;
    mapping(address => uint256) interestStart;
    uint256 interestRate;
    uint256 interestPeriod;


    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        legacyOwner = payable(msg.sender);
    }

    event getToken();
    event userAdded(address newUser);
    event sellToken(uint256 tokens); 
    event toTransferToken(address toPerson, uint256 tokens); 

    event interestRateSet(uint256 rate, uint256 period);
    event depositedInterest(uint256 newBalance, uint256 interestStart);
    event debug(uint256 bug);


    function isExistingUser(address sender) public view returns (bool) {
        if (users[sender] == 0) {
            return false;
        }
        return true;
    }

    function getLegacyToken() public payable {
        uint256 amt = 2 * msg.value / 10000000000000000;
       
        if (!isExistingUser(msg.sender)) {
            users[msg.sender] = 1;
            interestStart[msg.sender] = block.timestamp;
            emit userAdded(msg.sender);
        } else {
            //lazy update of interest earned
            depositInterest(msg.sender);
        }

        erc20Contract.mint(msg.sender, amt);
        emit getToken();
    }

    function sellLegacyToken(uint256 tokens) public payable {
        require(tokens > 0, "You need to sell at least some tokens");
        uint256 userBalance = erc20Contract.balanceOf(msg.sender);
        require(userBalance >= tokens, "Your token balance is lower than the amount you want to sell");
        depositInterest(msg.sender);
        uint256 toPay = erc20Contract.unmint(msg.sender, tokens);
        payable(msg.sender).transfer(toPay);
        emit sellToken(tokens);
    }

    function transferToken(address toPerson, uint256 tokens) public {
        require(tokens > 0, "You need to sell at least some tokens");
        erc20Contract.transfer(toPerson,tokens);
        emit toTransferToken(toPerson, tokens);
    }

    //interest rate = 1%, set: interestRate = 1
    function setInterestRate(uint256 rate, uint256 period) onlyOwner public {
        require(rate >= 0, "Interest rate cannot be negative");
        interestRate = rate;
        interestPeriod = period;
        emit interestRateSet(rate, period);
    }

    function depositInterest(address sender) internal {
        uint256 balance = erc20Contract.balanceOf(msg.sender);
        uint256 newBalance;
        uint256 numPeriods;
        (newBalance, numPeriods) = calculateInterest(balance, sender);
        
        erc20Contract.mint(sender, newBalance - balance);
        interestStart[sender] = interestStart[sender] + numPeriods * interestPeriod;
        emit depositedInterest(newBalance, interestStart[sender]);
    }


    function calculateInterest(uint256 principal, address sender) public view returns (uint256, uint256) {
        uint256 numPeriods = (block.timestamp - interestStart[sender]) / interestPeriod;
        for (uint period = 0; period < numPeriods; period++)  
            principal += principal * interestRate / 10000;
        return (principal, numPeriods);
    }

    function checkLTCredit() public view returns (uint256) {     
        uint256 balance = erc20Contract.balanceOf(msg.sender);
        uint256 newBalance;
        (newBalance, ) = calculateInterest(balance, msg.sender);
        return newBalance;
    }

    function totalSupply() public view returns (uint256) {
        return erc20Contract.totalSupply();
    }

    // function checkOwnerLTCredit() onlyOwner public view returns (uint256) {
    //     return erc20Contract.balanceOf(address(this));
    // }

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
