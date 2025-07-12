// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
1 存款功能：
    用户可直接向合约地址转账（通过 MetaMask 等钱包）
    使用 receive() 函数处理原生以太币转账
    自动记录每个地址的存款余额
2 存款排名：
    维护一个 topDepositors 数组存储前三名
    每次存款自动更新排名
    相同地址多次存款会累积金额并更新排名
3 提款功能：
    仅管理员可调用 withdraw() 方法
    提取合约全部余额到管理员地址
    包含资金转移的安全检查
4 辅助功能：
    balances 映射可查询任意地址的存款余额
    topDepositors 数组可查询前三名存款信息
    getContractBalance() 查看合约总余额
*/
contract Bank {
    address public admin;
    mapping(address => uint256) public balances;
    
    struct Depositor {
        address addr;
        uint256 amount;
    }
    
    Depositor[3] public topDepositors;
    
    event Deposit(address indexed depositor, uint256 amount);
    event Withdraw(address indexed admin, uint256 amount);
    
    constructor() {
        admin = msg.sender;
    }
    
    // 接收以太币存款
    receive() external payable {
        _recordDeposit(msg.sender, msg.value);
    }
    fallback() external payable {
        //_recordDeposit(msg.sender, msg.value);
    }
    //虚拟环境测试用
    function recvETH() public payable {
        _recordDeposit(msg.sender, msg.value);
    }
    
    // 记录存款并更新排名
    function _recordDeposit(address depositor, uint256 amount) private {
        require(amount > 0, "Deposit amount must be greater than 0");
        
        // 更新存款余额
        balances[depositor] += amount;
        emit Deposit(depositor, amount);
        
        // 更新前三名
        _updateTopDepositors(depositor, balances[depositor]);
    }
    
    // 更新前三存款人
    function _updateTopDepositors(address depositor, uint256 newBalance) private {
        uint256 insertIndex = 3; // 默认不插入
        
        // 检查是否已在前三名中
        for (uint i = 0; i < 3; i++) {
            if (topDepositors[i].addr == depositor) {
                // 更新现有存款人金额
                topDepositors[i].amount = newBalance;
                insertIndex = i; // 标记需要重新排序的位置
                break;
            }
        }
        
        // 如果是新存款人且金额足够大
        if (insertIndex == 3) {
            // 找到应该插入的位置
            for (uint i = 0; i < 3; i++) {
                if (newBalance > topDepositors[i].amount) {
                    insertIndex = i;
                    break;
                }
            }
        }
        
        // 如果需要插入新记录
        if (insertIndex < 3) {
            // 创建新存款人记录
            Depositor memory newDepositor = Depositor({
                addr: depositor,
                amount: newBalance
            });
            
            // 向后移动较低排名的记录
            for (uint j = 2; j > insertIndex; j--) {
                topDepositors[j] = topDepositors[j-1];
            }
            
            // 插入新记录
            topDepositors[insertIndex] = newDepositor;
        }
    }
    
    // 管理员提取资金
    function withdraw() external {
        require(msg.sender == admin, "Only admin can withdraw");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        (bool sent, ) = admin.call{value: balance}("");
        require(sent, "Failed to send Ether");
        
        emit Withdraw(admin, balance);
    }
    
    // 获取合约余额
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}