// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBank {
    function autoAssetTranfer() external;
}

contract AutoAssetTranferByCL is AutomationCompatibleInterface {
    address public immutable token;
    address public immutable bank;

    constructor(address _token, address _bank) {
        token = _token;
        bank = _bank;
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded , bytes memory){
        if(IERC20(token).balanceOf(bank) > 10e18) {
            upkeepNeeded = true;
        }
    }

    function performUpkeep(bytes calldata) external override {
        if(IERC20(token).balanceOf(bank) > 10e18) {
            IBank(bank).autoAssetTranfer();
        }
    }
}
