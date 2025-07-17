// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 转账回调接口
interface ITokensRecipient {
    function tokensReceived(
        bytes calldata data
    ) external;
}

contract A {
    string public res;
    string public res1;
    uint256 public id;
    function transferWithCallback(
        address recipient,
        bytes calldata data
    ) external returns (bool) {
        id = abi.decode(data,(uint256));
        try
            ITokensRecipient(recipient).tokensReceived(data)
        {} catch (bytes memory reason) {
            res = string(reason);
            //revert("CallbackFailed");
        }
        return true;   
    }    
}

contract B{
    string public rdata;
    uint256 public id;
    function tokensReceived(bytes calldata data) external{
        rdata = string(data);
        id = abi.decode(data,(uint256));
    }
}
