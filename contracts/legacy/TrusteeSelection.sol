// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract TrusteeSelection {
    mapping(address => address) custodian;
    mapping(address => uint256) custodianAccess;
    mapping(address => address[]) trustees;

    /* ACCESS LEVEL
    0: Trustees/Custodian has no access to any features.
    1: Custodian can act on behalf of Will Writer
    2: Trustee can act on behalf of Will Writer
    */

    modifier authorize(address willWriter, address executor) {
        require(isAuthorized(willWriter, executor));
        _;
    }

    function isAuthorized(address willWriter, address executor) public view returns (bool) {
        if (custodianAccess[willWriter] == 0) {
            return executor == willWriter;
        } else if (custodianAccess[willWriter] == 1) {
            return executor == willWriter || executor == custodian[willWriter];
        } else if (custodianAccess[willWriter] == 2) {
            return executor == willWriter || executor == custodian[willWriter] || inTrustees(willWriter, executor);
        }
        return false;
    }

    function inTrustees(address willWriter, address trustee) public view returns (bool) {
        for (uint256 i = 0; i < trustees[willWriter].length; i++) {
            if (trustees[willWriter][i] == trustee) {
                return true;
            }
        }
        return false;
    }

    function addTrustee(address willWriter, address executor, address trustee) public authorize(willWriter, executor) {
        trustees[willWriter].push(trustee);
    }

    function removeTrustee(address willWriter, address executor, address trustee) public authorize(willWriter, executor) {
        for (uint256 i = 0; i < trustees[willWriter].length; i++) {
            if (trustees[willWriter][i] == trustee) {
                delete trustees[willWriter][i];
            }
        }
    }

    function getTrustees(address willWriter)
        public
        view
        returns (address[] memory)
    {
        return trustees[willWriter];
    }

    function addCustodian(address willWriter, address executor, address cust) public authorize(willWriter, executor) {
        require(
            custodian[willWriter] == address(0),
            "Custodian already set. Please remove before adding"
        );
        custodian[willWriter] = cust;
    }

    function removeCustodian(address willWriter, address executor) public authorize(willWriter, executor) {
        require(
            custodian[willWriter] != address(0),
            "Custodian already set. Please remove before adding"
        );
        delete custodian[willWriter];
    }

    function getCustodian(address willWriter) public view returns (address) {
        return custodian[willWriter];
    }

    function setCustodianAccess(address willWriter, address executor, uint256 access) public authorize(willWriter, executor) {
        custodianAccess[willWriter] = access;
    }
}
