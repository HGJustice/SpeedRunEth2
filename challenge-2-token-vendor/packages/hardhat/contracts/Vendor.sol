pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
	event SoldTokens(
		address buyer,
		uint256 amountOfEth,
		uint256 amountOfTokens
	);

	YourToken public yourToken;

	uint256 public constant tokensPerEth = 100;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() external payable {
		require(msg.value > 0, "please sent more eth");
		uint256 tokensBought = msg.value * tokensPerEth;
		require(
			yourToken.balanceOf(address(this)) >= tokensBought,
			"vendor doesnt have enough tokens"
		);

		bool sent = yourToken.transfer(payable(msg.sender), tokensBought);
		require(sent, "payment failed");
		emit BuyTokens(msg.sender, msg.value, tokensBought);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH

	function withdraw() external onlyOwner {
		uint256 balance = address(this).balance;
		require(balance > 0, "no funds to send boss");

		(bool sent, ) = payable(msg.sender).call{ value: balance }("");
		require(sent, "Payment failed");
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 amount) external {
		require(amount > 0, "you must buy more then 0 tokens");
		uint256 userGoldBalance = yourToken.balanceOf(msg.sender);
		require(
			userGoldBalance >= amount,
			"user doesnt have enough coint to sell"
		);

		uint256 amountOfEth = amount / tokensPerEth;

		bool sent = yourToken.transferFrom(msg.sender, address(this), amount);
		require(sent, "faailed to send tokens");

		(bool ethSent, ) = payable(msg.sender).call{ value: amountOfEth }("");
		require(ethSent, "eth payment failed");
		emit SoldTokens(msg.sender, amountOfEth, amount);
	}
}
