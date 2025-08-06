// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBank {
    function autoAssetTranfer() external;
}

//0x2Bf7e3D94292E9D313F9c79735ac61ECd17DE118
contract AutoAssetTranferByCL is AutomationCompatibleInterface {
    address public constant token = 0xD67ee2ff8F2B5FFC0B7B8689b9e1626B70452C44;
    address public constant bank = 0x2EBCf91ee8FCFBaC295e56976Fb5E03B77383DFC;

    constructor() {
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
