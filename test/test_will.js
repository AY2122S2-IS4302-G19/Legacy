const _deploy_contract = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

var WillStorage = artifacts.require("../contracts/WillStorage.sol");
var Legacy = artifacts.require("../contracts/Legacy.sol");
var DeathOracle = artifacts.require('../contracts/api/DeathOracle.sol');
var Escrow = artifacts.require('../contracts/apis/Escrow.sol');

contract("Legacy", function (accounts) {
  before(async () => {
    willInstance = await WillStorage.deployed();
    legacyInstance = await Legacy.deployed();
    DeathOracleInstance = await DeathOracle.deployed();
    EscrowInstance = await Escrow.deployed();
  });

  console.log("Testing Legacy Contract");

  it("4a. A1 adds L1 Trustee Trigger Will (TTW)", async () => {
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
      [100], // assets to xfer to beneficiaries
      { from: accounts[1], value: 10 } // willWriter & ether to transfer to platform
    );
    truffleAssert.eventEmitted(will1, "addingWill");
  });

  it("4b. A2 adds L1 Inactivity Trigger Will (ITW)", async () => {
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
      [accounts[8]], // beneficiaries
      [100], // assets to xfer to beneficiaries
      { from: accounts[2], value: 10 } // willWriter
    );
    truffleAssert.eventEmitted(will2, "addingWill");
  });

  it("4c. A3 adds L0 TTW with Own Wallet (_OW)", async () => {
    // Own Wallet with Trustee Trigger
    let will3 = await legacyInstance.createWill(
      [accounts[8], accounts[9]], // trustees
      accounts[8], // custodian
      0, // custodianAccess
      true, // trusteeTrigger
      true, // ownWallet
      false, // ownLT
      false, // convertLT
      0, // inactiveDays
      [accounts[8]], // beneficiaries
      [100], // assets to xfer to beneficiaries
      { from: accounts[3], value: 10 } // willWriter
    );
    truffleAssert.eventEmitted(will3, "addingWill");
  });

  it("4d. A4 adds L2 ITW with Token Conversion (_TC)", async () => {
    let will4 = await legacyInstance.createWill(
      [accounts[2], accounts[3]], // trustees
      accounts[2], // custodian
      2, // custodianAccess
      false, // trusteeTrigger
      false, // ownWallet
      true, // ownLT
      false, // convertLT
      366, // inactiveDays
      [accounts[2]], // beneficiaries
      [100], // assets to xfer to beneficiaries
      { from: accounts[4], value: 200000000000000 } // willWriter & ether to transfer to platform
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

  it("4e. A5 cannot add L1 ITW_OW since 0 ETH paid", async () => {
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

  it("4f. A6 cannot add ITW with inactivity period < 365 days", async () => {
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

  it("4g. A7 cannot add Will if length(beneficiary addresses) != length(beneficiary %s)", async () => {
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

  it("4h. A1 cannot add Will if already exists", async () => {
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

  it("4i. A1 updates Will", async () => {
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

  it("4j. A1 updates beneficiaries", async () => {
    let update2 = await legacyInstance.updateBeneficiaries(
      [accounts[3], accounts[5]],
      [50, 50],
      { from: accounts[1] }
    );
    truffleAssert.eventEmitted(update2, "updatingBeneficiaries");
  });

  it("4k. A2 removes will", async () => {
    let delete1 = await legacyInstance.deleteWill({ from: accounts[2] });
    truffleAssert.eventEmitted(delete1, "deletingWill");
  });

  it("5a. A3's Trustee cannot update A3's L0 Will due to restricted access", async () => {
    await truffleAssert.fails(
      legacyInstance.updateWill(
        accounts[3],
        [accounts[8], accounts[9]],
        accounts[8],
        0,
        true,
        true,
        false,
        false,
        0,
        [accounts[8], accounts[9]],
        [50, 50],
        { from: accounts[9] }
      ),
      truffleAssert.ErrorType.REVERT,
      "unauthorized"
    );
  });

  it("5b. A3's Custodian cannot update A3's L0 Will due to restricted access", async () => {
    await truffleAssert.fails(
      legacyInstance.updateWill(
        accounts[3],
        [accounts[8], accounts[9]],
        accounts[8],
        1,
        true,
        true,
        false,
        false,
        0,
        [accounts[8]],
        [100],
        { from: accounts[8] }
      ),
      truffleAssert.ErrorType.REVERT,
      "unauthorized"
    );
  });

  it("5c. A1's Trustee cannot update A1's L1 Will due to restricted access", async () => {
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
        368,
        [accounts[4]],
        [100],
        { from: accounts[3] }
      ),
      truffleAssert.ErrorType.REVERT,
      "unauthorized"
    );
  });

  it("5d. A1's Custodian can update A1's L1 Will", async () => {
    let updateWill1 = await legacyInstance.updateWill(
      accounts[1],
      [accounts[2], accounts[3]],
      accounts[2],
      1,
      false,
      false,
      false,
      true,
      367,
      [accounts[2]],
      [100],
      { from: accounts[2] }
    );
    truffleAssert.eventEmitted(updateWill1, "updatingWill");
  });

  it("5e. A4's Trustee can update A1's L2 Will", async () => {
    let updateWill4 = await legacyInstance.updateWill(
      accounts[4],
      [accounts[2], accounts[3]],
      accounts[2],
      2,
      false,
      false,
      true,
      false,
      369,
      [accounts[2]],
      [100],
      { from: accounts[3] }
    );
    truffleAssert.eventEmitted(updateWill4, "updatingWill");
  });

  it("5f. A4's Custodian can update A4's L2 Will", async () => {
    let updateWill4 = await legacyInstance.updateWill(
      accounts[4],
      [accounts[2], accounts[3]],
      accounts[2],
      2,
      false,
      false,
      true,
      false,
      369,
      [accounts[4]],
      [100],
      { from: accounts[2] }
    );
    truffleAssert.eventEmitted(updateWill4, "updatingWill");
  });

  it("6. A1's Trustee submits A1's death certificate", async () => {
    let death1 = await legacyInstance.submitDeathCertificate(
      accounts[1],
      "https://upload.wikimedia.org/wikipedia/commons/0/06/Eddie_August_Schneider_%281911-1940%29_death_certificate.gif",
      { from: accounts[3] }
    );
    truffleAssert.eventEmitted(death1, "submittedDeathCert");
  });



  it("7a. Activate will from Custodian/Trustee (Legacy Token)", async () => {
    let will4 = await legacyInstance.createWill(
      [accounts[2], accounts[3]], // trustees
      accounts[2], // custodian
      2, // custodianAccess
      true, // trusteeTrigger
      false, // ownWallet
      true, // ownLT
      false, // convertLT
      366, // inactiveDays
      [accounts[2]], // beneficiaries
      [100], // assets to xfer to beneficiaries
      { from: accounts[8], value: 200000000000000 } // willWriter & ether to transfer to platform
    );

    let bal1 = await legacyInstance.checkCredit({ from: accounts[8] });
    truffleAssert.eventEmitted(bal1, "balance", (ev) => {
      return ev.bal == 100;
    });
    let bal2 = await legacyInstance.checkCredit({ from: accounts[2] });
    truffleAssert.eventEmitted(bal2, "balance", (ev) => {
      return ev.bal == 0;
    });

    let death1 = await legacyInstance.submitDeathCertificate(
      accounts[8],
      "https://upload.wikimedia.org/wikipedia/commons/0/06/Eddie_August_Schneider_%281911-1940%29_death_certificate.gif",
      { from: accounts[2] }
    );
    truffleAssert.eventEmitted(death1, "submittedDeathCert");

    let verifyDeath1 = await DeathOracleInstance.verify(accounts[8], { from: accounts[0] });
    let execute1 = await legacyInstance.executeWill(accounts[8], { from: accounts[2] })

    let bal3 = await legacyInstance.checkCredit({ from: accounts[8] });
    truffleAssert.eventEmitted(bal3, "balance", (ev) => {
      return ev.bal == 0;
    });
    let bal4 = await legacyInstance.checkCredit({ from: accounts[2] });
    truffleAssert.eventEmitted(bal4, "balance", (ev) => {
      return ev.bal == 100;
    });
  }) 

  it("7b. Activate will from Custodian/Trustee (Own Wallet Ether)", async () => {
    let will5 = await legacyInstance.createWill(
      [accounts[2], accounts[3]], // trustees
      accounts[2], // custodian
      2, // custodianAccess
      true, // trusteeTrigger
      true, // ownWallet
      false, // ownLT
      false, // convertLT
      366, // inactiveDays
      [accounts[7]], // beneficiaries
      [100], // % assets to xfer to beneficiaries
      { from: accounts[9], value: 250000000000000 } // willWriter & ether to transfer to platform
    );

    let b1 = await EscrowInstance.getEtherBal(accounts[9], { from: accounts[0] })
    assert(b1 == 250000000000000);
    let b2 = await EscrowInstance.getEtherBal(accounts[7], { from: accounts[0] })
    assert(b2 == 0);

    let death2 = await legacyInstance.submitDeathCertificate(
      accounts[9],
      "https://upload.wikimedia.org/wikipedia/commons/0/06/Eddie_August_Schneider_%281911-1940%29_death_certificate.gif",
      { from: accounts[3] }
    );
    truffleAssert.eventEmitted(death2, "submittedDeathCert");

    let verifyDeath2 = await DeathOracleInstance.verify(accounts[9], { from: accounts[0] });

    let b3 = await EscrowInstance.getEtherBal(accounts[9], { from: accounts[0] })
    assert(b3 == 250000000000000);
    let b4 = await EscrowInstance.getEtherBal(accounts[7], { from: accounts[0] })
    assert(b4 == 0);
  })
});
