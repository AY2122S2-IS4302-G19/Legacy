const LegacyToken = artifacts.require("LegacyToken");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(LegacyToken);
};
