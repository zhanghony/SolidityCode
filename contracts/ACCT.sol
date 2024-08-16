// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



// interface IERC20 {
//     function totalSupply() external view returns (uint256);

//     function balanceOf(address account) external view returns (uint256);

//     function transfer(address recipient, uint256 amount)
//         external
//         returns (bool);

//     function allowance(address owner, address spender)
//         external
//         view
//         returns (uint256);

//     function approve(address spender, uint256 amount) external returns (bool);

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) external returns (bool);

//     event Transfer(address indexed from, address indexed to, uint256 value);

//     /// @notice 从一个地址许可转移token到另一个地址的细节,可以被用来跟踪地址余额和配额的变更，而无需查询区块链。
//     /// @dev zhagnhony
//     /// @param owner a parameter just like in doxygen (must be followed by parameter name)
//     /// @param spender to an end user what this does
//     /// @param value to a developer any extra details
//     event Approval(
//         address indexed owner,
//         address indexed spender,
//         uint256 value
//     );
// }

/**
 * Token合约 
 * 
 * approve()和transferFrom()是两个方程，它们使用一个两步过程，可以解决上面的问题。
 * 第一步，一个token持有者给另一个地址（常常是一个智能合约）批准从本地转出一个最大特定数量的token，也就是所谓的配额（allowence）。
 * Token持有者使用approve()来提供这些信息。
 * 
 * 
 * 
 * 后面ERC-223协议提供了额外的特性和安全措施
 * 
 */
contract ACCT is IERC20 {
    //代币元数据
    string public name = "TestToken";
    string public symbol = "TEST";
    uint8 public decimals = 18;
    //总供应量
    uint256 public override totalSupply;
    //⽤⼾余额映射
    mapping(address => uint256) public override balanceOf;
    //授权映射
    mapping(address => mapping(address => uint256)) public override allowance;

    /**
        转移函数
    **/
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    //授权函数
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    //授权转移函数
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //增发函数
    function mint(uint256 amount) public {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    //销毁函数
    function burn(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function test(uint256 amount) external {
        //0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        
        address spender = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        
        //1 spender  mint
        //2 spender approve  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

        //0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        //第一步 增发
        mint(amount);

        approve(spender,amount/2);

        transfer(spender,amount/2);

        
        //使用0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266账号  
        //授权账号  0x70997970C51812dc3A010C7d01b50e0d17dc79C8 向 0x90F79bf6EB2c4f870365E785982E1f101E93b906 转账
        
        // transferFrom(spender,recipient,amount);


    }
}
