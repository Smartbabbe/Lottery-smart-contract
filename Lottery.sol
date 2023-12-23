// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    event PlayerEntered(address indexed player);
    event WinnerSelected(address indexed winner);

    address public organizer;
    address[] public lotteryPlayers;
    uint public lotteryWinner;

     mapping(address => bool) private hasEntered;

    constructor() {
        organizer = msg.sender;
    }

    function playLottery() external payable {
        require(msg.sender != organizer, "Organizers cannot participate in the lottery");
        require(!hasEntered[msg.sender], "Address has already entered the lottery");
        require(msg.value > 0.001 ether, "Minimum entry fee is 0.001 ether");

        lotteryPlayers.push(msg.sender);
        hasEntered[msg.sender] = true;

        emit PlayerEntered(msg.sender);
    }

    function pickWinner() external {
        require(msg.sender == organizer, "Only organizers can pick winners");
        require(lotteryPlayers.length > 0, "No players in the lottery");

       uint index = uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, lotteryPlayers))) % lotteryPlayers.length;
        address winner = lotteryPlayers[index];
        lotteryWinner = index;

        payable(winner).transfer(address(this).balance);

        lotteryPlayers = new address[](0);

        emit WinnerSelected(winner);
    }

    function getPlayers() external view returns (address[] memory) {
        return lotteryPlayers;
    }
}