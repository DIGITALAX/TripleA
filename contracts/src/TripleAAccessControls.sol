// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleAErrors.sol";

contract TripleAAccessControls {
    address public agentsContract;
    mapping(address => uint256) private _base;
    mapping(address => uint256) private _vig;
    mapping(address => bool) private _admins;
    mapping(address => bool) private _agents;
    mapping(address => bool) private _fulfillers;
    mapping(address => uint256) private _thresholds;
    mapping(address => uint256) private _cycleRentRemix;
    mapping(address => uint256) private _cycleRentLead;
    mapping(address => uint256) private _cycleRentPublish;
    mapping(address => bool) private _acceptedTokens;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event FulfillerAdded(address indexed admin);
    event FulfillerRemoved(address indexed admin);
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);
    event AcceptedTokenSet(address token);
    event AcceptedTokenRemoved(address token);
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

    modifier onlyAgentOrAdmin() {
        if (!_admins[msg.sender] && !_agents[msg.sender]) {
            revert TripleAErrors.NotAgentOrAdmin();
        }
        _;
    }

    modifier onlyAdmin() {
        if (!_admins[msg.sender]) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyAgentContractOrAdmin() {
        if (msg.sender != agentsContract && !_admins[msg.sender]) {
            revert TripleAErrors.OnlyAgentContract();
        }
        _;
    }

    constructor() payable {
        _admins[msg.sender] = true;
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

    function addAgent(address agent) external onlyAgentContractOrAdmin {
        if (_agents[agent]) {
            revert TripleAErrors.AgentAlreadyExists();
        }
        _agents[agent] = true;
        emit AgentAdded(agent);
    }

    function removeAgent(address agent) external onlyAgentContractOrAdmin {
        if (!_agents[agent]) {
            revert TripleAErrors.AgentDoesntExist();
        }
        _agents[agent] = false;
        emit AgentRemoved(agent);
    }

    function setAcceptedToken(address token) external {
        if (_acceptedTokens[token]) {
            revert TripleAErrors.TokenAlreadyExists();
        }

        _acceptedTokens[token] = true;

        emit AcceptedTokenSet(token);
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
        if (!_acceptedTokens[token]) {
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

    function removeAcceptedToken(address token) external {
        if (!_acceptedTokens[token]) {
            revert TripleAErrors.TokenDoesntExist();
        }

        delete _acceptedTokens[token];
        delete _thresholds[token];
        delete _cycleRentLead[token];
        delete _cycleRentPublish[token];
        delete _cycleRentRemix[token];
        delete _vig[token];
        delete _base[token];

        emit AcceptedTokenRemoved(token);
    }

    function isAdmin(address _address) public view returns (bool) {
        return _admins[_address];
    }

    function isAgent(address _address) public view returns (bool) {
        return _agents[_address];
    }

    function isFulfiller(address _address) public view returns (bool) {
        return _fulfillers[_address];
    }

    function isAcceptedToken(address token) public view returns (bool) {
        return _acceptedTokens[token];
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

    function setAgentsContract(address _agentsContract) public onlyAdmin {
        agentsContract = _agentsContract;
    }

    function faucet(address payable to, uint256 amount) external {
        if (address(this).balance < amount) {
            revert TripleAErrors.InsufficientFunds();
        }

        (bool _success, ) = to.call{value: amount}("");
        if (!_success) {
            revert TripleAErrors.TransferFailed();
        }

        emit FaucetUsed(to, amount);
    }

    function getNativeGrassBalance(address user) public view returns (uint256) {
        return user.balance;
    }

    receive() external payable {}

    fallback() external payable {}
}
