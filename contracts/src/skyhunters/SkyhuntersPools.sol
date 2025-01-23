// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.24;

import "./SkyhuntersAccessControls.sol";
import "./SkyhuntersErrors.sol";

contract SkyhuntersPools {
    SkyhuntersAccessControls public accessControls;

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert SkyhuntersErrors.NotAdmin();
        }
        _;
    }

    constructor(address _accessControls) payable {
        accessControls = SkyhuntersAccessControls(_accessControls);
    }

    function setAccessControls(address _accessControls) public onlyAdmin {
        accessControls = SkyhuntersAccessControls(_accessControls);
    }

    receive() external payable {}

    fallback() external payable {}
}
