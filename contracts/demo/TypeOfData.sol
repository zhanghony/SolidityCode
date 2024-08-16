// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// /************************************* 用户定义的值类型 ****************************************************************/
// // 使用用户定义的值类型表示 18 位小数、256 bit的浮点类型。
// type UFixed256x18 is uint256;

// /// 在 UFixed256x18 上进行浮点操作的精简库。
// library FixedMath {
//     uint constant multiplier = 10**18;

//     /// 两个 UFixed256x18 数相加，
//     /// 溢出时恢复，依赖于 uint256 上的检查算术
//      function add(UFixed256x18 a, UFixed256x18 b) internal pure returns (UFixed256x18) {
//         return UFixed256x18.wrap(UFixed256x18.unwrap(a) + UFixed256x18.unwrap(b));
//     }
//     /// 将 UFixed256x18 和 uint256 相乘.
//     /// 溢出时恢复，依赖于 uint256 上的检查算术
//      function mul(UFixed256x18 a, uint256 b) internal pure returns (UFixed256x18) {
//         return UFixed256x18.wrap(UFixed256x18.unwrap(a) * b);
//     }
//     ///  UFixed256x18 向下取整.
//     /// @return 不超过 `a` 的最大整数。
//     function floor(UFixed256x18 a) internal pure returns (uint256) {
//         return UFixed256x18.unwrap(a) / multiplier;
//     }
//     /// 将 uint256 转换为相同值的 UFixed256x18。
//     /// 如果整数太大，则还原。
//     function toUFixed256x18(uint256 a) internal pure returns (UFixed256x18) {
//         return UFixed256x18.wrap(a * multiplier);
//     }
// }

// contract TypeOfData {
//     // 枚举类型的默认值是第一个值。
//     // 结构
//     enum Status {
//         None, // 0
//         Pending, // 1
//         Shiped, // 2
//         Completed,
//         Rejected,
//         Canceled
//     }

//     // 变量
//     Status public status;

// // 设置索引值
//     function set(Status _status) external {
//         status = _status;
//     }

//     // 由于枚举类型不属于 |ABI| 的一部分，因此对于所有来自 Solidity 外部的调用，
//     // "getStatus" 的签名会自动被改成 "getStatus() returns (uint8)"。
//     function getStatus() public view returns (Status) {
//         return status;
//     }

//     function getDefaultStatus() public view returns (uint256) {
//         return uint256(status);
//     }

//     // 设置
//     function ship() external {
//         status = Status.Shiped;
//     }

//     // 恢复为0
//     function reset() external {
//         delete status;
//     }

//     function getLargestValue() public pure returns (Status) {
//         return type(Status).max;
//     }

//     function getSmallestValue() public pure returns (Status) {
//         return type(Status).min;
//     }


//     //int8 to int256 8 位到 256 位的带符号整型数。
//     //uint8 to uint256 8 位到 256 位的无符号整型。
//     //int 有符号整数，int 与 int256 相同。
//     //uint 无符号整数，uint 和 uint256 是一样的。
//     //fixed 有符号的定长浮点型
//     //unfixed 无符号的定长浮点型
//     function getMin() external pure returns (uint256) {
//         return type(uint256).min;
//     }

//     function getMax() external pure returns (uint256) {
//         return type(uint256).max;
//     }

//     function getString() external pure {
//         string memory s1 = unicode"同志们好";
//         s1 = "sfsfsdf";
//         //用空格分开的字符串
//         string memory a = "a"
//         "b";
//     }

//     function getHex() external pure {
//         bytes1  b1 = hex"61";
//         b1[0] = "a";
//         b1[0] = 0x61;

//         //用空格分隔的多个十六进制字面常量被合并为一个字面常量： hex"61" hex"61" 等同于 hex"6161"
//         bytes2 = hex"61" hex"61";

//     }






// /*************************************** address/uint/bytes32 之间的转换 ***************************************************/

//     /**
//      * 1 字节 8 位，一个 address 是 20 个字节，是 160 位，所以 address 可以用 uint160 表示。
//      * 1 字节可以表示为两个连续的十六进制数字，所以 address 可以用连续的 40 个十六进制数字表示。
//      * @param _a 
//      */
//     function bytes32ToAddress(bytes32 _a) external pure returns (address) {
//         //


//         // return address(uint160(bytes20(_a)));
//         return address(uint160(uint256(_a)));
//     }


//     //地址方法
//     function demoAddress(address _addr) external {
//         // 以 Wei 为单位的余额
//        uint256 balance =  _addr.balance;
//        //code : 地址上的代码(可以为空) 不为空说明是合约
//        bytes memory code = _addr.code;

//         bytes32 codehash = _addr.codehash;

//         //合约地址
//         //address(this);


//         // payable()将普通地址转为可支付地址。
//         // .transfer(uint256 amount): 将余额转到当前地址（合约地址转账）
//         //_addr.send(uint256 amount): 将余额转到当前地址，并返回交易成功状态（合约地址转账）
//         //用给定的有效载荷（payload）发出低级 CALL 调用，并返回交易成功状态和返回数据（调用合约的方法并转账）
//         //_addr.call(bytes memory);
//         // 用给定的有效载荷（payload）发出低级 DELEGATECALL 调用，并返回交易成功状态和返回数据（调用合约的方法并转账）
//         //_addr.delegatecall(bytes memory);
//         //用给定的有效载荷（payload）发出低级 STATICCALL 调用，并返回交易成功状态和返回数据（调用合约的方法并转账）
//         //_addr.staticcall(bytes memory);
//     } 


//     // 获取即将部署的地址
//     function getAddress(bytes memory bytecode, uint256 _salt)
//         external
//         view
//         returns (address)
//     {
//         bytes32 hash = keccak256(
//             abi.encodePacked(
//                 bytes1(0xff), // 固定字符串
//                 address(this), // 当前工厂合约地址
//                 _salt, // salt
//                 keccak256(bytecode) //部署合约的 bytecode
//             )
//         );
//         return address(uint160(uint256(hash)));
//     }


// }
