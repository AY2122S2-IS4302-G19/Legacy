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

    it('1. Add Wills', async () => {
        // Trigger Trigger
        let will1 = await legacyInstance.createWill(
            [accounts[2], accounts[3]],     // trustees
            accounts[2],                    // custodian
            1,                              // custodianAccess
            false,                          // trusteeTrigger
            false,                          // ownWallet
            false,                          // ownLT
            false,                          // convertLT
            366,                            // inactiveDays
            [accounts[4]],                  // beneficieries
            [10],                           // assets to xfer to benefiecieries
            { from: accounts[1] }           // willWriter
        );

        // Inactivity Trigger
        let will2 = await legacyInstance.createWill(
            [accounts[5], accounts[6]],     // trustees
            accounts[7],                    // custodian
            1,                              // custodianAccess
            true,                           // trusteeTrigger
            false,                          // ownWallet
            false,                          // ownLT
            false,                          // convertLT
            0,                              // inactiveDays
            [accounts[8]],                  // beneficieries
            [10],                           // assets to xfer to benefiecieries
            { from: accounts[2] }           // willWriter
        );

        truffleAssert.eventEmitted(will1, 'addingWill');
        truffleAssert.eventEmitted(will2, 'addingWill');
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