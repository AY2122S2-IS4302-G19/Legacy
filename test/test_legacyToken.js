const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
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

    it('1b. Set Interest Rate to 1% and interest compounding rate to 1 minutes', async() => {
        let t1 = await legacyTokenInstance.setInterestRate(101, 60, {from: accounts[0]});
        truffleAssert.eventEmitted(t1, "interestRateSet", (ev) => {
            return ev.rate == 101 && ev.period == 60;
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

    it("Sell Legacy token", async() => {

    })

});