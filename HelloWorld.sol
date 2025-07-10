// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract HelloWorld {
    string strVal = "Hello World";

    /**
     * 使用结构体来保存信息
     */
    struct Info {
        string phrase; // 短语
        uint256 id;
        address addr;
    }

    // Info[] infos;//使用数组持久化数据
    mapping(uint256 => Info) infoMap; // 使用Map持久化数据

    function sayHello(uint256 _id) public view returns (string memory) {
        // for (uint256 i = 0;i < infos.length;i++){
        //     if (infos[i].id == _id){
        //         return addInfo(infos[i].phrase);
        //     }
        // }
        if (infoMap[_id].addr != address(0)) {
            return addInfo(infoMap[_id].phrase);
        } else {
            return addInfo(strVal);
        }
    }

    function setHelloWorld(string memory newStr, uint256 _id) public {
        Info memory info = Info(newStr, _id, msg.sender);
        // infos.push(info);
        infoMap[_id] = info;
    }

    function addInfo(string memory message)
        internal
        pure
        returns (string memory)
    {
        return string.concat(message, ", form elvis's contract.");
    }
}
