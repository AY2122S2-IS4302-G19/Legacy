// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract TrusteeSelection {
    mapping(address => address) custodian;
    mapping(address => uint256) custodianAccess;
    mapping(address => address[]) trustees;

    function addTrustee(address trustee) public {
        // TODO
    }

    function removeTrustee(address trustee) public {
        // TODO
    }

    function getTrustees(address willWriter) public {
        // TODO
    }

    function addCustodian(address cust) public {
        // TODO
    }

    function removeCustodian(address cust) public {
        // TODO
    }

    function getCustodian(address willWriter) public {
        // TODO
    }

    function setCustodianAccess(uint256 access) public {
        // TODO
    }
}
