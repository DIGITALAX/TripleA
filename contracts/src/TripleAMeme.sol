// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleAErrors.sol";
import "./TripleAAccessControls.sol";
import "./TripleADevTreasury.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TripleAMeme {
    TripleAAccessControls public accessControls;
    TripleADevTreasury public devTreasury;

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    constructor(
        address payable _accessControls,
        address payable _devTreasury
    ) payable {
        accessControls = TripleAAccessControls(_accessControls);
        devTreasury = TripleADevTreasury(_devTreasury);
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function setDevTreasury(address payable _devTreasury) external onlyAdmin {
        devTreasury = TripleADevTreasury(_devTreasury);
    }

    receive() external payable {}

    fallback() external payable {}
}
