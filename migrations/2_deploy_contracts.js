const ERC20 = artifacts.require("ERC20");
const LegacyToken = artifacts.require("LegacyToken");
const WillStorage = artifacts.require("WillStorage");
const DeathOracle = artifacts.require("DeathOracle");
const TransactionOracle = artifacts.require("TransactionOracle");
const Legacy = artifacts.require("Legacy");

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(ERC20);
  await deployer.deploy(LegacyToken, {from: accounts[0]});
  await deployer.deploy(WillStorage);
  await deployer.deploy(DeathOracle);
  await deployer.deploy(TransactionOracle);
  await deployer.deploy(
    Legacy,
    LegacyToken.address,
    WillStorage.address,
    DeathOracle.address,
    TransactionOracle.address
  );
};
