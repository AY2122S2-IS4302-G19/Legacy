// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../legacytoken/LegacyToken.sol";

contract WillStorage {
    LegacyToken legacyToken;
    uint256 numWill;
    mapping(uint256 => address) usersAdd; // works just like an array but is cheaper to use mapping
    mapping(address => Will) users;

    constructor(LegacyToken lt) public {
        legacyToken = lt;
        numWill = 1;
    }

    /* ACCESS LEVEL
    0: Trustees/Custodian has no access to any features.
    1: Custodian can act on behalf of Will Writer
    2: Trustee can act on behalf of Will Writer
    */

    struct Will {
        uint256 id;
        address willWriter;
        address custodian;
        uint256 custodianAccess;
        address[] trustees;
        bool trusteeTrigger; // true = trustee, false = inactivity
        bool ownWallet; // whether the user wants to store $$ in their own wallet or into legacy platform
        bool ownLegacyToken; // whether the user wants to convert to legacy token at the point of adding user
        bool convertLegacyPOW; // whether the user wants to covert to legacy token at the point of executing the will
        uint256 inactivityDays; // how many days does the wallet needs to be without activity before triggering the will.
        mapping(address => uint256) beneficiaries;
    }

    function hasWill(address willWriter) public view returns (bool) {
        return users[willWriter].id != 0;
    }

    function getNumWill() public view returns (uint256) {
        return numWill;
    }

    function addWill(
        address willWriter,
        address[] memory trustees,
        address custodian,
        uint256 custodianAccess,
        bool trusteeTrigger,
        bool ownWallet,
        bool ownLegacyToken,
        bool convertLegacyPOW,
        uint16 inactivityDays,
        address[] memory beneficiariesAddress,
        uint256[] memory amount
    ) public returns (uint256) {
        require(
            users[willWriter].id == 0,
            "Already has a will with Legacy, use update will function instead"
        );
        trusteeTrigger
            ? require(
                trustees.length > 0,
                "Cannot have empty trustee address when trustee option is selected"
            )
            : require(
                inactivityDays >= 365,
                "Please set inactivity days to be at least 365 days"
            );
        require(
            beneficiariesAddress.length != 0 &&
                beneficiariesAddress.length == amount.length,
            "Please check beneficiaries and amount information"
        );

        Will storage userWill = users[willWriter];
        userWill.id = numWill++;
        userWill.willWriter = willWriter;
        userWill.custodian = custodian;
        userWill.custodianAccess = custodianAccess;
        userWill.trustees = trustees;
        userWill.trusteeTrigger = trusteeTrigger;
        userWill.ownWallet = ownWallet;
        userWill.ownLegacyToken = ownLegacyToken;
        userWill.convertLegacyPOW = convertLegacyPOW;
        userWill.inactivityDays = inactivityDays;
        addBeneficiares(willWriter, beneficiariesAddress, amount);
        usersAdd[numWill] = willWriter;

        if (userWill.ownWallet) {
            // Seek approval to transfer his asset
        }
        if (userWill.ownLegacyToken) {
            // to convert $$ into Legacy token
        }
        return numWill;
    }

    function getAddressById(uint256 id) public view returns (address) {
        return usersAdd[id];
    }

    function isTrusteeTrigger(address willWriter) public view returns (bool) {
        return users[willWriter].trusteeTrigger;
    }

    function addTrustee(
        address willWriter,
        address executor,
        address trustee
    ) public authorize(willWriter, executor) {
        users[willWriter].trustees.push(trustee);
    }

    function removeTrustee(
        address willWriter,
        address executor,
        address trustee
    ) public authorize(willWriter, executor) {
        for (uint256 i = 0; i < users[willWriter].trustees.length; i++) {
            if (users[willWriter].trustees[i] == trustee) {
                delete users[willWriter].trustees[i];
            }
        }
    }

    function getTrustees(address willWriter)
        public
        view
        returns (address[] memory)
    {
        return users[willWriter].trustees;
    }

    function addCustodian(
        address willWriter,
        address executor,
        address cust
    ) public authorize(willWriter, executor) {
        require(
            users[willWriter].custodian == address(0),
            "Custodian already set. Please remove before adding"
        );
        users[willWriter].custodian = cust;
    }

    function removeCustodian(address willWriter, address executor)
        public
        authorize(willWriter, executor)
    {
        require(
            users[willWriter].custodian != address(0),
            "No custodian. Cannot remove."
        );
        delete users[willWriter].custodian;
    }

    function getCustodian(address willWriter) public view returns (address) {
        return users[willWriter].custodian;
    }

    function setCustodianAccess(
        address willWriter,
        address executor,
        uint8 access
    ) public authorize(willWriter, executor) {
        users[willWriter].custodianAccess = access;
    }

    function addBeneficiares(
        address willWriter,
        address[] memory beneficiariesAddress,
        uint256[] memory amount
    ) private {
        Will storage userWill = users[willWriter];
        for (uint256 i = 0; i < beneficiariesAddress.length; i++) {
            userWill.beneficiaries[beneficiariesAddress[i]] = amount[i];
        }
    }

    function removeBeneficiares(
        address willWriter,
        address[] memory beneficiariesAddress
    ) private {
        Will storage userWill = users[willWriter];
        for (uint256 i = 0; i < beneficiariesAddress.length; i++) {
            userWill.beneficiaries[beneficiariesAddress[i]] = 0;
        }
    }

    // Modifiers and authorization

    modifier authorize(address willWriter, address executor) {
        require(isAuthorized(willWriter, executor));
        _;
    }

    function isAuthorized(address willWriter, address executor)
        public
        view
        returns (bool)
    {
        if (users[willWriter].custodianAccess == 0) {
            return executor == willWriter;
        } else if (users[willWriter].custodianAccess == 1) {
            return
                executor == willWriter ||
                executor == users[willWriter].custodian;
        } else if (users[willWriter].custodianAccess == 2) {
            return
                executor == willWriter ||
                executor == users[willWriter].custodian ||
                inTrustees(willWriter, executor);
        }
        return false;
    }

    function inTrustees(address willWriter, address trustee)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < users[willWriter].trustees.length; i++) {
            if (users[willWriter].trustees[i] == trustee) {
                return true;
            }
        }
        return false;
    }

    function getInactivityDays(address add) public view returns (uint256) {
        return users[add].inactivityDays;
    }
}
