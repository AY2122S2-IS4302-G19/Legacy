const _deploy_contract = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

var WillStorage = artifacts.require("../contracts/WillStorage.sol");
var Legacy = artifacts.require("../contracts/Legacy.sol");

contract("Legacy", function (accounts) {
  before(async () => {
    willInstance = await WillStorage.deployed();
    legacyInstance = await Legacy.deployed();
  });

  console.log("Testing Legacy Contract");

  it("4a. Add Trustee Trigger Will (A1)", async () => {
    // Trustee Trigger
    let will1 = await legacyInstance.createWill(
      [accounts[2], accounts[3]], // trustees
      accounts[2], // custodian
      1, // custodianAccess
      true, // trusteeTrigger
      false, // ownWallet
      false, // ownLT
      false, // convertLT
      366, // inactiveDays
      [accounts[2]], // beneficiaries
      [100], // assets to xfer to benefiecieries
      { from: accounts[1], value: 10 } // willWriter & ether to transfer to platform
    );
    truffleAssert.eventEmitted(will1, "addingWill");
  });

  it("4b. Add Inactivity Trigger Will (A2)", async () => {
    // Inactivity Trigger
    let will2 = await legacyInstance.createWill(
      [accounts[5], accounts[6]], // trustees
      accounts[7], // custodian
      1, // custodianAccess
      true, // trusteeTrigger
      false, // ownWallet
      false, // ownLT
      false, // convertLT
      0, // inactiveDays
      [accounts[8]], // beneficieries
      [100], // assets to xfer to benefiecieries
      { from: accounts[2], value: 10 } // willWriter
    );
    truffleAssert.eventEmitted(will2, "addingWill");
  });

  it("4c. Add Trustee Trigger Will with Own Wallet (A3)", async () => {
    // Own Wallet with Trustee Trigger
    let will3 = await legacyInstance.createWill(
      [accounts[8]], // trustees
      [accounts[8]], // custodian
      1, // custodianAccess
      true, // trusteeTrigger
      true, // ownWallet
      false, // ownLT
      false, // convertLT
      0, // inactiveDays
      [accounts[8]], // beneficieries
      [100], // assets to xfer to benefiecieries
      { from: accounts[3], value: 10 } // willWriter
    );
    truffleAssert.eventEmitted(will3, "addingWill");
  });

  it("4d. Add Inactivity Trigger Will with Token Conversion (A4)", async () => {
    let will4 = await legacyInstance.createWill(
      [accounts[2], accounts[3]], // trustees
      accounts[2], // custodian
      1, // custodianAccess
      false, // trusteeTrigger
      false, // ownWallet
      true, // ownLT
      false, // convertLT
      366, // inactiveDays
      [accounts[4]], // beneficieries
      [100], // assets to xfer to benefiecieries
      { from: accounts[4], value: 250000000000000 } // willWriter & ether to transfer to platform
    );
    truffleAssert.eventEmitted(will4, "addingWill");

    let t1 = await legacyTokenInstance.setInterestRate(100, 60, {
      from: accounts[0],
    });
    truffleAssert.eventEmitted(t1, "interestRateSet", (ev) => {
      return ev.rate == 100 && ev.period == 60;
    });

    let bal1 = await legacyInstance.checkCredit({ from: accounts[4] });
    truffleAssert.eventEmitted(bal1, "balance", (ev) => {
      return ev.bal == 100;
    });
  });

  it("4e. Cannot add Inactivity Trigger Will with Own Wallet but 0 ETH (A5)", async () => {
    // Own wallet is false, but yet no ether is transferred to the platform
    await truffleAssert.fails(
      legacyInstance.createWill(
        [accounts[2], accounts[3]],
        accounts[2],
        1,
        false,
        false,
        false,
        false,
        366,
        [accounts[4]],
        [100],
        { from: accounts[5], value: 0 }
      ),
      truffleAssert.ErrorType.REVERT,
      "No ether received when legacy platform as custodian is chosen"
    );
  });

  it("4f. Cannot add Inactivity Trigger Will with <365 days (A6)", async () => {
    // Inactivity less than 365 days
    await truffleAssert.fails(
      legacyInstance.createWill(
        [accounts[2], accounts[3]],
        accounts[2],
        1,
        false,
        false,
        false,
        false,
        1,
        [accounts[4]],
        [100],
        { from: accounts[6], value: 10 }
      ),
      truffleAssert.ErrorType.REVERT,
      "Please set inactivity days to be at least 365 days"
    );
  });

  it("4g. Cannot add Will if length(beneficiary addresses) != length(beneficiary %s)", async () => {
    // Beneficiaries and weight information inconsistent
    await truffleAssert.fails(
      legacyInstance.createWill(
        [accounts[2], accounts[3]],
        accounts[2],
        1,
        false,
        false,
        false,
        false,
        366,
        [accounts[4]],
        [100, 10],
        { from: accounts[7], value: 10 }
      ),
      truffleAssert.ErrorType.REVERT,
      "Please check beneficiaries and weights information"
    );
  });

  it("4h. Cannot add Will if already exists. (A1)", async () => {
    await truffleAssert.fails(
      legacyInstance.createWill(
        [accounts[2], accounts[3]],
        accounts[2],
        1,
        false,
        false,
        false,
        false,
        366,
        [accounts[4]],
        [100],
        { from: accounts[1], value: 10 ** 18 }
      ),
      truffleAssert.ErrorType.REVERT,
      "Already has a will with Legacy, use update will function instead"
    );
  });

  it("4i. Update Will. (A1)", async () => {
    let updateWill1 = await legacyInstance.updateWill(
      accounts[1],
      [accounts[2], accounts[3]],
      accounts[2],
      1,
      false,
      false,
      false,
      true,
      366,
      [accounts[4]],
      [100],
      { from: accounts[1] }
    );
    truffleAssert.eventEmitted(updateWill1, "updatingWill");
  });

  it("4j. Update beneficiaries (A1)", async () => {
    let update2 = await legacyInstance.updateBeneficiaries(
      [accounts[3], accounts[5]],
      [50, 50],
      { from: accounts[1] }
    );
    truffleAssert.eventEmitted(update2, "updatingBeneficiaries");
  });

  it("4f. Remove Will (A2)", async () => {
    let delete1 = await legacyInstance.deleteWill({ from: accounts[2] });
    truffleAssert.eventEmitted(delete1, "deletingWill");
  });

  it("5a. Trustee (A3) cannot change inactivity days of Will with L1 access", async () => {
    await truffleAssert.fails(
      legacyInstance.updateWill(
        accounts[1],
        [accounts[2], accounts[3]],
        accounts[2],
        1,
        false,
        false,
        false,
        true,
        367,
        [accounts[4]],
        [100],
        { from: accounts[3] }
      ),
      truffleAssert.ErrorType.REVERT,
      "unauthorized"
    );
  });

  it("5b. Custodian (A2) can change inactivity days of Will with L1 access", async () => {
    let updateWill4 = await legacyInstance.updateWill(
      accounts[1],
      [accounts[2], accounts[3]],
      accounts[2],
      1,
      false,
      false,
      false,
      true,
      367,
      [accounts[4]],
      [100],
      { from: accounts[2] }
    );
    truffleAssert.eventEmitted(updateWill4, "updatingWill");
  });

  it("6. Trustee (A3) submit death certificate for A1 Will", async () => {
    let death1 = await legacyInstance.submitDeathCertificate(
      accounts[1],
      "https://upload.wikimedia.org/wikipedia/commons/0/06/Eddie_August_Schneider_%281911-1940%29_death_certificate.gif",
      { from: accounts[3] }
    );
    truffleAssert.eventEmitted(death1, "submittedDeathCert");
  });
});
