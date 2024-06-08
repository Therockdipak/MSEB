// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "hardhat/console.sol";

contract MSEB {
   address public owner;
   uint256 public ratePerUnit;

   struct Meter {
     address owner;
     uint256 meterId;
     uint256 currentReading;
     bool isRegistered;
   }

   mapping(uint256 => Meter) public meters;
   mapping(address => uint256) public balances;

   event meterRegistered(address indexed owner, uint256 indexed meterId);
   event readigSubbmitted(uint256 indexed meterId, uint256 currentReading);
   event billPayed(uint256 indexed meterId, uint256 amount);

   modifier onlyOwner() {
    require(owner == msg.sender,"you are not the owner");
    _;
   }

   constructor(uint256 _ratePerUnit) {
       ratePerUnit = _ratePerUnit;
       owner = msg.sender;
   }

   function registerYourMeter(uint256 _id) external {
      require(!meters[_id].isRegistered,"already registered");
      meters[_id] = Meter(msg.sender,_id,0,true);
      emit meterRegistered(msg.sender, _id);
   }

   function  submitReading(uint256 _id, uint256 _reading) external {
      Meter storage meter = meters[_id];
      require(meter.isRegistered,"meter is not registered");
      require(_reading >= meter.currentReading,"Invalid reading");

      uint256 consumption = _reading - meter.currentReading;
      uint256 amount = consumption * ratePerUnit;

      balances[owner] += amount;
      meter.currentReading += _reading;
      emit readigSubbmitted(_id, _reading);
   }

   function payBills(uint256 _meterId) external payable {
       Meter storage meter = meters[_meterId];
       require(meter.isRegistered,"Meter is not registered");
       uint256 amountToPay = meter.currentReading * ratePerUnit;
       require(msg.value >= amountToPay,"insufficient payment");
       console.log("Amount to pay: ", amountToPay);
       payable(owner).transfer(amountToPay);

       uint256 excessAmount = msg.value -  amountToPay;
       if(excessAmount > 0) {
         payable(msg.sender).transfer(excessAmount);
       }
       meter.currentReading = 0; //reset current reading after payment
       emit billPayed(_meterId, amountToPay);
   }
}