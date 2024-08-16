// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/toSuiBridge.sol";

contract DeployToSuiBridge is Script {
    function run() external {
        vm.startBroadcast();

        toSuiBridge bridge = new toSuiBridge();

        console.log("toSuiBridge deployed to:", address(bridge));

        vm.stopBroadcast();
    }
}
