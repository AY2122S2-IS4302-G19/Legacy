const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

var Legacy = artifacts.require("../contracts/legacy/Legacy.sol");
var LegacyToken = artifacts.require("../contracts/legacyToken/LegacyToken.sol");

contract('LegacyToken', function(accounts) {
    before(async () => {
        legacyTokenInstance = await LegacyToken.deployed();
    });

    console.log("Testing Legacy Token Contract");

    it('Cet LT Token', async() => {
        let t1 = await legacyTokenInstance.getLegacyToken({from: accounts[1], value: 20000000000000000000});
        truffleAssert.eventEmitted(t1, "getToken");
    })
});