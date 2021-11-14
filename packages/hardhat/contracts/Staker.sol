// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  // uint deadline = 1636803680;
  uint deadline = block.timestamp + 30 seconds;
  uint threshold = 1 ether;
  bool openForWithdraw = false;

  event Stake(address, uint256);

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process is completed");
    _;
  }
  
  modifier deadlineHasToBeReached(bool hasToBeReached) {
    if (hasToBeReached) {
      require(deadline < block.timestamp, "deadline has to be reached");
    } else {
      require(deadline >= block.timestamp, "deadline was already reached");
    }
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable deadlineHasToBeReached(false) {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public stakeNotCompleted deadlineHasToBeReached(true){
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }

  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public deadlineHasToBeReached(false) {
    require(threshold > address(this).balance, "threshold has been reached");
    require(openForWithdraw, "withdraw not available");
    uint userBalance = balances[msg.sender];

    delete balances[msg.sender];
    msg.sender.transfer(userBalance);
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

}
