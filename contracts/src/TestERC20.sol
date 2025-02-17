// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("Test Token", "TST") {
        _mint(msg.sender, 10000 ether);
    }
}
