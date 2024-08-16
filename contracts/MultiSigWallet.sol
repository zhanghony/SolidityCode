// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title 多签名钱包合约
/// @author zhanghony
/// @notice 多签名钱包的使用场景
/// @dev 1.部署  ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","0x70997970C51812dc3A010C7d01b50e0d17dc79C8","0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC","0x90F79bf6EB2c4f870365E785982E1f101E93b906","0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"]
/// amount 1
/// 2 submit  合约地址 0x3155755b79aA083bd953911C92705B7aA82a18F9  1 0x3155755b79aA083bd953911C92705B7aA82a18F9
/// 3 approve 0  
/// 4 切换账号 approve 0
/// 向合约打1 ether
/// 5 execute 0

contract MultiSigWallet {
    /// @notice 当以太币存⼊钱包时触发
    /// @dev Explain to a developer any extra details
    /// @param sender a parameter just like in doxygen (must be followed by parameter name)
    /// @param amount a parameter just like in doxygen (must be followed by parameter name)
    event Deposit(address indexed sender, uint256 amount);
    /// @notice 当提交交易时触发
    /// @dev Explain to a developer any extra details
    /// @param txId a parameter just like in doxygen (must be followed by parameter name)
    event Submit(uint256 indexed txId);
    /// @notice 当交易被批准时触发
    /// @dev Explain to a developer any extra details
    /// @param owner a parameter just like in doxygen (must be followed by parameter name)
    /// @param txId a parameter just like in doxygen (must be followed by parameter name)
    event Approve(address indexed owner, uint256 indexed txId);

    /// @notice 当交易被执⾏时触发
    /// @dev Explain to a developer any extra details
    /// @param txId a parameter just like in doxygen (must be followed by parameter name)
    event Execute(uint256 indexed txId);
    /// @notice 当批准被撤销时触发
    /// @dev Explain to a developer any extra details
    /// @param owner a parameter just like in doxygen (must be followed by parameter name)
    /// @param txId a parameter just like in doxygen (must be followed by parameter name)
    event Revoke(address indexed owner, uint256 indexed txId);

    /// @notice 包含交易⽬标地址、发送⾦额、交易数据和执⾏状态
    /// @dev Explain to a developer any extra details
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }
    /// @notice 存储所有者地址的数组
    address[] public owners;
    /// @notice 检查某地址是否为所有者的映射
    mapping(address => bool) public isOwner;
    /// @notice 执⾏交易所需的最少批准数
    uint256 public required;
    /// @notice 存储所有交易的数组
    Transaction[] public transactions;
    /// @notice 存储每个交易被每个所有者批准情况的映射
    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    //确保交易存在
    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }
    //未被批准
    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }
    //未被执⾏
    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    /// @notice 初始化所有者数组和所需的批准数
    /// @dev Explain to a developer any extra details
    /// @param _owners a parameter just like in doxygen (must be followed by parameter name)
    /// @param _required 执⾏交易所需的最少批准数
    constructor(address[] memory _owners, uint256 _required)   {
        require(_owners.length > 0, " owners require");
        require(_required > 0 && _required <= _owners.length,"invalied required number ");

        for (uint256 i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    /// @notice 接收以太币并触发 Deposit 事件
    /// @dev Explain to a developer any extra details
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    ///提交新交易
    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );
        emit Submit(transactions.length - 1);
    }

    /// @notice 批准交易
    /// @dev Explain to a developer any extra details
    /// @param _txId a parameter just like in doxygen (must be followed by parameter name)
    function approve(
        uint256 _txId
    ) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(
        uint256 _txId
    ) private view returns (uint256 count) {
        for (uint256 i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    function call(address   _to) external payable  {
        (bool isSuccess, /* memory data */ ) = payable(_to).call{value: msg.value}("");
        require(isSuccess, "Failure! Ether not send.");
    }

    //执⾏已批准的交易
    function execute(
        uint256 _txId
    ) external txExists(_txId) notExecuted(_txId) {
        require(_getApprovalCount(_txId) >= required, "approvals < required");
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;
        (bool success, ) = payable(transaction.to).call{value: transaction.value}(
            ""
        );
        require(success, "tx failed");
        emit Execute(_txId);
    }

    //撤销已批准的交易
    function revoke(
        uint256 _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "tx not approved ");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}
