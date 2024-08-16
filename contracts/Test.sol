// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ACCT.sol";

contract Test is Ownable {
    //string  private msg = "hello World";


    function sendEth(address _to ) external  {
        payable(_to).transfer(100);
    }

}