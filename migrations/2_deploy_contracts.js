const LegacyToken = artifacts.require("LegacyToken");
const Legacy = artifacts.require("Legacy");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(LegacyToken);
};
