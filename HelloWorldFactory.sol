// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {HelloWorld} from "HelloWorld.sol";

contract HelloWorldFactory {
    HelloWorld helloWorld;
    HelloWorld[] hws;

    function createHelloWorld() public {
        helloWorld = new HelloWorld();
        hws.push(helloWorld);
    }

    function getHelloWorldByIndex(uint256 _index)
        public
        view
        returns (HelloWorld)
    {
        return hws[_index];
    }

    function callSayHello(uint256 _index, uint256 _id)
        public
        view
        returns (string memory)
    {
        return hws[_index].sayHello(_id);
    }

    function callSetHello(uint256 _index, string memory newStr, uint256 _id) public {
        hws[_index].setHelloWorld(newStr, _id);
    }

    
}
