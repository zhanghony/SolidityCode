// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Counter {
    uint256 public count;

    function inc() external returns (uint256) {
        count += 1;
        return count;
    }
}

// 课程060 
contract ABICoder {
    struct MyStruct {
        string name;
        uint256[2] numbers;
    }

    /// @notice 编码数据
    function encodeData(
        uint256 x,
        address addr,
        uint256[] memory r,
        MyStruct memory myStruct
    ) public pure returns (bytes memory) {
        return abi.encode(x, addr, r, myStruct);
    }

    /// @notice 解码数据
    function decodeData(bytes memory data)
        public
        pure
        returns (
            uint256,
            address,
            uint256[] memory,
            MyStruct memory
        )
    {
        (
            uint256 x,
            address addr,
            uint256[] memory r,
            MyStruct memory myStruct
        ) = abi.decode(data, (uint256, address, uint256[], MyStruct));
        return (x, addr, r, myStruct);
    }

    function encodeWithSignature() external pure returns (bytes memory) {
        return abi.encodeWithSignature("inc()");
    }
    
}