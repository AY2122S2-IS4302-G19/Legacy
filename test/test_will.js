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
            [100],
            { from: accounts[1], value: 10**18 }
        );
        truffleAssert.eventEmitted(will1, 'addingWill');
    })

    it("Add will fails", async () => {

        // Own wallet is false, but yet no ether is transferred to the platform
        await truffleAssert.fails(legacyInstance.createWill(
            [accounts[2], accounts[3]],
            accounts[2],
            1,
            false,
            false,
            false,
            false,
            366,
            [accounts[4]],
            [100],
            {from: accounts[1], value: 0 }
        ),truffleAssert.ErrorType.REVERT,"No ether received when legacy platform as custodian is chosen")

        // Inactivity less than 365 days
        await truffleAssert.fails(legacyInstance.createWill(
            [accounts[2], accounts[3]],
            accounts[2],
            1,
            false,
            false,
            false,
            false,
            1,
            [accounts[4]],
            [100],
            {from: accounts[1], value: 10 }
        ),truffleAssert.ErrorType.REVERT,"Please set inactivity days to be at least 365 days")
        
        // Beneficiaries and weight information inconsistent
        await truffleAssert.fails(legacyInstance.createWill(
            [accounts[2], accounts[3]],
            accounts[2],
            1,
            false,
            false,
            false,
            false,
            366,
            [accounts[4]],
            [100,10],
            {from: accounts[1], value: 10 }
        ),truffleAssert.ErrorType.REVERT,"Please check beneficiaries and weights information")
        
    })

    it("check balances", async () =>{
        let bal = await legacyInstance.getBalances();
        assert(bal == 10**18)
    })

    it("Updating Will", async () => {
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
            [100],
            { from: accounts[1], value: 10**18 }
        );

        let updateWill1 = await legacyInstance.updateWill(
            [accounts[2], accounts[3]],
            accounts[2],
            1,
            false,
            false,
            false,
            true,
            366,
            [accounts[4]],
            [100],
            {from: accounts[1]}
        );
        truffleAssert.eventEmitted(updateWill1, "updatingWill");            
    })

    it("Updating beneficiaries", async () => {
        let update2 = await legacyInstance.updateBeneficiaries(
            [accounts[3],accounts[5]],
            [50,50],{from:accounts[1]}
        )
        truffleAssert.eventEmitted(update2, "updatingBeneficiaries")

    })

    it("Removing will", async ()=>{
        let delete1 = await legacyInstance.deleteWill({from:accounts[1]});
        truffleAssert.eventEmitted(delete1, 'deletingWill');
        
    })


    
})