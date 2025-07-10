// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

/*
 写一个众筹产品的智能合约
 1、创建一个收款函数；
 2、记录投资人并查看；
 3、在锁定期内，达到目标值，生产商可以提款；
 4、在锁定期内，没有达到目标值，投资人在锁定期以后退款
*/
contract FundMe{
    mapping (address => uint256) public addressToAmountFunded;
    uint256 MINNUM_VALUE = 100 * 10 ** 18;//每笔最低限制100美元
    
}