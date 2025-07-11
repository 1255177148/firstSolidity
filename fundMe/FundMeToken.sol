// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract FundMeToken {
    // 1、通证的名称
    string public tokenName;
    // 2、通证的简称
    string public tokenNick;
    // 3、通证的发行数量
    uint256 public totalCirculation;
    // 4、owner，合约的拥有者地址
    address public owner;
    // 5、balance，address => uint256，记录每个地址通证的数量
    mapping(address => uint256) public balances;

    constructor(string memory _tokenName, string memory _tokenNick) {
        tokenName = _tokenName;
        tokenNick = _tokenNick;
        owner = msg.sender;
    }

    // mint函数，铸造通证
    function mint(uint256 _amountToMint) public {
        balances[msg.sender] += _amountToMint;
        totalCirculation += _amountToMint;
    }

    // transfer通证
    function transfer(address _target, uint256 _amount) public {
        require(balances[msg.sender] >= _amount, unicode"没有足够的通证");
        balances[msg.sender] -= _amount;
        balances[_target] += _amount;
    }

    // balanceInfo,查看某一个地址的通证数量
    function balanceOf(address addr) public view returns (uint256) {
        return balances[addr];
    }
}
