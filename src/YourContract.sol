//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
// import "hardhat/console.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */

contract YourContract {
    address public owner;
    bool public isLotteryActive;
    uint256 public lotteryRound;
    mapping(address => mapping(uint256 => uint256)) public contributions;
    mapping(uint256 => address[]) public participantsByRound;
    uint256 public totalContributions;

    constructor(address _owner) {
        owner = _owner;
        isLotteryActive = false;
        lotteryRound = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function startLottery() public onlyOwner {
        require(!isLotteryActive, "Lottery is already active.");
        isLotteryActive = true;
        totalContributions = 0;
        lotteryRound++;
    }

    function contribute() public payable {
        require(isLotteryActive, "Lottery is not active.");
        if (contributions[msg.sender][lotteryRound] == 0) {
            participantsByRound[lotteryRound].push(msg.sender);
        }
        contributions[msg.sender][lotteryRound] += msg.value;
        totalContributions += msg.value;
    }

    function endLottery() public onlyOwner {
        require(isLotteryActive, "Lottery is not active.");
        isLotteryActive = false;

        uint256 numberOfParticipants = participantsByRound[lotteryRound].length;
        require(numberOfParticipants > 0, "No participants in this round.");

        uint256 totalTickets = 0;
        uint256[] memory ticketsPerParticipant = new uint256[](
            numberOfParticipants
        );

        for (uint i = 0; i < numberOfParticipants; i++) {
            address participant = participantsByRound[lotteryRound][i];
            // 0.01 ETH for 1 ticket
            ticketsPerParticipant[i] =
                contributions[participant][lotteryRound] /
                1e16; // 1e16 wei = 0.01 ETH
            totalTickets += ticketsPerParticipant[i];
        }

        uint256 winningTicket = (uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        ) % totalTickets) + 1;
        uint256 ticketCount = 0;
        address winner;

        for (uint i = 0; i < numberOfParticipants; i++) {
            ticketCount += ticketsPerParticipant[i];
            if (winningTicket <= ticketCount) {
                winner = participantsByRound[lotteryRound][i];
                break;
            }
        }

        payable(winner).transfer(address(this).balance);
    }

    function getParticipants()
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        address[] memory participants = participantsByRound[lotteryRound];
        uint256[] memory contribs = new uint256[](participants.length);

        for (uint i = 0; i < participants.length; i++) {
            contribs[i] = contributions[participants[i]][lotteryRound];
        }

        return (participants, contribs);
    }
}
