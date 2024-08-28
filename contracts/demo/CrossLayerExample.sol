// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

contract CrossLayerExample {
    address public l1Contract;
    address public l2Contract;

    constructor(address _l1Contract) {
        l1Contract = _l1Contract;
    }

    function sendMessageToL1(bytes memory message) public {
        ICrossDomainMessenger(0x4200000000000000000000000000000000000007)
            .sendMessage(
                l1Contract,
                message,
                1000000 // gas limit
            );
    }
}
