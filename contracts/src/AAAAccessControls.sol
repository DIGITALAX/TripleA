// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./AAAErrors.sol";

contract AAAAccessControls {
    address public agentsContract;
    mapping(address => bool) private _admins;
    mapping(address => bool) private _agents;
    mapping(address => uint256) private _thresholds;
    mapping(address => uint256) private _dailyRent;
    mapping(address => bool) private _acceptedTokens;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);
    event AcceptedTokenSet(address token);
    event AcceptedTokenRemoved(address token);
    event TokenThresholdSet(address token, uint256 threshold, uint256 rent);
    event FaucetUsed(address to, uint256 amount);

    modifier onlyAgentOrAdmin() {
        if (!_admins[msg.sender] && !_agents[msg.sender]) {
            revert AAAErrors.NotAgentOrAdmin();
        }
        _;
    }

    modifier onlyAdmin() {
        if (!_admins[msg.sender]) {
            revert AAAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyAgentContractOrAdmin() {
        if (msg.sender != agentsContract && !_admins[msg.sender]) {
            revert AAAErrors.OnlyAgentContract();
        }
        _;
    }

    constructor()  {
        _admins[msg.sender] = true;
        emit AdminAdded(msg.sender);
    }

    function addAdmin(address admin) external onlyAdmin {
        if (_admins[admin]) {
            revert AAAErrors.AdminAlreadyExists();
        }
        _admins[admin] = true;
        emit AdminAdded(admin);
    }

    function removeAdmin(address admin) external onlyAdmin {
        if (!_admins[admin]) {
            revert AAAErrors.AdminDoesntExist();
        }

        if (admin == msg.sender) {
            revert AAAErrors.CannotRemoveSelf();
        }

        _admins[admin] = false;
        emit AdminRemoved(admin);
    }

    function addAgent(address agent) external onlyAgentContractOrAdmin {
        if (_agents[agent]) {
            revert AAAErrors.AgentAlreadyExists();
        }
        _agents[agent] = true;
        emit AgentAdded(agent);
    }

    function removeAgent(address agent) external onlyAgentContractOrAdmin {
        if (!_agents[agent]) {
            revert AAAErrors.AgentDoesntExist();
        }
        _agents[agent] = false;
        emit AgentRemoved(agent);
    }

    function setAcceptedToken(address token) external {
        if (_acceptedTokens[token]) {
            revert AAAErrors.TokenAlreadyExists();
        }

        _acceptedTokens[token] = true;

        emit AcceptedTokenSet(token);
    }

    function setTokenThresholdAndRent(
        address token,
        uint256 threshold,
        uint256 rent
    ) external {
        if (!_acceptedTokens[token]) {
            revert AAAErrors.TokenNotAccepted();
        }

        _thresholds[token] = threshold;
        _dailyRent[token] = rent;

        emit TokenThresholdSet(token, threshold, rent);
    }

    function removeAcceptedToken(address token) external {
        if (!_acceptedTokens[token]) {
            revert AAAErrors.TokenDoesntExist();
        }

        delete _acceptedTokens[token];
        delete _thresholds[token];
        delete _dailyRent[token];

        emit AcceptedTokenRemoved(token);
    }

    function isAdmin(address _address) public view returns (bool) {
        return _admins[_address];
    }

    function isAgent(address _address) public view returns (bool) {
        return _agents[_address];
    }

    function isAcceptedToken(address token) public view returns (bool) {
        return _acceptedTokens[token];
    }

    function getTokenThreshold(address token) public view returns (uint256) {
        return _thresholds[token];
    }

    function getTokenDailyRent(address token) public view returns (uint256) {
        return _dailyRent[token];
    }

    function setAgentsContract(address _agentsContract) public onlyAdmin {
        agentsContract = _agentsContract;
    }
}
