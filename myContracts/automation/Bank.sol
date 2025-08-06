// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Bank {
    // 存储的代币合约地址
    //0xD67ee2ff8F2B5FFC0B7B8689b9e1626B70452C44
    IERC20 public token;
    
    // 记录每个地址的存款余额
    mapping(address => uint256) public balances;
    
    // 事件：存款
    event Deposit(address indexed user, uint256 amount);
    
    // 事件：取款
    event Withdraw(address indexed user, uint256 amount);
    
    // 构造函数，传入要存储的代币合约地址
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }
    
    // 存款函数
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        // 将代币从用户转移到合约
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
        
        // 更新用户余额
        balances[msg.sender] += amount;
        
        emit Deposit(msg.sender, amount);
    }
    
    // 取款函数
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // 更新用户余额
        balances[msg.sender] -= amount;
        
        // 将代币从合约转移回用户
        bool success = token.transfer(msg.sender, amount);
        require(success, "Transfer failed");
        
        emit Withdraw(msg.sender, amount);
    }
    
    // 查询合约中的代币总余额
    function getBankBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    // 查询用户的存款余额
    function getUserBalance(address user) external view returns (uint256) {
        return balances[user];
    }
    //自动转移资产 by chainlink-automation，当代币的数量操作 
    function autoAssetTranfer() external {
        uint256 balance = token.balanceOf(address(this));
        if( balance > 10e18){
            bool success = token.transfer(address(0x94Ad6B903Ef1fC481D0D8c1f8f9FC36d752AC9A1), balance - 10e18);
            require(success, "Transfer failed");
        }
    }
}