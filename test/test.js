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
}