// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ACCT.sol";

import "hardhat/console.sol";

contract Test is Ownable {
    //string  private msg = "hello World";


    function sendEth(address _to ) external  {
        payable(_to).transfer(100);
    }


    function stake(uint256 amount) external {
    console.log(
        "offset: %d, amount: %d",
        block.timestamp ,
        amount
    );
    // 其他逻辑
}

}