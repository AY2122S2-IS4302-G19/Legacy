const Legacy = artifacts.require("Legacy");
const LegacyToken = artifacts.require("LegacyToken");

module.exports = (deployer, network, accounts) => {
    deployer.deploy(Legacy);
    deployer.deploy(LegacyToken);
}