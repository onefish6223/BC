// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 扩展的ERC20接口，包含transferWithCallback
interface IERC20WithCallback is IERC20 {
    function transferWithCallback(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract TokenBank {
    // 存储的代币合约地址
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
    
    // 标准存款函数 需要先 approve
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
}

contract TokenBankV2 is TokenBank{
    // 构造函数，传入要存储的代币合约地址
    constructor(address _tokenAddress) TokenBank(_tokenAddress){
        token = IERC20WithCallback(_tokenAddress);
    }

    // 通过transferWithCallback直接存款
    function tokensReceived(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external {
        // 确保调用者是代币合约
        require(msg.sender == address(token), "Only token contract can call this");
        
        // 确保接收者是本合约
        require(recipient == address(this), "Invalid recipient");
        
        // 更新用户余额
        balances[sender] += amount;
        
        emit Deposit(sender, amount);
    }
}
