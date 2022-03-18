const Legacy = artifacts.require("LegacyToken");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(Legacy);
};
