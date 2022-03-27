const _deploy_contract = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

var WillStorage = artifacts.require("../contracts/WillStorage.sol");
var Legacy = artifacts.require("../contracts/Legacy.sol");

contract('Legacy', function (accounts) {
    before(async () => {
        willInstance = await WillStorage.deployed();
        legacyInstance = await Legacy.deployed();
    });
    console.log("Testing Legacy Contract");
    it('Add Will', async () => {
        let will1 = await legacyInstance.createWill(
            [accounts[2], accounts[3]],
            accounts[2],
            1,
            false,
            false,
            false,
            false,
            366,
            [accounts[4]],
            [10],
            { from: accounts[1] }
        );
        truffleAssert.eventEmitted(will1, 'addingWill');
    })
})