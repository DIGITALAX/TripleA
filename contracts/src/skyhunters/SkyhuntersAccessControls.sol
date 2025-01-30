// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.24;

import "./SkyhuntersErrors.sol";

contract SkyhuntersAccessControls {
    address public agentsContract;
    address[] private _verifiedContractsList;
    address[] private _verifiedPoolsList;
    address[] private _allTokens;

    mapping(address => bool) private _admins;
    mapping(address => bool) private _verifiedContracts;
    mapping(address => bool) private _verifiedPools;
    mapping(address => bool) private _agents;
    mapping(address => bool) private _acceptedTokens;

    modifier onlyAdmin() {
        if (!_admins[msg.sender]) {
            revert SkyhuntersErrors.NotAdmin();
        }
        _;
    }

    modifier onlyAgentOrAdmin() {
        if (!_admins[msg.sender] && !_agents[msg.sender]) {
            revert SkyhuntersErrors.NotAgentOrAdmin();
        }
        _;
    }

    modifier onlyAgentContractOrAdmin() {
        if (msg.sender != agentsContract && !_admins[msg.sender]) {
            revert SkyhuntersErrors.OnlyAgentContract();
        }
        _;
    }

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event VerifiedContractAdded(address indexed verifiedContract);
    event VerifiedContractRemoved(address indexed verifiedContract);
    event VerifiedPoolAdded(address indexed pool);
    event VerifiedPoolRemoved(address indexed pool);
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);
    event AcceptedTokenSet(address token);
    event AcceptedTokenRemoved(address token);

    constructor() {
        _admins[msg.sender] = true;
    }

    function addAdmin(address admin) external onlyAdmin {
        if (_admins[admin]) {
            revert SkyhuntersErrors.AdminAlreadyExists();
        }
        _admins[admin] = true;
        emit AdminAdded(admin);
    }

    function removeAdmin(address admin) external onlyAdmin {
        if (!_admins[admin]) {
            revert SkyhuntersErrors.AdminDoesntExist();
        }

        if (admin == msg.sender) {
            revert SkyhuntersErrors.CannotRemoveSelf();
        }

        _admins[admin] = false;
        emit AdminRemoved(admin);
    }

    function addVerifiedContract(address verifiedContract) external onlyAdmin {
        if (_verifiedContracts[verifiedContract]) {
            revert SkyhuntersErrors.ContractAlreadyExists();
        }
        _verifiedContracts[verifiedContract] = true;
        _verifiedContractsList.push(verifiedContract);
        emit VerifiedContractAdded(verifiedContract);
    }

    function removeVerifiedContract(
        address verifiedContract
    ) external onlyAdmin {
        if (!_verifiedContracts[verifiedContract]) {
            revert SkyhuntersErrors.ContractDoesntExist();
        }

        _verifiedContractsList.push(verifiedContract);

        for (uint8 i = 0; i < _verifiedContractsList.length; i++) {
            if (_verifiedContractsList[i] == verifiedContract) {
                _verifiedContractsList[i] = _verifiedContractsList[
                    _verifiedContractsList.length - 1
                ];
                _verifiedContractsList.pop();
                break;
            }
        }

        _verifiedContracts[verifiedContract] = false;
        emit VerifiedContractRemoved(verifiedContract);
    }

    function addVerifiedPool(address verifiedPool) external onlyAdmin {
        if (_verifiedPools[verifiedPool]) {
            revert SkyhuntersErrors.PoolAlreadyExists();
        }
        _verifiedPools[verifiedPool] = true;
        _verifiedPoolsList.push(verifiedPool);
        emit VerifiedPoolAdded(verifiedPool);
    }

    function removeVerifiedPool(address verifiedPool) external onlyAdmin {
        if (!_verifiedPools[verifiedPool]) {
            revert SkyhuntersErrors.PoolDoesntExist();
        }

        for (uint8 i = 0; i < _verifiedPoolsList.length; i++) {
            if (_verifiedPoolsList[i] == verifiedPool) {
                _verifiedPoolsList[i] = _verifiedPoolsList[
                    _verifiedPoolsList.length - 1
                ];
                _verifiedPoolsList.pop();
                break;
            }
        }

        _verifiedPools[verifiedPool] = false;
        emit VerifiedPoolRemoved(verifiedPool);
    }

    function setAcceptedToken(address token) external {
        if (_acceptedTokens[token]) {
            revert SkyhuntersErrors.TokenAlreadyExists();
        }

        _acceptedTokens[token] = true;

        emit AcceptedTokenSet(token);
    }

    function removeAcceptedToken(address token) external {
        if (!_acceptedTokens[token]) {
            revert SkyhuntersErrors.TokenDoesntExist();
        }

        delete _acceptedTokens[token];

        emit AcceptedTokenRemoved(token);
    }

    function addAgent(address agent) external onlyAgentContractOrAdmin {
        if (_agents[agent]) {
            revert SkyhuntersErrors.AgentAlreadyExists();
        }
        _agents[agent] = true;
        emit AgentAdded(agent);
    }

    function removeAgent(address agent) external onlyAgentContractOrAdmin {
        if (!_agents[agent]) {
            revert SkyhuntersErrors.AgentDoesntExist();
        }

        _agents[agent] = false;
        emit AgentRemoved(agent);
    }

    function setAgentsContract(address _agentsContract) public onlyAdmin {
        agentsContract = _agentsContract;
    }

    function isAdmin(address admin) public view returns (bool) {
        return _admins[admin];
    }

    function isVerifiedContract(
        address verifiedContract
    ) public view returns (bool) {
        return _verifiedContracts[verifiedContract];
    }

    function isAgent(address _address) public view returns (bool) {
        return _agents[_address];
    }

    function isAcceptedToken(address token) public view returns (bool) {
        return _acceptedTokens[token];
    }

    function isPool(address token) public view returns (bool) {
        return _verifiedPools[token];
    }

    function getVerifiedContracts() public view returns (address[] memory) {
        return _verifiedContractsList;
    }

    function getVerifiedPools() public view returns (address[] memory) {
        return _verifiedPoolsList;
    }

    function getAllTokens() public view returns (address[] memory) {
        return _allTokens;
    }
}
