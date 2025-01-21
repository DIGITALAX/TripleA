// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleAErrors.sol";
import "./TripleALibrary.sol";
import "./TripleAAccessControls.sol";
import "./TripleADevTreasury.sol";
import "./TripleACollectionManager.sol";

contract TripleAAgents {
    uint256 private _agentCounter;
    address public market;
    TripleAAccessControls public accessControls;
    TripleACollectionManager public collectionManager;
    TripleADevTreasury public devTreasury;
    mapping(uint256 => TripleALibrary.Agent) private _agents;
    mapping(address => mapping(uint256 => bool)) private _isOwner;
    mapping(address => mapping(uint256 => bool)) private _isWallet;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentActiveBalances;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentTotalBalances;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentBonusBalances;
    mapping(uint256 => mapping(uint256 => TripleALibrary.CollectionWorker))
        private _workers;

    event AgentCreated(address[] wallets, address creator, uint256 indexed id);
    event AgentDeleted(uint256 indexed id);
    event AgentEdited(uint256 indexed id);
    event BalanceAdded(
        address token,
        uint256 agentId,
        uint256 amount,
        uint256 collectionId
    );
    event BalanceWithdrawn(
        address[] tokens,
        uint256[] collectionIds,
        uint256[] amounts,
        uint256 agentId
    );
    event AgentRecharged(
        address recharger,
        address token,
        uint256 agentId,
        uint256 collectionId,
        uint256 amount
    );
    event ExcessAgent(
        address token,
        uint256 amount,
        uint256 agentId,
        uint256 collectionId
    );
    event SwapFundsToTreasury(
        address token,
        uint256 agentId,
        uint256 collectionId,
        uint256 amount
    );
    event WorkerAdded(uint256 agentId, uint256 collectionId);
    event WorkerUpdated(uint256 agentId, uint256 collectionId);
    event RevokeOwner(address wallet, uint256 agentId);
    event AddOwner(address wallet, uint256 agentId);
    event RevokeAgentWallet(address wallet, uint256 agentId);
    event AddAgentWallet(address wallet, uint256 agentId);

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyAgentOwner(uint256 agentId) {
        if (!_isOwner[msg.sender][agentId]) {
            revert TripleAErrors.NotAgentOwner();
        }

        _;
    }

    modifier onlyAgentCreator(uint256 agentId) {
        if (_agents[agentId].creator != msg.sender) {
            revert TripleAErrors.NotAgentCreator();
        }
        _;
    }

    modifier onlyMarket() {
        if (market != msg.sender) {
            revert TripleAErrors.OnlyMarketContract();
        }
        _;
    }

    modifier onlyCollectionManager() {
        if (address(collectionManager) != msg.sender) {
            revert TripleAErrors.OnlyCollectionContract();
        }
        _;
    }

    constructor(
        address payable _accessControls,
        address _devTreasury,
        address _collectionManager
    ) payable {
        accessControls = TripleAAccessControls(_accessControls);
        devTreasury = TripleADevTreasury(_devTreasury);
        collectionManager = TripleACollectionManager(_collectionManager);
    }

    function createAgent(
        address[] memory wallets,
        address[] memory owners,
        string memory metadata
    ) external {
        _agentCounter++;

        for (uint8 i = 0; i < owners.length; i++) {
            _isOwner[owners[i]][_agentCounter] = true;
        }

        for (uint8 i = 0; i < wallets.length; i++) {
            _isWallet[wallets[i]][_agentCounter] = true;
        }

        _agents[_agentCounter] = TripleALibrary.Agent({
            id: _agentCounter,
            metadata: metadata,
            agentWallets: wallets,
            owners: owners,
            creator: msg.sender,
            collectionIdsHistory: new uint256[](0),
            activeCollectionIds: new uint256[](0)
        });

        for (uint8 i = 0; i < wallets.length; i++) {
            accessControls.addAgent(wallets[i]);
        }

        emit AgentCreated(wallets, msg.sender, _agentCounter);
    }

    function editAgent(
        string memory metadata,
        uint256 agentId
    ) external onlyAgentOwner(agentId) {
        _agents[agentId].metadata = metadata;

        emit AgentEdited(agentId);
    }

    function deleteAgent(uint256 agentId) external onlyAgentOwner(agentId) {
        if (_agents[agentId].activeCollectionIds.length > 0) {
            revert TripleAErrors.AgentStillActive();
        }

        address[] memory _wallets = _agents[agentId].agentWallets;
        address[] memory _owners = _agents[agentId].owners;

        for (uint8 i = 0; i < _wallets.length; i++) {
            accessControls.removeAgent(_wallets[i]);
            _isWallet[_wallets[i]][_agentCounter] = false;
        }

        for (uint8 i = 0; i < _owners.length; i++) {
            _isOwner[_owners[i]][_agentCounter] = false;
        }

        for (
            uint256 i = 0;
            i < _agents[agentId].collectionIdsHistory.length;
            i++
        ) {
            delete _workers[agentId][_agents[agentId].collectionIdsHistory[i]];
        }

        delete _agents[agentId];

        emit AgentDeleted(agentId);
    }

    function addWorker(
        TripleALibrary.CollectionWorker memory worker,
        uint256 agentId,
        uint256 collectionId
    ) external onlyCollectionManager {
        if (!worker.remix && !worker.publish && !worker.lead) {
            revert TripleAErrors.InvalidWorker();
        }

        _workers[agentId][collectionId] = worker;

        emit WorkerAdded(agentId, collectionId);
    }

    function updateWorker(
        TripleALibrary.CollectionWorker memory worker,
        uint256 agentId,
        uint256 collectionId
    ) external onlyCollectionManager {
        if (!worker.remix && !worker.publish && !worker.lead) {
            revert TripleAErrors.InvalidWorker();
        }

        _workers[agentId][collectionId] = worker;

        emit WorkerUpdated(agentId, collectionId);
    }

    function revokeOwner(
        address wallet,
        uint256 agentId
    ) public onlyAgentCreator(agentId) {
        for (uint8 i = 0; i < _agents[agentId].owners.length; i++) {
            if (_agents[agentId].owners[i] == wallet) {
                _agents[agentId].owners[i] = _agents[agentId].owners[
                    _agents[agentId].owners.length - 1
                ];
                _agents[agentId].owners.pop();
                break;
            }
        }
        _isOwner[wallet][_agentCounter] = false;
        emit RevokeOwner(wallet, agentId);
    }

    function addOwner(
        address wallet,
        uint256 agentId
    ) public onlyAgentCreator(agentId) {
        _agents[agentId].owners.push(wallet);
        _isOwner[wallet][_agentCounter] = true;
        emit AddOwner(wallet, agentId);
    }

    function revokeAgentWallet(
        address wallet,
        uint256 agentId
    ) public onlyAgentOwner(agentId) {
        for (uint8 i = 0; i < _agents[agentId].agentWallets.length; i++) {
            if (_agents[agentId].agentWallets[i] == wallet) {
                _agents[agentId].agentWallets[i] = _agents[agentId]
                    .agentWallets[_agents[agentId].agentWallets.length - 1];
                _agents[agentId].agentWallets.pop();
                break;
            }
        }
        _isWallet[wallet][_agentCounter] = false;
        accessControls.removeAgent(wallet);

        emit RevokeAgentWallet(wallet, agentId);
    }

    function addAgentWallet(
        address wallet,
        uint256 agentId
    ) public onlyAgentOwner(agentId) {
        _agents[agentId].agentWallets.push(wallet);
        _isWallet[wallet][_agentCounter] = true;
        accessControls.addAgent(wallet);
        emit AddAgentWallet(wallet, agentId);
    }

    function addBalance(
        address token,
        uint256 agentId,
        uint256 amount,
        uint256 collectionId,
        bool soldOut
    ) external onlyMarket {
        uint256 _bonus = 0;
        uint256 _rent = _handleRent(token, agentId, collectionId);

        // if (soldOut) {
        //     _bonus = amount;
        // } else
        if (amount >= _rent) {
            _bonus = amount - _rent;
        }
        _agentActiveBalances[agentId][token][collectionId] += _rent;
        _agentTotalBalances[agentId][token][collectionId] += _rent;
        // }

        _agentBonusBalances[agentId][token][collectionId] += _bonus;

        uint256[] storage activeCollections = _agents[agentId]
            .activeCollectionIds;

        bool isCollectionActive = false;
        for (uint8 i = 0; i < activeCollections.length; i++) {
            if (activeCollections[i] == collectionId) {
                isCollectionActive = true;
                break;
            }
        }

        if (!isCollectionActive && !soldOut) {
            activeCollections.push(collectionId);
        } else if (soldOut) {
            for (uint8 i = 0; i < activeCollections.length; i++) {
                if (activeCollections[i] == collectionId) {
                    activeCollections[i] = activeCollections[
                        activeCollections.length - 1
                    ];
                    activeCollections.pop();
                    break;
                }
            }
        }

        bool existsInHistory = false;
        for (
            uint8 i = 0;
            i < _agents[agentId].collectionIdsHistory.length;
            i++
        ) {
            if (_agents[agentId].collectionIdsHistory[i] == collectionId) {
                existsInHistory = true;
                break;
            }
        }

        if (!existsInHistory) {
            _agents[agentId].collectionIdsHistory.push(collectionId);
        }

        emit BalanceAdded(token, agentId, amount, collectionId);
    }

    function payRent(
        address[] memory tokens,
        uint256[] memory collectionIds,
        uint256 agentId
    ) external {
        bool _isAgent = false;

        if (collectionIds.length != tokens.length) {
            revert TripleAErrors.BadUserInput();
        }

        if (accessControls.isAgent(msg.sender)) {
            for (uint8 i = 0; i < _agents[agentId].agentWallets.length; i++) {
                if (_agents[agentId].agentWallets[i] == msg.sender) {
                    _isAgent = true;
                    break;
                }
            }
        }

        if (!_isAgent) {
            revert TripleAErrors.NotAgent();
        }

        for (uint8 i = 0; i < collectionIds.length; i++) {
            if (
                _agentActiveBalances[agentId][tokens[i]][collectionIds[i]] <
                _handleRent(tokens[i], agentId, collectionIds[i])
            ) {
                revert TripleAErrors.InsufficientBalance();
            }

            if (!collectionManager.getCollectionIsActive(collectionIds[i])) {
                revert TripleAErrors.CollectionNotActive();
            }

            uint256[] memory _ids = _agents[agentId].activeCollectionIds;
            if (_ids.length < 1) {
                revert TripleAErrors.NoActiveAgents();
            } else {
                bool _notCollection = false;

                for (uint256 j = 0; j < _ids.length; j++) {
                    if (_ids[j] == collectionIds[i]) {
                        _notCollection = true;
                    }
                }

                if (!_notCollection) {
                    revert TripleAErrors.NoActiveAgents();
                }
            }
        }

        uint256[] memory _amounts = new uint256[](collectionIds.length);
        uint256[] memory _bonuses = new uint256[](collectionIds.length);
        for (uint8 i = 0; i < collectionIds.length; i++) {
            _amounts[i] = _handleRent(tokens[i], agentId, collectionIds[i]);
            _agentActiveBalances[agentId][tokens[i]][
                collectionIds[i]
            ] -= _handleRent(tokens[i], agentId, collectionIds[i]);
            _bonuses[i] = _agentBonusBalances[agentId][tokens[i]][
                collectionIds[i]
            ];
            _agentBonusBalances[agentId][tokens[i]][collectionIds[i]] = 0;
        }

        devTreasury.agentPayRent(
            tokens,
            collectionIds,
            _amounts,
            _bonuses,
            agentId
        );

        emit BalanceWithdrawn(tokens, collectionIds, _amounts, agentId);
    }

    function _handleRent(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) internal returns (uint256) {
        uint256 _rent = 0;

        if (_workers[agentId][collectionId].remix) {
            _rent += accessControls.getTokenCycleRentRemix(token);
        }

        if (_workers[agentId][collectionId].lead) {
            _rent += accessControls.getTokenCycleRentLead(token);
        }

        if (_workers[agentId][collectionId].publish) {
            _rent += accessControls.getTokenCycleRentPublish(token);
        }

        return _rent;
    }

    function sendFundsToTreasury(
        address token,
        uint256 agentId,
        uint256 amount,
        uint256 collectionId
    ) external onlyAdmin {
        if (amount > _agentActiveBalances[agentId][token][collectionId]) {
            revert TripleAErrors.InsufficientBalance();
        }

        _agentActiveBalances[agentId][token][collectionId] -= amount;

        devTreasury.receiveTreasury(token, amount);

        emit SwapFundsToTreasury(token, agentId, collectionId, amount);
    }

    function rechargeAgentActiveBalance(
        address token,
        uint256 agentId,
        uint256 collectionId,
        uint256 amount
    ) public {
        if (
            collectionManager.getCollectionAmountSold(collectionId) >=
            collectionManager.getCollectionAmount(collectionId)
        ) {
            revert TripleAErrors.CollectionSoldOut();
        }
        uint256[] memory _ids = collectionManager.getCollectionAgentIds(
            collectionId
        );

        if (_ids.length < 1) {
            revert TripleAErrors.NoActiveAgents();
        } else {
            bool _notAgent = false;

            for (uint8 i = 0; i < _ids.length; i++) {
                if (_ids[i] == agentId) {
                    _notAgent = true;
                }
            }

            if (!_notAgent) {
                revert TripleAErrors.NoActiveAgents();
            }
        }

        address[] memory _tokens = collectionManager.getCollectionERC20Tokens(
            collectionId
        );
        bool _exists = false;

        for (uint8 i = 0; i < _tokens.length; i++) {
            if (_tokens[i] == token) {
                _exists = true;
                break;
            }
        }
        if (!_exists) {
            revert TripleAErrors.TokenNotAccepted();
        }

        if (
            !IERC20(token).transferFrom(
                msg.sender,
                address(devTreasury),
                amount
            )
        ) {
            revert TripleAErrors.PaymentFailed();
        } else {
            devTreasury.receiveFunds(msg.sender, token, amount);

            _agentActiveBalances[agentId][token][collectionId] += amount;
            _agentTotalBalances[agentId][token][collectionId] += amount;

            uint256[] storage activeCollections = _agents[agentId]
                .activeCollectionIds;

            bool isCollectionActive = false;
            for (uint8 i = 0; i < activeCollections.length; i++) {
                if (activeCollections[i] == collectionId) {
                    isCollectionActive = true;
                    break;
                }
            }

            activeCollections.push(collectionId);

            bool existsInHistory = false;
            for (
                uint8 i = 0;
                i < _agents[agentId].collectionIdsHistory.length;
                i++
            ) {
                if (_agents[agentId].collectionIdsHistory[i] == collectionId) {
                    existsInHistory = true;
                    break;
                }
            }

            if (!existsInHistory) {
                _agents[agentId].collectionIdsHistory.push(collectionId);
            }

            emit AgentRecharged(
                msg.sender,
                token,
                agentId,
                collectionId,
                amount
            );
        }
    }

    function excessAgent(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) external onlyAdmin {
        uint256 _amount = _agentActiveBalances[agentId][token][collectionId];
        _agentActiveBalances[agentId][token][collectionId] = 0;

        devTreasury.addToServices(token, _amount);

        emit ExcessAgent(token, _amount, agentId, collectionId);
    }

    function getAgentCounter() public view returns (uint256) {
        return _agentCounter;
    }

    function getAgentWallets(
        uint256 agentId
    ) public view returns (address[] memory) {
        return _agents[agentId].agentWallets;
    }

    function getAgentMetadata(
        uint256 agentId
    ) public view returns (string memory) {
        return _agents[agentId].metadata;
    }

    function getAgentActiveBalance(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) public view returns (uint256) {
        return _agentActiveBalances[agentId][token][collectionId];
    }

    function getAgentTotalBalance(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) public view returns (uint256) {
        return _agentTotalBalances[agentId][token][collectionId];
    }

    function getAgentBonusBalance(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) public view returns (uint256) {
        return _agentBonusBalances[agentId][token][collectionId];
    }

    function getAgentCollectionIdsHistory(
        uint256 agentId
    ) public view returns (uint256[] memory) {
        return _agents[agentId].collectionIdsHistory;
    }

    function getAgentOwners(
        uint256 agentId
    ) public view returns (address[] memory) {
        return _agents[agentId].owners;
    }

    function getAgentCreator(uint256 agentId) public view returns (address) {
        return _agents[agentId].creator;
    }

    function getAgentActiveCollectionIds(
        uint256 agentId
    ) public view returns (uint256[] memory) {
        return _agents[agentId].activeCollectionIds;
    }

    function getIsWallet(
        address wallet,
        uint256 agentId
    ) public view returns (bool) {
        return _isWallet[wallet][agentId];
    }

    function getIsOwner(
        address owner,
        uint256 agentId
    ) public view returns (bool) {
        return _isOwner[owner][agentId];
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function setDevTreasury(address _devTreasury) external onlyAdmin {
        devTreasury = TripleADevTreasury(_devTreasury);
    }

    function setMarket(address _market) external onlyAdmin {
        market = _market;
    }

    function setCollectionManager(
        address _collectionManager
    ) external onlyAdmin {
        collectionManager = TripleACollectionManager(_collectionManager);
    }
}
