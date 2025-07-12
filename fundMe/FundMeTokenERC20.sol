// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundMeTokenERC20 is ERC20 {
    FundMe fundMe;
    mapping (address => bool) mintFlags;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address fundMeAddr
    ) ERC20(tokenName, tokenSymbol) {
        fundMe = FundMe(fundMeAddr); // 类型转换，把fundMeAddr合约地址转换为FundMe合约类型的地址
    }

    // mint函数，铸造通证
    function mint() public {
        require(fundMe.fundMeCompleted(), unicode"众筹还未完成");
        require(
            fundMe.getFundersToAmount(msg.sender) > 0,
            unicode"没有众筹，不能生成通证"
        );
        _mint(msg.sender, fundMe.getFundersToAmount(msg.sender));
        fundMe.setFunderToAmount(msg.sender, 0);
        mintFlags[msg.sender] = true;
    }

    /*
     * 提取通证
     */
    function claim() public {
        require(mintFlags[msg.sender], unicode"没有通证，不能提取");
        // 提取通证，这里先没有操作

        // 清空通证
        _burn(msg.sender, fundMe.getFundersToAmount(msg.sender));
    }
}
