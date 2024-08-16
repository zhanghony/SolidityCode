// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 智能保险箱
 * @author zhanghony
 * @notice 一款智能加密的区块链数据，只有自己才能看到自己的数据，可以放一些比较私密的数据
 */
contract Strongbox {
    mapping(address => mapping(string => string)) secretMap;
    mapping(address => string[]) sercretKeyMap;

    function putSecret(string memory _key, string memory _value) external {
        sercretKeyMap[msg.sender].push(_key);
        secretMap[msg.sender][_key] = _value;
    }

    function getSecretKey() external view returns (string[] memory _keys) {
        return sercretKeyMap[msg.sender];
    }

    function getSecretByKey(
        string memory _key,
        bytes memory _sig
    ) external view checkSign(_key, _sig) returns (string memory _value) {
        return secretMap[msg.sender][_key];
    }

    modifier checkSign(string memory _key, bytes memory _sig) {
        require(verifyMessage(_key, _sig), "sig is checked failed");
        _;
    }

    function verifyMessage(
        string memory _message,
        bytes memory _sig
    ) internal pure returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(_message));
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        (bytes32 r, bytes32 s, uint8 v) = split(_sig);
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        address _signer = bytesToAddress(s);
        return _signer == signer;
    }

    function split(
        bytes memory _sig
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        //32+32+1 ==65
        require(_sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }

    function bytesToAddress(bytes32 bys) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}
