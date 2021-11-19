// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable{

  YourToken yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  //ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    require(msg.value > 0, "Send ETH to buy some tokens");
    uint numberOfTokens = msg.value * 100;

    require(yourToken.balanceOf(address(this)) >= numberOfTokens, "Vendor contract has not enough tokens in its balance");
    (bool sent) = yourToken.transfer(msg.sender, numberOfTokens);
    require(sent, "Failed to transfer token to user");

    emit BuyTokens(msg.sender, msg.value, numberOfTokens);
  }

  //ToDo: create a sellTokens() function:

  //ToDo: create a withdraw() function that lets the owner, you can 
  //use the Ownable.sol import above:
  function withdraw() public onlyOwner {
    require(address(this).balance > 0);

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to transfer balance to owner");
  }
}
