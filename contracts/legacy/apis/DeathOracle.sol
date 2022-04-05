// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract DeathOracle {
    
    uint256 numCertificates;
    mapping(address => DeathCertificate) users;
    
    struct DeathCertificate {
        uint256 id;
        address requester;
        string url;
        bool verified;
    }

    function isVerifiedOracle(address oracle) public pure returns (bool) {
        /* Simulated Verification of Oracle Service */
        require(oracle != address(0));
        return true;
    }
    
    function isDead(address deceased) public view returns (bool) {
        return users[deceased].verified;
    }

    function submit(address deceased, string memory url) public {
        DeathCertificate storage dc = users[deceased];
        dc.id = numCertificates++;
        dc.requester = msg.sender;
        dc.url = url;
        dc.verified = false;
    }

    function verify(address deceased) public returns (bool) {
        require(isVerifiedOracle(msg.sender));
        /* Simulated Verification of Death Certificate */
        DeathCertificate storage dc = users[deceased];
        dc.verified = true;
        return true;
    }
}