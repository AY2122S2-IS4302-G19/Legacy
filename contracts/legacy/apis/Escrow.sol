// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "../../legacytoken/SafeMath.sol";
import "../../legacytoken/LegacyToken.sol";
import "../../legacytoken/ERC20.sol";

/*
 * This contract holds the wallet of ether and LT until it is withdrawn
 * by the will writer or the will is executed by the trigger. This contract
 * will not hold or generate interest.
 */
contract Escrow {
    using SafeMath for uint256;

    LegacyToken lt;

    uint256 gasPrice;
    mapping(address => uint256) ltAmt;
    mapping(address => uint256) etherAmt;

    event etherBal(uint256,uint256);

    constructor(LegacyToken _lt) {
        gasPrice = 2300;
        lt = _lt;
    }

    fallback() external payable {
        etherAmt[msg.sender] = etherAmt[msg.sender].add(msg.value);
    }

    receive() external payable {
        etherAmt[msg.sender] = etherAmt[msg.sender].add(msg.value);
    }

    function getEtherBal(address add) public view returns (uint256) {
        if (add == address(0)) {
            return etherAmt[msg.sender];
        } else {
            return etherAmt[add];
        }
    }

    function getLTBal(address add) public returns (uint256) {
        if (add == address(0)) {
            return lt.checkLTCredit(msg.sender);
        } else {
            return lt.checkLTCredit(add);
        }
    }

    function depositEther(address to) public payable {
        etherAmt[to] = etherAmt[to].add(msg.value);
    }

    function depositLT(address to, uint256 amt) public {
        require(lt.checkLTCredit(to) > amt);
        ltAmt[to] = ltAmt[to].add(amt);
    }

    function transferEther(address from, address to, uint256 amt) public {
        // emit etherBal(etherAmt[from], amt);
        // require(etherAmt[from] >= amt,'Not enough ether');
        // etherAmt[to] = etherAmt[to].add(amt);
        // etherAmt[from] = etherAmt[from].sub(amt);
    }

    function transferLT(address from, address to, uint256 amt) public {
        require(lt.checkLTCredit(to) > amt);
        lt.transferToken(from, to, amt);
        ltAmt[from] = ltAmt[from].sub(amt);
        ltAmt[to] = ltAmt[to].add(amt);
    }

    function withdrawEther() public payable {
        require(msg.value >= gasPrice);
        payable(tx.origin).transfer(etherAmt[tx.origin]);
        etherAmt[tx.origin] = 0;
    }
    
    function withdrawLT() public payable {
        require(msg.value >= gasPrice);
        lt.sellLegacyToken(ltAmt[tx.origin]);
        ltAmt[tx.origin] = 0;
    }

}
