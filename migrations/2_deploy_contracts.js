const Legacy = artifacts.require("Legacy");
const LegacyToken = artifacts.require("LegacyToken");
const WillStorage = artifacts.require("WillStorage");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(LegacyToken).then(function () {
    return deployer.deploy(WillStorage, LegacyToken.address).then(function () {
      return deployer.deploy(Legacy, WillStorage.address)
    });
  });
};
