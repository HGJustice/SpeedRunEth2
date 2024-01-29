// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	mapping(address => uint256) public balances;
	uint256 public constant threshold = 1 ether;
	uint256 public deadline = block.timestamp + 30 seconds;
	bool openforwithdraw = false;
	event Stake(address indexed staker, uint256);

	modifier notCompleted() {
		require(!exampleExternalContract.completed(), "completed");
		_;
	}

	function stake() public payable {
		require(block.timestamp < deadline, "Deadline has passed");
		balances[msg.sender] += msg.value;
		emit Stake(msg.sender, msg.value);
	}

	function balance() public view returns (uint256) {
		return balances[msg.sender];
	}

	function execute() public notCompleted {
		if (address(this).balance >= threshold) {
			exampleExternalContract.complete{ value: address(this).balance }();
		} else {
			openforwithdraw = true;
		}
	}

	function withdraw() external notCompleted {
		require(address(this).balance < threshold, "Threshhold met");

		require(openforwithdraw, "cannot withdraw");
		uint256 amount = balances[msg.sender];
		balances[msg.sender] = 0;
		(bool sent, ) = payable(msg.sender).call{ value: amount }("");
		require(sent, "payment failed");
	}

	function timeLeft() public view returns (uint256) {
		if (block.timestamp >= deadline) {
			return 0;
		}

		return deadline - block.timestamp;
	}

	receive() external payable {
		stake();
	}
}
