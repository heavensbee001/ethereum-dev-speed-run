// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint deadline = 1636803680;
  uint threshold = 1 ether;

  event Stake(address, uint256);

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public {
    require(deadline < block.timestamp, "deadline not reached yet");

    exampleExternalContract.complete{value: address(this).balance}();
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public {
    require(threshold > address(this).balance, "threshold has been reached");
    uint userBalance = balances[msg.sender];

    delete balances[msg.sender];
    msg.sender.transfer(userBalance);
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


}
