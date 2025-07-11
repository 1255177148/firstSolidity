// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; //eth和美元转换接口

/*
 写一个众筹产品的智能合约
 1、创建一个收款函数；
 2、记录投资人并查看；
 3、在锁定期内，达到目标值，生产商可以提款；
 4、在锁定期内，没有达到目标值，投资人在锁定期以后退款
*/
contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    uint256 constant MINNUM_VALUE = 100 * 10**18; //每笔最低限制100美元
    uint256 constant TARGET_VALUE = 1000 * 10**18; // 众筹的目标值
    AggregatorV3Interface internal dataFeed;
    address owner; //合约的拥有者，也就是可以提款的人

    constructor() {
        owner = msg.sender; //获取部署合约的地址
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    /*
     * @notice 众筹函数。可以用eth购买商品，然后转入我们账户，就可以收款了
     */
    function fund() external payable {
        require(
            convertEthToUsd(msg.value) >= MINNUM_VALUE,
            unicode"最小额度为100美元"
        );
        addressToAmountFunded[msg.sender] += msg.value;
    }

    /*
     * 将eth转为usd
     */
    function convertEthToUsd(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        uint256 conversionRate = 10**8; //美元每eth，精确度是10的8次方
        uint256 dolarAmount = (ethPrice / conversionRate) * ethAmount;
        return dolarAmount;
    }

    /*
     * 提取众筹金额
     */
    function getFund() external {
        require(owner == msg.sender, unicode"无权提取");
        require(
            convertEthToUsd(address(this).balance) >= MINNUM_VALUE,
            unicode"没有达到目标额度，不能提取"
        );
        /*
        三种交易金额的方法
        */
        // 1、transfer
        payable(owner).transfer(address(this).balance); //将usd转给owner
    }

    function transferOwnerShip(address newOwner) public {
        require(msg.sender == owner, unicode"无权调用此函数");
        owner = newOwner;
    }
}
