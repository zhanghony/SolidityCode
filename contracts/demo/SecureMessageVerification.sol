// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SecureMessageVerification is EIP712, ReentrancyGuard {
    using ECDSA for bytes32;
    using Counters for Counters.Counter;

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256(
            "Message(address from,address to,uint256 amount,uint256 nonce,uint256 deadline)"
        );

    mapping(address => Counters.Counter) private _nonces;
    mapping(bytes32 => bool) private _usedSignatures;

    uint256 public constant MAX_DEADLINE = 1 hours;

    event MessageExecuted(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 nonce
    );

    constructor() EIP712("SecureMessageVerification", "1") {}

    function verifyAndExecuteMessage(
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(block.timestamp <= deadline, "Signature expired");
        require(
            deadline <= block.timestamp + MAX_DEADLINE,
            "Deadline too far in the future"
        );

        address signer = msg.sender;
        uint256 nonce = getNonce(signer);

        bytes32 structHash = keccak256(
            abi.encode(MESSAGE_TYPEHASH, signer, to, amount, nonce, deadline)
        );

        bytes32 hash = _hashTypedDataV4(structHash);
        address recoveredSigner = ecrecover(hash, v, r, s);

        require(recoveredSigner == signer, "Invalid signature");
        require(!_usedSignatures[hash], "Signature already used");

        _usedSignatures[hash] = true;

        // 执行消息逻辑
        // 例如: token.transferFrom(signer, to, amount);

        emit MessageExecuted(signer, to, amount, nonce);
    }

    function getNonce(address account) public view returns (uint256) {
        return _nonces[account].current();
    }

    function _useNonce(address account) internal returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[account];
        current = nonce.current();
        nonce.increment();
    }
}
