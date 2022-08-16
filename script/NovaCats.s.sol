// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NovaCats.sol";

contract NovaCatsScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        NovaCats token = new NovaCats();

        vm.stopBroadcast();
    }
}
