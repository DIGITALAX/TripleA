// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./AAAErrors.sol";
import "./AAALibrary.sol";
import "./AAAAccessControls.sol";
import "./AAADevTreasury.sol";
import "./AAACollectionManager.sol";

contract AAAAgents {
    uint256 private _agentCounter;
    address public market;
    AAAAccessControls public accessControls;
    AAACollectionManager public collectionManager;
    AAADevTreasury public devTreasury;
    mapping(uint256 => AAALibrary.Agent) private _agents;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentActiveBalances;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentTotalBalances;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentBonusBalances;

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

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert AAAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyAgentOwner(uint256 agentId) {
        if (_agents[agentId].owner != msg.sender) {
            revert AAAErrors.NotAgentOwner();
        }
        _;
    }

    modifier onlyMarket() {
        if (market != msg.sender) {
            revert AAAErrors.OnlyMarketContract();
        }
        _;
    }

    constructor(
        address  _accessControls,
        address _devTreasury,
        address _collectionManager
    )  {
        accessControls = AAAAccessControls(_accessControls);
        devTreasury = AAADevTreasury(_devTreasury);
        collectionManager = AAACollectionManager(_collectionManager);
    }

    function createAgent(
        address[] memory wallets,
        string memory metadata
    ) external {
        _agentCounter++;

        _agents[_agentCounter] = AAALibrary.Agent({
            id: _agentCounter,
            metadata: metadata,
            wallets: wallets,
            owner: msg.sender,
            collectionIdsHistory: new uint256[](0),
            activeCollectionIds: new uint256[](0)
        });

        for (uint256 i = 0; i < wallets.length; i++) {
            accessControls.addAgent(wallets[i]);
        }

        emit AgentCreated(wallets, msg.sender, _agentCounter);
    }

    function editAgent(
        address[] memory wallets,
        string memory metadata,
        uint256 agentId
    ) external onlyAgentOwner(agentId) {
        _agents[agentId] = AAALibrary.Agent({
            id: agentId,
            metadata: metadata,
            wallets: wallets,
            owner: msg.sender,
            collectionIdsHistory: _agents[agentId].collectionIdsHistory,
            activeCollectionIds: _agents[agentId].activeCollectionIds
        });

        emit AgentEdited(agentId);
    }

    function deleteAgent(uint256 agentId) external onlyAgentOwner(agentId) {
        if (_agents[agentId].activeCollectionIds.length > 0) {
            revert AAAErrors.AgentStillActive();
        }

        address[] memory _wallets = _agents[agentId].wallets;

        for (uint256 i = 0; i < _wallets.length; i++) {
            accessControls.removeAgent(_wallets[i]);
        }

        delete _agents[agentId];

        emit AgentDeleted(agentId);
    }

    function addBalance(
        address token,
        uint256 agentId,
        uint256 amount,
        uint256 collectionId,
        bool soldOut
    ) external onlyMarket {
        uint256 _bonus = 0;
        uint256 _rent = accessControls.getTokenDailyRent(token);

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
        for (uint256 i = 0; i < activeCollections.length; i++) {
            if (activeCollections[i] == collectionId) {
                isCollectionActive = true;
                break;
            }
        }

        if (!isCollectionActive && !soldOut) {
            activeCollections.push(collectionId);
        } else if (soldOut) {
            for (uint256 i = 0; i < activeCollections.length; i++) {
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
            uint256 i = 0;
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
            revert AAAErrors.BadUserInput();
        }

        if (accessControls.isAgent(msg.sender)) {
            for (uint256 i = 0; i < _agents[agentId].wallets.length; i++) {
                if (_agents[agentId].wallets[i] == msg.sender) {
                    _isAgent = true;
                    break;
                }
            }
        }

        if (!_isAgent) {
            revert AAAErrors.NotAgent();
        }

        for (uint256 i = 0; i < collectionIds.length; i++) {
            if (
                _agentActiveBalances[agentId][tokens[i]][collectionIds[i]] <
                accessControls.getTokenDailyRent(tokens[i])
            ) {
                revert AAAErrors.InsufficientBalance();
            }

            if (!collectionManager.getCollectionIsActive(collectionIds[i])) {
                revert AAAErrors.CollectionNotActive();
            }

            uint256[] memory _ids = _agents[agentId].activeCollectionIds;
            if (_ids.length < 1) {
                revert AAAErrors.NoActiveAgents();
            } else {
                bool _notCollection = false;

                for (uint256 j = 0; j < _ids.length; j++) {
                    if (_ids[j] == collectionIds[i]) {
                        _notCollection = true;
                    }
                }

                if (!_notCollection) {
                    revert AAAErrors.NoActiveAgents();
                }
            }
        }

        uint256[] memory _amounts = new uint256[](collectionIds.length);
        uint256[] memory _bonuses = new uint256[](collectionIds.length);
        for (uint256 i = 0; i < collectionIds.length; i++) {
            _amounts[i] = accessControls.getTokenDailyRent(tokens[i]);
            _agentActiveBalances[agentId][tokens[i]][
                collectionIds[i]
            ] -= accessControls.getTokenDailyRent(tokens[i]);
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

    function sendFundsToTreasury(
        address token,
        uint256 agentId,
        uint256 amount,
        uint256 collectionId
    ) external onlyAdmin {
        if (amount > _agentActiveBalances[agentId][token][collectionId]) {
            revert AAAErrors.InsufficientBalance();
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
            revert AAAErrors.CollectionSoldOut();
        }
        uint256[] memory _ids = collectionManager.getCollectionAgentIds(
            collectionId
        );

        if (_ids.length < 1) {
            revert AAAErrors.NoActiveAgents();
        } else {
            bool _notAgent = false;

            for (uint256 i = 0; i < _ids.length; i++) {
                if (_ids[i] == agentId) {
                    _notAgent = true;
                }
            }

            if (!_notAgent) {
                revert AAAErrors.NoActiveAgents();
            }
        }

        address[] memory _tokens = collectionManager.getCollectionERC20Tokens(
            collectionId
        );
        bool _exists = false;

        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_tokens[i] == token) {
                _exists = true;
                break;
            }
        }
        if (!_exists) {
            revert AAAErrors.TokenNotAccepted();
        }

        if (
            !IERC20(token).transferFrom(
                msg.sender,
                address(devTreasury),
                amount
            )
        ) {
            revert AAAErrors.PaymentFailed();
        } else {
            devTreasury.receiveFunds(msg.sender, token, amount);

            _agentActiveBalances[agentId][token][collectionId] += amount;
            _agentTotalBalances[agentId][token][collectionId] += amount;

            uint256[] storage activeCollections = _agents[agentId]
                .activeCollectionIds;

            bool isCollectionActive = false;
            for (uint256 i = 0; i < activeCollections.length; i++) {
                if (activeCollections[i] == collectionId) {
                    isCollectionActive = true;
                    break;
                }
            }

            activeCollections.push(collectionId);

            bool existsInHistory = false;
            for (
                uint256 i = 0;
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
        return _agents[agentId].wallets;
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

    function getAgentOwner(uint256 agentId) public view returns (address) {
        return _agents[agentId].owner;
    }

    function getAgentActiveCollectionIds(
        uint256 agentId
    ) public view returns (uint256[] memory) {
        return _agents[agentId].activeCollectionIds;
    }

    function setAccessControls(
        address  _accessControls
    ) external onlyAdmin {
        accessControls = AAAAccessControls(_accessControls);
    }

    function setDevTreasury(address _devTreasury) external onlyAdmin {
        devTreasury = AAADevTreasury(_devTreasury);
    }

    function setMarket(address _market) external onlyAdmin {
        market = _market;
    }

    function setCollectionManager(
        address _collectionManager
    ) external onlyAdmin {
        collectionManager = AAACollectionManager(_collectionManager);
    }
}
