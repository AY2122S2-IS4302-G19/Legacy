const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
const timeMachine = require('ganache-time-traveler');
var assert = require("assert");

var Legacy = artifacts.require("../contracts/legacy/Legacy.sol");
var LegacyToken = artifacts.require("../contracts/legacyToken/LegacyToken.sol");

contract('LegacyToken', function(accounts) {
    
    before(async () => {
        legacyInstance = await Legacy.deployed();
        legacyTokenInstance = await LegacyToken.deployed();
    });

    console.log("Testing Legacy Token Contract");

    it('1a. Buy LT Token', async() => {
        let t1 = await legacyTokenInstance.getLegacyToken(accounts[1], {from: accounts[1], value: 250000000000000});
        truffleAssert.eventEmitted(t1, "getToken", (ev) => {
            return ev.numTokens == 100;
        });
        truffleAssert.eventEmitted(t1, "userAdded");
    })

    it('1b. Set Interest Rate to 1% and interest compounding rate to 1 year', async() => {
        let t1 = await legacyTokenInstance.setInterestRate(101, 31536000, {from: accounts[0]});
        truffleAssert.eventEmitted(t1, "interestRateSet", (ev) => {
            return ev.rate == 101 && ev.period == 31536000;
        })
    })

    it('1c. Returning user buys LT Token', async() => {
        let t1 = await legacyTokenInstance.getLegacyToken(accounts[1],{from: accounts[1], value: 250000000000000});
        truffleAssert.eventEmitted(t1, "getToken");
        truffleAssert.eventNotEmitted(t1, "userAdded");
        truffleAssert.eventEmitted(t1, "depositedInterest", (ev) => {
            return ev.newBalance == 100;
        });
    })

    it("1d. Buying Legacy token through Legacy", async () =>{
        let tok1 = await legacyInstance.getToken(accounts[2],{from:accounts[2], value:250000000000000});
        let credit = await legacyInstance.checkCredit({from:accounts[2]});
        truffleAssert.eventEmitted(credit, "balance", (ev) => {
            return ev.bal == 100
        });
    })
});

contract('Legacy Token Time Dependent Tests', function (accounts) {

    beforeEach(async() => {
        let snapshot = await timeMachine.takeSnapshot();
        snapshotId = snapshot['result'];
    });
 
    afterEach(async() => {
        await timeMachine.revertToSnapshot(snapshotId);
    });
 
    before(async () => {
        legacyInstance = await Legacy.deployed();
        legacyTokenInstance = await LegacyToken.deployed();
    });
 
    it('2a. Buy Legacy Token and check balance plus interest earned after 1 year', async () => {
        let t1 = await legacyTokenInstance.getLegacyToken(accounts[1], {from: accounts[1], value: 250000000000000});
        await timeMachine.advanceTimeAndBlock(31536000);

        let balance = await legacyTokenInstance.checkLTCredit(accounts[1], {from: accounts[1]});
        truffleAssert.eventEmitted(balance, "getBalance", (ev) => {
            return ev.balance == 101;
        })
    });
 });