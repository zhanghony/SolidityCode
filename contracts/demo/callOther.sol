// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
call ， delegatecall 和 staticcall 都是非常低级的函数，应该只把它们当作最后一招来使用，它们破坏了 Solidity 的类型安全性。
三种方法都提供 gas 选项，而 value 选项仅 call 支持 。所以三种 call 里只有 call 可以进行 ETH 转账，其他两种不可以进行转账。
不管是读取状态还是写入状态，最好避免在合约代码中硬编码使用的 gas 值。这可能会引入错误，而且 gas 的消耗也是动态改变的。
如果在通过低级函数 delegatecall 发起调用时需要访问存储中的变量，那么这两个合约的存储布局需要一致，以便被调用的合约代码可以正确地通过变量名访问合约的存储变量。 这不是指在库函数调用（高级的调用方式）时所传递的存储变量指针需要满足那样情况。
*/
contract callOther {
    event Log(string funName, address from, uint256 value, bytes data);

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function test(uint256 _num) external pure returns (uint256) {
        return _num;
    }

    function getGasleft() external  view   returns (uint256) {
        return gasleft();
    }

    //低级 CALL 调用：不需要 payable address, 普通地址即可
    //当合约调用合约时，不知道对方源码和 ABI 时候，可以使用 call 调用对方合约
    //推荐使用 call 转账 ETH，但是不推荐使用 call 来调用其他合约。原因是: call 调用的时候，将合约控制权交给对方，如果碰到恶意代码，或者不安全的代码就很容易凉凉
    //当调用不存在的合约方法时候，会触发对方合约内的 fallback 或者 receive。我们的合约也可以在 fallback / receive 这两个方法内抛出事件，查看是否有人对其做了什么操作。
    //三种方法都提供 gas 选项，而 value 选项仅 call 支持 。三种 call 里只有 call 可以进行 ETH 转账，其他两种不可以进行转账。
    function call1(address _addr, bytes memory data) external payable {
        // 9005
        (bool success, ) = _addr.call{value: 100}(data);

        // 29007
        // (bool success, bytes memory data) = payable(_to).call{value: 100}("");

        require(success, "call Faied");
        // _addr.call{value: msg.value,gas:2300}(data);
    }

    function call2(
        address _addr,
        string memory _name,
        uint256 _age
    ) external payable {
        bytes memory data = abi.encodeWithSignature(
            "setNameAndAge(string,uint256)",
            _name,
            _age
        );
        (bool success, bytes memory _bys) = _addr.call{value: msg.value}(data);
        require(success, "Call Failed");
    }

    //发出低级函数 DELEGATECALL，失败时返回 false，发送所有可用 gas，也可以自己调节 gas
    //只调用给定地址的代码（函数），其他状态属性如（存储，余额 …）都来自当前合约。delegatecall 的目的是使用另一个合约中的库代码。
    //委托对方调用自己数据的。类似授权转账，比如我部署一个 Bank 合约， 授权 ContractA 使用 Bank 地址内的资金，ContractA 只拥有控制权，但是没有拥有权。
    //所有变量修改都是发生在委托合约内部，并不会保存在被委托合约中。利用这个特性，可以通过更换被委托合约，来升级委托合约。
    //委托调用合约内部，需要和被委托合约的内部参数完全一样，否则容易导致数据混乱可以通过顺序来避免这个问题，但是推荐完全一样
    function delegatecall(address _addr) external {
        uint256 _num = 23;
        // 不需知道合约名字，函数完全自定义
        bytes memory data1 = abi.encodeWithSignature("set(uint256)", _num);

        // 需要合约名字，可以避免函数和参数写错
        bytes memory data2 = abi.encodeWithSelector(
            callOther.test.selector,
            _num
        );
        (bool success, bytes memory _data) = _addr.delegatecall(data2);
    }


    //合约地址用给定的有效载荷（payload）发出低级 STATICCALL 调用，并返回交易成功状态和返回数据（调用合约的方法并转账）
    function staticcall(address _addr) external view returns (string memory) {
        // 编码被调用者的方法签名
        bytes4 methodId = bytes4(keccak256("echo()"));
        // 调用合约
        (bool success, bytes memory data) = _addr.staticcall(
            abi.encodeWithSelector(methodId)
        );

        if (success) {
            return abi.decode(data, (string));
        } else {
            return "error";
        }

    }



}
