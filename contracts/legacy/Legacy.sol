// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "./WillStorage.sol";
import "./apis/DeathOracle.sol";
import "./apis/TransactionOracle.sol";
import "./apis/Escrow.sol";

import "../legacytoken/LegacyToken.sol";
import "../legacytoken/ERC20.sol";

contract Legacy {
    WillStorage willStorage;
    LegacyToken lt;
    DeathOracle deathOracle;
    TransactionOracle transactionOracle;
    Escrow escrow;

    uint256 totalBalances;

    constructor(
        LegacyToken legacyt,
        WillStorage ws,
        DeathOracle doracle,
        // TransactionOracle toracle,
        Escrow es
    ) {
        lt = legacyt;
        willStorage = ws;
        deathOracle = doracle;
        escrow = es;
    }

    event addingWill();
    event updatingWill();
    event deletingWill();
    event updatingBeneficiaries();
    event executingTrusteeWill(address willWriter);
    event submittedDeathCert(address deceased);
    event balance(uint256 bal);

    event addresses_lst(address);
    event weight_debug(uint256[]);
    event transferingToBeneficiaries();

    modifier hasWill(address add) {
        require(willStorage.hasWill(add), "Please create a Will first");
        _;
    }

    function createWill(
        address[] memory trustees,
        address custodian,
        uint256 custodianAccess,
        bool trusteeTrigger,
        bool ownWallet,
        bool ownLegacyToken,
        bool convertLegacyPOW,
        uint16 inactivityDays,
        address[] memory beneficiariesAddress,
        uint256[] memory weights
    ) public payable {
        require(
            msg.value > 0,
            "No ether received when legacy platform as custodian is chosen"
        );
        willStorage.addWill(
            msg.sender,
            msg.value,
            trustees,
            custodian,
            custodianAccess,
            trusteeTrigger,
            ownWallet,
            ownLegacyToken,
            convertLegacyPOW,
            inactivityDays,
            beneficiariesAddress,
            weights
        );
        if (ownLegacyToken) {
            (bool success, ) = payable(address(this)).call{value: msg.value}(
                abi.encodeWithSignature("getToken(address)", msg.sender)
            );
            require(success, "Fail to get token");
        }
        if (ownWallet) {
            (bool success, ) = payable(address(escrow)).call{value: msg.value}(
            abi.encodeWithSignature("depositEther(address)", msg.sender)
        );
        require(success, "deposit failed");
        }
        totalBalances += msg.value;
        emit addingWill();
    }

    function getToken(address willWriter) public payable {
        require(msg.value > 0, "No ether received");
        (bool success, ) = payable(address(lt)).call{value: msg.value}(
            abi.encodeWithSignature("getLegacyToken(address)", willWriter)
        );
        require(success, "token mint failed");
    }

    function transferToken(address willWriter, address recipient) public {

    }

    function checkCredit() public returns (uint256) {
        uint256 bal = lt.checkLTCredit(msg.sender);
        emit balance(bal);
        return bal;
    }

    function getLegacyTokendeposited(address add) public returns (uint256) {
        uint256 bal = lt.checkDepositedBal(add);
        emit balance(bal);
        return bal;
    }

    function getBalances() public view returns (uint256) {
        return address(this).balance;
    }

    function updateBeneficiaries(
        address[] memory beneficiariesAddress,
        uint256[] memory weights
    ) public {
        willStorage.updateBeneficiares(
            msg.sender,
            beneficiariesAddress,
            weights
        );
        emit updatingBeneficiaries();
    }

    function updateWill(
        address willWriter,
        address[] memory trustees,
        address custodian,
        uint8 custodianAccess,
        bool trusteeTrigger,
        bool ownWallet,
        bool ownLegacyToken,
        bool convertLegacyPOW,
        uint16 inactivityDays,
        address[] memory beneficiariesAddress,
        uint256[] memory amount
    ) public {
        if (willWriter == address(0)) {
            willWriter = msg.sender;
        }
        willStorage.updateWill(
            willWriter,
            trustees,
            custodian,
            custodianAccess,
            trusteeTrigger,
            ownWallet,
            ownLegacyToken,
            convertLegacyPOW,
            inactivityDays,
            beneficiariesAddress,
            amount
        );

        emit updatingWill();
    }

    function deleteWill() public {
        willStorage.removeWill(msg.sender);
        emit deletingWill();
    }

    function executeWill(address willWriter) public hasWill(willWriter) {
        bool isTrustee =  willStorage.isTrusteeTrigger(willWriter);
        if (isTrustee) {
            require(
                willStorage.isAuthorized(willWriter, msg.sender),
                "You are not authorized to execute the trustee will"
            );
            require(
                deathOracle.isDead(willWriter),
                "User does not have a verified death certificate"
            );
        }
        
        transferToBeneficiaries(willWriter);

        // Perform the transferring of assets here

    }

    function transferToBeneficiaries(address willWriter) private hasWill(willWriter){
        bool hasLegacyToken = willStorage.ownsLegacyToken(willWriter);
        if(hasLegacyToken){
            transferTokenToBeneficiaries(willWriter);
        }
        bool ownWallet  =  willStorage.holdsInOwnWallet(willWriter);
        if (ownWallet) {
            bool convertLegacyToken = willStorage.convertToLegacyToken(willWriter);
            if(convertLegacyToken){
                //conver to legacy token;
                convertToLegacyToken(willWriter);
                transferTokenToBeneficiaries(willWriter);
            }else{
                transferEtherToBeneficiaries(willWriter);
            }
        }
    
    }

    function transferTokenToBeneficiaries(address willWriter) private {
        address[] memory addresses = willStorage.getBenficiariesAddress(willWriter);
        uint256[] memory weights = willStorage.getBenficiariesWeights(addresses, willWriter);
        uint256 tokenBalances = lt.checkLTCredit(willWriter);
        for(uint8 i = 0; i < weights.length; i ++){
            address recipient = addresses[i];
            uint256 token = tokenBalances * (weights[i]/100);
            lt.transferToken(willWriter,recipient, token);
        }
    }

    function transferEtherToBeneficiaries(address willWriter) private {
        address[] memory addresses = willStorage.getBenficiariesAddress(willWriter);
        uint256[] memory weights = willStorage.getBenficiariesWeights(addresses, willWriter);
        uint256 etherBalances = escrow.getEtherBal(willWriter);

        for(uint8 i = 1; i < weights.length; i ++){
            address recipient = addresses[i-1];
            uint256 eth = etherBalances * (weights[i]/100);
            escrow.transferEther(willWriter, recipient, eth);
        }
        
    }

    function convertToLegacyToken(address willWriter) payable public {
        uint256 etherBalances = escrow.getEtherBal(willWriter);
        escrow.transferEther(willWriter, address(this), etherBalances);
        (bool success, ) = payable(address(this)).call{value: etherBalances}(
                abi.encodeWithSignature("getToken(address)", willWriter)
            );
        require(success,"Conversion to legacy token fail");
    }

    function submitDeathCertificate(address willWriter, string memory url)
        public
        hasWill(willWriter)
    {
        deathOracle.submit(willWriter, url);
        emit submittedDeathCert(willWriter);
    }

    // just throw this method into the most used function and
    // that's how inactivity wills will get triggered
    function triggerInactivityWills() private  {
        for (uint256 i = 1; i <= willStorage.getNumWill(); i++) {
            address add = willStorage.getAddressById(i);
            if (!willStorage.isTrusteeTrigger(add)) {
                if (
                    block.timestamp - willStorage.getInactivityDays(add) >
                    transactionOracle.getLatestTransactionTimestamp(add)
                ) {
                    executeWill(add);
                }
            }
        }
    }
}
