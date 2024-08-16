// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Test {
    //string  private msg = "hello World";


    function sendEth() external  {
        address _to =   0x40340F24338dc5DFFe9338Be1A114A768541AEe7;

        payable(_to).transfer(100);
    }

}