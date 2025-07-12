// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
编写 IBank 接口及BigBank 合约，使其满足 Bank 实现 IBank， BigBank 继承自 Bank ， 
同时 BigBank 有附加要求：
	要求存款金额 >0.001 ether（用modifier权限控制）
	BigBank 合约支持转移管理员
编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。
BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，然后
Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。
*/

/*
1 编写 IBank 接口
*/
interface IBank {
    struct Depositor {
        address addr;
        uint256 amount;
    }
    //管理员地址
    //function admin() external view returns (address);
    //根据地址查询余额
    function balances(address addr) external view returns (uint256);
    //function topDepositors(uint i) external view returns (Depositor);
    // 虚拟环境测试用
    function recvETH() external payable;
    // 管理员提取资金
    function withdraw() external payable;
    // 获取合约余额
    function getContractBalance() external view returns (uint256);
}

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
contract Bank is IBank{
    address payable public admin;
    mapping(address => uint256) public balances;
    Depositor[3] public topDepositors;
    
    event Deposit(address indexed depositor, uint256 amount);
    event Withdraw(address indexed admin, uint256 amount);
    
    constructor() {
        admin = payable (msg.sender);
    }
    
    // 接收以太币存款
    receive() external payable {
        _recordDeposit(msg.sender, msg.value);
    }
    fallback() external payable {
        //_recordDeposit(msg.sender, msg.value);
    }
    // 虚拟环境测试用
    function recvETH() external payable virtual {
        _recordDeposit(msg.sender, msg.value);
    }
    
    // 记录存款并更新排名
    function _recordDeposit(address depositor, uint256 amount) internal   {
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
    function withdraw() external payable{
        require(msg.sender == admin, "Only admin can withdraw");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        //(bool sent, ) = admin.call{value: balance}("");
        admin.transfer(balance);
        //require(sent, "Failed to send Ether");
        
        emit Withdraw(admin, balance);
    }
    
    // 获取合约余额
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/*
1 编写BigBank合约
2 继承Bank
3 要求存款金额 >0.001 ether（用modifier权限控制）
4 BigBank 合约支持转移管理员
*/
contract BigBank is Bank{
    modifier depositCtl(){
        require(msg.value > 0.001 * 10**18, "Deposit amount must be greater than 0.001 ether!");
        _;
    }
    // 虚拟环境测试用
    function recvETH() external override payable depositCtl {
        super._recordDeposit(msg.sender, msg.value);
    }
    //转移管理员权限
    function changeAdmin(address payable newAdmin) public {
        require(msg.sender == admin, "Not Admin!!! Just Admin can do it!");
        admin = newAdmin;
    }
}

/*
1 编写一个 Admin 合约
2 Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。
3 BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，
4 然后Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。
*/
contract Admin{
    address public owner;
    //充点钱 要不然取不出来Bigbank的钱
    //function recvETH() external payable virtual {
    //}

    constructor() {
        owner = msg.sender;
    }
    // 接收以太币的回退函数，没有这个函数是不能将BigBank里的钱提取过来的
    receive() external payable {
        
    }
    function adminWithdraw(IBank bank) public  {
        require(msg.sender == owner, "Not owner!!! Just owner can do it!");
        bank.withdraw();
    }
}
