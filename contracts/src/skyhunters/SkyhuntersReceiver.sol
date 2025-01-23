// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.24;

import "./SkyhuntersAccessControls.sol";
import "./SkyhuntersErrors.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SkyhuntersReceiver {
    SkyhuntersAccessControls public accessControls;
    mapping(address => mapping(address => uint256)) private _userDeposited;

    event TokensReceived(address token, address user, uint256 amount);
    event UserWithdraw(address token, address user, uint256 amount);

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert SkyhuntersErrors.NotAdmin();
        }
        _;
    }

    modifier onlyContract() {
        if (!accessControls.isVerifiedContract(msg.sender)) {
            revert SkyhuntersErrors.NotVerifiedContract();
        }
        _;
    }

    constructor(address _accessControls) payable {
        accessControls = SkyhuntersAccessControls(_accessControls);
    }

    function receiveTokensUser(address token, uint256 amount) public {
        _userDeposited[msg.sender][token] += amount;

        emit TokensReceived(token, msg.sender, amount);
    }

    function receiveTokensContract(
        address token,
        address user,
        uint256 amount
    ) external onlyContract returns (bool) {
        _userDeposited[user][token] += amount;
        emit TokensReceived(token, user, amount);

        return true;
    }

    function withdrawDeposited(address token, uint256 amount, bool max) public {
        if (amount > _userDeposited[msg.sender][token]) {
            revert SkyhuntersErrors.InvalidFunds();
        }

        if (max) {
            if (
                IERC20(token).transfer(
                    msg.sender,
                    _userDeposited[msg.sender][token]
                )
            ) {
                _userDeposited[msg.sender][token] = 0;
            }
        } else {
            if (IERC20(token).transfer(msg.sender, amount)) {
                _userDeposited[msg.sender][token] -= amount;
            }
        }

        emit UserWithdraw(token, msg.sender, amount);
    }

    function setAccessControls(address _accessControls) public onlyAdmin {
        accessControls = SkyhuntersAccessControls(_accessControls);
    }

    receive() external payable {}

    fallback() external payable {}
}
