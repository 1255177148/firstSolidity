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
    address[] keys; // 存储addressToAmountFunded的key
    bool public fundMeCompleted = false; //是否提款成功
    uint256 constant MINNUM_VALUE = 100 * 10**18; //每笔最低限制100美元
    uint256 constant TARGET_VALUE = 300 * 10**18; // 众筹的目标值
    AggregatorV3Interface internal dataFeed;
    address owner; //合约的拥有者，也就是可以提款的人
    uint256 deploymentTimestamp; // 合约部署时的时间戳
    uint256 lockTime; // 锁定众筹的时间,单位为秒
    address erc20Addr;

    constructor(uint256 _lockTime) {
        owner = msg.sender; //获取部署合约的地址
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
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

    function getFundersToAmount(address addr) public view returns (uint256) {
        return addressToAmountFunded[addr];
    }

    function setFunderToAmount(address addr, uint256 amount) public {
        require(erc20Addr == msg.sender, unicode"无权调用此函数");
        addressToAmountFunded[addr] = amount;
    }

    function setErc20Addr(address addr) public onlyOwner {
        erc20Addr = addr;
    }

    /*
     * @notice 众筹函数。可以用eth购买商品，然后转入我们账户，就可以收款了
     */
    function fund() external payable {
        require(
            block.timestamp < deploymentTimestamp + lockTime,
            unicode"众筹窗口已关闭"
        );
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
    function getFund() external windowOpen onlyOwner{
        require(
            convertEthToUsd(address(this).balance) >= TARGET_VALUE,
            unicode"没有达到目标额度，不能提取"
        );
        /*
        三种交易金额的方法
        */
        // 1、transfer，如果失败会回退交易
        // payable(owner).transfer(address(this).balance); //将usd转给owner
        // 2、send，会返回一个boolean，交易成功为true，失败为false
        // bool successFlag = payable(owner).send(address(this).balance);
        // 3、call,交易的时候可以加上信息，里面用了transfer，然后又加了data，同时会返回一个bool表示是否交易成功
        bool successFlag;
        (successFlag, ) = payable(owner).call{value: address(this).balance}("");
        require(successFlag, unicode"交易失败");
        fundMeCompleted = true; // 标记已提款成功
    }

    /*
    退款操作
    */
    function refund() external {
        require(!fundMeCompleted, unicode"生产商已提款，不能退款");
        uint256 amountToRefund = addressToAmountFunded[msg.sender];
        require(amountToRefund > 0, unicode"没有众筹过");
        require(
            convertEthToUsd(address(this).balance) < TARGET_VALUE,
            unicode"达到目标额度，不能退款"
        );
        bool successFlag;
        (successFlag, ) = payable(msg.sender).call{value: amountToRefund}("");
        require(successFlag, unicode"交易失败");
        addressToAmountFunded[msg.sender] = 0; //清空众筹金额
    }

    function transferOwnerShip(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    /*
     * 修改器，类似于切面
     */
    modifier windowOpen() {
        require(
            block.timestamp >= deploymentTimestamp + lockTime,
            unicode"正在众筹期间，不能交易"
        );
        _; //这里类似于AOP，切面，下划线表示其它的代码在上面这行之后运行，也就是此修改器在开头就运行
    }

    modifier onlyOwner() {
        require(owner == msg.sender, unicode"无权调用此函数");
        _;
    }
}
