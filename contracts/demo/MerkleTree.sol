// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title 默克尔树
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
contract MerkleTree is Ownable {
    bytes32 private root;

    constructor() Ownable(msg.sender){

    }
 
    function valid(address _address, bytes32[] calldata _proof)
        public
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(_address));
        require(MerkleProof.verify(_proof, root, leaf), "Invalid");

        return true;
    }

    function setRoot(bytes32 _root) public onlyOwner {
        root = _root;
    }
}
