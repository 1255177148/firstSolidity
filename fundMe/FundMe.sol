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
    uint256 MINNUM_VALUE = 100 * 10**18; //每笔最低限制100美元
    AggregatorV3Interface internal dataFeed;

    constructor() {
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

    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINNUM_VALUE, unicode"最小额度为100美元");
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        uint256 conversionRate = 10**8; //美元每eth，精确度是10的8次方
        uint256 dolarAmount = (ethPrice / conversionRate) * ethAmount;
        return dolarAmount;
    }
}
