// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleAErrors.sol";
import "./skyhunters/SkyhuntersAccessControls.sol";

contract TripleAAccessControls {
    SkyhuntersAccessControls public skyhuntersAccessControls;

    mapping(address => uint256) private _base;
    mapping(address => uint256) private _vig;
    mapping(address => bool) private _admins;
    mapping(address => bool) private _fulfillers;
    mapping(address => uint256) private _thresholds;
    mapping(address => uint256) private _cycleRentRemix;
    mapping(address => uint256) private _cycleRentLead;
    mapping(address => uint256) private _cycleRentPublish;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event FulfillerAdded(address indexed admin);
    event FulfillerRemoved(address indexed admin);
    event FaucetUsed(address to, uint256 amount);
    event TokenDetailsSet(
        address token,
        uint256 threshold,
        uint256 rentLead,
        uint256 rentRemix,
        uint256 rentPublish,
        uint256 vig,
        uint256 base
    );
    event TokenDetailsRemoved(address token);

    modifier onlyAdmin() {
        if (!_admins[msg.sender]) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    constructor(address payable _skyhuntersAccessControls) payable {
        _admins[msg.sender] = true;
        skyhuntersAccessControls = SkyhuntersAccessControls(
            _skyhuntersAccessControls
        );
        emit AdminAdded(msg.sender);
    }

    function addAdmin(address admin) external onlyAdmin {
        if (_admins[admin]) {
            revert TripleAErrors.AdminAlreadyExists();
        }
        _admins[admin] = true;
        emit AdminAdded(admin);
    }

    function removeAdmin(address admin) external onlyAdmin {
        if (!_admins[admin]) {
            revert TripleAErrors.AdminDoesntExist();
        }

        if (admin == msg.sender) {
            revert TripleAErrors.CannotRemoveSelf();
        }

        _admins[admin] = false;
        emit AdminRemoved(admin);
    }

    function addFulfiller(address fulfiller) external onlyAdmin {
        if (_fulfillers[fulfiller]) {
            revert TripleAErrors.FulfillerAlreadyExists();
        }
        _fulfillers[fulfiller] = true;
        emit FulfillerAdded(fulfiller);
    }

    function removeFulfiller(address fulfiller) external onlyAdmin {
        if (!_fulfillers[fulfiller]) {
            revert TripleAErrors.FulfillerDoesntExist();
        }
        _fulfillers[fulfiller] = false;
        emit FulfillerRemoved(fulfiller);
    }

    function setTokenDetails(
        address token,
        uint256 threshold,
        uint256 rentLead,
        uint256 rentRemix,
        uint256 rentPublish,
        uint256 vig,
        uint256 base
    ) external {
        if (!skyhuntersAccessControls.isAcceptedToken(token)) {
            revert TripleAErrors.TokenNotAccepted();
        }

        _thresholds[token] = threshold;
        _cycleRentLead[token] = rentLead;
        _cycleRentRemix[token] = rentRemix;
        _cycleRentPublish[token] = rentPublish;
        _vig[token] = vig;
        _base[token] = base;

        emit TokenDetailsSet(
            token,
            threshold,
            rentLead,
            rentRemix,
            rentPublish,
            vig,
            base
        );
    }

    function removeTokenDetails(address token) external {
        if (!skyhuntersAccessControls.isAcceptedToken(token)) {
            revert TripleAErrors.TokenDoesntExist();
        }

        delete _thresholds[token];
        delete _cycleRentLead[token];
        delete _cycleRentPublish[token];
        delete _cycleRentRemix[token];
        delete _vig[token];
        delete _base[token];

        emit TokenDetailsRemoved(token);
    }

    function isAdmin(address _address) public view returns (bool) {
        return _admins[_address];
    }

    function isFulfiller(address _address) public view returns (bool) {
        return _fulfillers[_address];
    }

    function getTokenThreshold(address token) public view returns (uint256) {
        return _thresholds[token];
    }

    function getTokenCycleRentLead(
        address token
    ) public view returns (uint256) {
        return _cycleRentLead[token];
    }

    function getTokenCycleRentPublish(
        address token
    ) public view returns (uint256) {
        return _cycleRentPublish[token];
    }

    function getTokenCycleRentRemix(
        address token
    ) public view returns (uint256) {
        return _cycleRentRemix[token];
    }

    function getTokenVig(address token) public view returns (uint256) {
        return _vig[token];
    }

    function getTokenBase(address token) public view returns (uint256) {
        return _base[token];
    }

    function faucet(
        address payable to,
        uint256 amount,
        uint256 gas
    ) external  {
        if (address(this).balance < amount) {
            revert TripleAErrors.InsufficientFunds();
        }

        (bool _success, ) = to.call{value: amount, gas: gas}("");

        if (!_success) {
            revert TripleAErrors.TransferFailed();
        }

        emit FaucetUsed(to, amount);
    }

    function getNativeGrassBalance(address user) public view returns (uint256) {
        return user.balance;
    }

    function setSkyhuntersAccessControls(
        address payable _skyhuntersAccessControls
    ) public onlyAdmin {
        skyhuntersAccessControls = SkyhuntersAccessControls(
            _skyhuntersAccessControls
        );
    }

    function emergencyWithdraw(
        uint256 amount,
        uint256 gasAmount
    ) external onlyAdmin {
        (bool success, ) = payable(msg.sender).call{
            value: amount,
            gas: gasAmount
        }("");
        if (!success) {
            revert SkyhuntersErrors.TransferFailed();
        }
    }

    receive() external payable {}

    fallback() external payable {}
}
