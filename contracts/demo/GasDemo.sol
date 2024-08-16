// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title 节省 gas
/// @author zhanghony
/// @notice 节省 gas的案例
/// @dev Explain to a developer any extra details
contract GasDemo {
    constructor() {}

    /**
     * 方式一: 参数中 地址标注 address payable ,并且函数状态可变性标为 payable;
        这种更省 gas (推荐)
        方式二: 仅在内部进行 payable(address) 显示转换
     * 
     */

    // 使用固定（不可调节）的 2300 gas 的矿工费，错误会 reverts （回滚所有状态）2300 gas 足够转账，但是如果接收合约内的 fallback 和 receive 函数有恶意代码，复杂代码。容易导致 gas 耗尽的错误。
    // 如果目标地址是一个合约，那么目标合约内部的 receive/fallback 函数会随着调用 transfer函数一起执行，这是 EVM 的特性，没办法阻止。
}


/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev 使⽤calldata代替memory：通过改变变量存储位置来减少燃⽓消耗。
/// 循环内部变量优化：在循环开始前将状态变量加载到内存，循环结束后再更新状态变量
/// 表达式短路（ShortCircuiting）：优化条件判断逻辑，避免不必要的计算。
/// 循环增量简化：使⽤++i 代替i + 1来减少操作。
/// 缓存数组⻓度：将数组⻓度存储在局部变量中，减少每次循环的计算量
/// 数组元素加载到内存：将频繁访问的数组元素预先加载到变量中

contract GasGolf {
    // start - 55167 gas
    // use calldata - 54438 gas
    // load state variables to memory  - 54187 gas
    // short circuit - 53815 gas
    // loop increments - 53304 gas
    // cache array length - deprecated
    // load array elements to memory - 53097 gas
    uint256 public total;
    // [1,2,3,4,5,100]
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        for (uint i = 0; i < nums.length; ++i) {
            uint num = nums[i];
            if (num % 2 == 0 && num < 99) {
                _total += num;
            }
        }
        total = _total;
    }
}
