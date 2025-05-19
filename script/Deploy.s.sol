// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {MyToken} from "../src/MyToken.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployMyToken is Script {
    function run() external {
        vm.startBroadcast();

        MyToken implementation = new MyToken();

        bytes memory initData = abi.encodeCall(
            MyToken.initialize,
            ("MyToken", "MTK")
        );

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );

        console.log("Proxy deployed at:", address(proxy));
        console.log("Logic (implementation) at:", address(implementation));

        vm.stopBroadcast();
    }
}
