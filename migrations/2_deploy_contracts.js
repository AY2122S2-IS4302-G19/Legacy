const TrusteeSelection = artifacts.require("TrusteeSelection");
const LegacyToken = artifacts.require("LegacyToken");
const Legacy = artifacts.require("Legacy");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(TrusteeSelection).then(function () {
    deployer.deploy(Legacy, TrusteeSelection.address);
    deployer.deploy(LegacyToken, Legacy.address);
  });
};
