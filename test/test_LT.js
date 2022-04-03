const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');


var legacyToken = artifacts.require("../contracts/LegacyToken.sol");

contract('LegacyToken', function(accounts) {

    before(async () => {
        ltInstance = await legacyToken.deployed();
    });
    console.log("Testing Legacy Token");

    it('Buy', async () => {
        let buyLT1 = await ltInstance.buy(1, 1000000000000000000);
        let buyLT2 = await ltInstance.buy(2, 1000000000000000000);

        console.log(buyLT1);
        console.log(buyLT2);
    })

    it('transfer ownership of legacyToken', async () => {

        let t1 = await ltInstance.transfer(1, accounts[3]);

        truffleAssert.eventEmitted(t1, 'transferred legacy token');
    })
}
)