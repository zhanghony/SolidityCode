// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyToken is IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    uint256 public override totalSupply;

    string private name;
    string private symbol;
    uint8 private decimals;

    address public owner;

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    mapping(address => uint256) public override balanceOf;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    mapping(address => mapping(address => uint256)) public override allowance;

    // /**
    //  * @dev Emitted when `value` tokens are moved from one account (`from`) to
    //  * another (`to`).
    //  *
    //  * Note that `value` may be zero.
    //  */
    // event Transfer(address indexed from, address indexed to, uint256 value);

    // /**
    //  * @dev Emitted when the allowance of a `spender` for an `owner` is set by
    //  * a call to {approve}. `value` is the new allowance.
    //  */
    // event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        mint(msg.sender, _totalSupply);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        balanceOf[msg.sender] = balanceOf[msg.sender] - amount;
        balanceOf[to] = balanceOf[to] + amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(balanceOf[from] >= amount, "from havn't enough balance");
        require(allowance[from][msg.sender] >= amount, "not enough allowance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(
        address _account,
        uint256 _amount
    ) internal virtual onlyOwner {
        require(_account != address(0), "ERC20: mint to the zero address");
        totalSupply += _amount;
        balanceOf[_account] += _amount;
        emit Transfer(address(0), _account, _amount);
    }
}

contract Faucet {
    IERC20 public tokenContract; // 代币合约
    mapping(address => uint256) public recvedRecord; //领取记录
    uint256 public amountEachTime; //每次领取数量
    address public owner;

    constructor(address _tokenContractAddress, uint256 _amountEachTime) {
        tokenContract = IERC20(_tokenContractAddress);
        amountEachTime = _amountEachTime;
        owner = msg.sender;
    }

    //领取代币，每个地址每24小时只能领取一次
    function withdrow() external {
        if (recvedRecord[msg.sender] > 0) {
            require(
                block.timestamp - recvedRecord[msg.sender] >= 24 hours,
                "You can only request tokens once every 24 hours"
            );
        }
        require(
            tokenContract.balanceOf(address(this)) >= amountEachTime,
            "Not enough tokens in the contract"
        );
        recvedRecord[msg.sender] = block.timestamp;
        tokenContract.transfer(msg.sender, amountEachTime);
    }

    function setAmountEachTime(uint256 _amountEachTime) public {
        require(owner == msg.sender, "Only the owner can set this amount");
        amountEachTime = _amountEachTime;
    }
}

contract Airdrop {
    IERC20 public tokenContract; // 代币合约
    address public owner; // 合约发布者

    constructor(address _tokenContractAddress) {
        tokenContract = IERC20(_tokenContractAddress);
        owner = msg.sender;
    }

    // 空投代币，多个地址对应一个数量
    function oneToMany(address[] memory _to, uint256 _amount) public {
        // 只有合约发布者可以调用
        require(msg.sender == owner, "Only the owner can airdrop tokens");
        // 验证合约中的代币数量是否足够
        uint256 totalAmount = _amount * _to.length;
        require(
            tokenContract.balanceOf(address(this)) >= totalAmount,
            "Not enough tokens in the contract"
        );
        // 空投代币
        for (uint256 i = 0; i < _to.length; i++) {
            tokenContract.transfer(_to[i], _amount);
        }
    }

    // 空投代币，一个地址对应一个数量
    function oneToOne(address[] memory _to, uint256[] memory _amount) public {
        // 只有合约发布者可以调用
        require(msg.sender == owner, "Only the owner can airdrop tokens");
        // 验证数组长度是否相等
        require(
            _to.length == _amount.length,
            "The length of the two arrays must be the same"
        );
        // 验证合约中的代币是否足够
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _amount.length; i++) {
            totalAmount += _amount[i];
        }
        require(
            tokenContract.balanceOf(address(this)) >= totalAmount,
            "Not enough tokens in the contract"
        );
        // 空投代币
        for (uint256 i = 0; i < _to.length; i++) {
            tokenContract.transfer(_to[i], _amount[i]);
        }
    }
}
