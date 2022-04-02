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

    it('1. Add Will', async () => {
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

    it('2. Submit Account 1 Death Certificate', async () => {
        let death1 = await legacyInstance.submitDeathCertificate(
            accounts[1],
            "https://upload.wikimedia.org/wikipedia/commons/0/06/Eddie_August_Schneider_%281911-1940%29_death_certificate.gif",
            { from: accounts[9] }
        )
        truffleAssert.eventEmitted(death1, 'submittedDeathCert');
    })
})