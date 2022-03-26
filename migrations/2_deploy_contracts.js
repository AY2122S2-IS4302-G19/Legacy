const Legacy = artifacts.require("Legacy");
const WillStorage = artifacts.require("WillStorage");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(WillStorage).then(function () {
    return deployer.deploy(Legacy, WillStorage.address);
  });
};
