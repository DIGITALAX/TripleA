// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleAErrors.sol";
import "./TripleALibrary.sol";
import "./TripleAAccessControls.sol";
import "./TripleACollectionManager.sol";
import "./TripleAMarket.sol";
import "./skyhunters/SkyhuntersAgentManager.sol";
import "./skyhunters/SkyhuntersAccessControls.sol";
import "./skyhunters/SkyhuntersPoolManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TripleAAgents {
    address public rewards;
    uint256 public ownerAmountPercent;
    uint256 public distributionAmountPercent;
    uint256 public devAmountPercent;
    TripleAAccessControls public accessControls;
    TripleAMarket public market;
    SkyhuntersAccessControls public skyhuntersAccessControls;
    SkyhuntersPoolManager public poolManager;
    SkyhuntersAgentManager public agentManager;
    TripleACollectionManager public collectionManager;

    mapping(uint256 => TripleALibrary.Agent) private _activatedAgents;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentRentBalances;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentHistoricalRentBalances;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentBonusBalances;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _agentHistoricalBonusBalances;
    mapping(uint256 => mapping(uint256 => TripleALibrary.CollectionWorker))
        private _workers;
    mapping(address => uint256) private _services;
    mapping(address => uint256) private _allTimeServices;
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        private _collectorPayment;
    mapping(address => mapping(address => mapping(uint256 => uint256)))
        private _ownerPayment;
    mapping(address => uint256) private _devPayment;
    mapping(address => uint256) private _currentRewards;
    mapping(address => uint256) private _rewardsHistory;

    event ActivateAgent(address wallet, uint256 agentId);
    event BalanceAdded(
        address token,
        uint256 agentId,
        uint256 amount,
        uint256 collectionId
    );
    event RewardsCalculated(address token, uint256 amount);
    event AgentPaidRent(
        address[] tokens,
        uint256[] collectionIds,
        uint256[] amounts,
        uint256[] bonuses,
        uint256 indexed agentId
    );
    event AgentRecharged(
        address recharger,
        address token,
        uint256 agentId,
        uint256 collectionId,
        uint256 amount
    );
    event WorkerAdded(uint256 agentId, uint256 collectionId);
    event WorkerUpdated(uint256 agentId, uint256 collectionId);

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyRewards() {
        if (msg.sender != rewards) {
            revert TripleAErrors.OnlyRewardsContract();
        }
        _;
    }

    modifier onlyAgentOwnerOrCreator(uint256 agentId) {
        if (
            !agentManager.getIsAgentOwner(msg.sender, agentId) &&
            agentManager.getAgentCreator(agentId) != msg.sender
        ) {
            revert TripleAErrors.NotAgentOwner();
        }

        _;
    }

    modifier onlyAgentCreator(uint256 agentId) {
        if (agentManager.getAgentCreator(agentId) != msg.sender) {
            revert TripleAErrors.NotAgentCreator();
        }
        _;
    }

    modifier onlyMarket() {
        if (address(market) != msg.sender) {
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
        address _collectionManager,
        address _skyhuntersAccessControls
    ) payable {
        accessControls = TripleAAccessControls(_accessControls);
        collectionManager = TripleACollectionManager(_collectionManager);
        skyhuntersAccessControls = SkyhuntersAccessControls(
            _skyhuntersAccessControls
        );
    }

    function activateAgent(
        uint256 agentId
    ) external onlyAgentOwnerOrCreator(agentId) {
        agentManager.setAgentActive(agentId);

        _activatedAgents[agentId] = TripleALibrary.Agent({
            collectionIdsHistory: new uint256[](0),
            activeCollectionIds: new uint256[](0)
        });

        emit ActivateAgent(msg.sender, agentId);
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

    function addBalance(
        address token,
        uint256 agentId,
        uint256 amount,
        uint256 collectionId,
        bool soldOut
    ) external onlyMarket {
        uint256 _bonus = 0;
        uint256 _rent = _handleRent(token, agentId, collectionId);

        if (amount >= _rent) {
            _bonus = amount - _rent;
        }
        _agentRentBalances[agentId][token][collectionId] += _rent;
        _agentHistoricalRentBalances[agentId][token][collectionId] += _rent;

        _agentBonusBalances[agentId][token][collectionId] += _bonus;
        _agentHistoricalBonusBalances[agentId][token][collectionId] += _bonus;

        uint256[] storage activeCollections = _activatedAgents[agentId]
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
            i < _activatedAgents[agentId].collectionIdsHistory.length;
            i++
        ) {
            if (
                _activatedAgents[agentId].collectionIdsHistory[i] ==
                collectionId
            ) {
                existsInHistory = true;
                break;
            }
        }

        if (!existsInHistory) {
            _activatedAgents[agentId].collectionIdsHistory.push(collectionId);
        }

        emit BalanceAdded(token, agentId, amount, collectionId);
    }

    function payRent(
        address[] memory tokens,
        uint256[] memory collectionIds,
        uint256 agentId
    ) external {
        if (collectionIds.length != tokens.length) {
            revert TripleAErrors.BadUserInput();
        }

        if (skyhuntersAccessControls.isAgent(msg.sender)) {
            revert TripleAErrors.NotAgent();
        }

        for (uint8 i = 0; i < collectionIds.length; i++) {
            if (
                _agentRentBalances[agentId][tokens[i]][collectionIds[i]] <
                _handleRent(tokens[i], agentId, collectionIds[i])
            ) {
                revert TripleAErrors.InsufficientBalance();
            }

            if (!collectionManager.getCollectionIsActive(collectionIds[i])) {
                revert TripleAErrors.CollectionNotActive();
            }

            uint256[] memory _ids = _activatedAgents[agentId]
                .activeCollectionIds;
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
            _agentRentBalances[agentId][tokens[i]][
                collectionIds[i]
            ] -= _handleRent(tokens[i], agentId, collectionIds[i]);
            _bonuses[i] = _agentBonusBalances[agentId][tokens[i]][
                collectionIds[i]
            ];
            _agentBonusBalances[agentId][tokens[i]][collectionIds[i]] = 0;
        }

        for (uint8 i = 0; i < collectionIds.length; i++) {
            _services[tokens[i]] += _amounts[i];
            _allTimeServices[tokens[i]] += _amounts[i];

            if (_bonuses[i] > 0) {
                _handleBonus(tokens[i], agentId, _bonuses[i], collectionIds[i]);
            }
        }

        emit AgentPaidRent(tokens, collectionIds, _amounts, _bonuses, agentId);
    }

    function _handleRent(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) internal view returns (uint256) {
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

    function _handleBonus(
        address token,
        uint256 agentId,
        uint256 bonus,
        uint256 collectionId
    ) internal {
        address[] memory _owners = agentManager.getAgentOwners(agentId);
        _currentRewards[token] += bonus;
        _rewardsHistory[token] += bonus;

        uint256 _ownerAmount = (bonus * ownerAmountPercent) / 100;
        uint256 _devAmount = (bonus * devAmountPercent) / 100;
        uint256 _distributionAmount = (bonus * distributionAmountPercent) / 100;

        address[] memory _collectors = market.getAllCollectorsByCollectionId(
            collectionId
        );

        uint256 totalWeight = 0;
        for (uint256 j = 1; j <= _collectors.length; j++) {
            totalWeight += 1e18 / j;
        }

        for (uint256 j = 0; j < _collectors.length; j++) {
            if (_collectors[j] != address(0)) {
                uint256 weight = 1e18 / (j + 1);
                uint256 payment = (_distributionAmount * weight) / totalWeight;

                _collectorPayment[token][_collectors[j]][
                    collectionId
                ] += payment;
            }
        }

        for (uint8 i = 0; i < _owners.length; i++) {
            _ownerPayment[token][_owners[i]][collectionId] +=
                _ownerAmount /
                _owners.length;
        }

        _devPayment[token] += _devAmount;
    }

    function rechargeAgentRentBalance(
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

        if (!IERC20(token).transferFrom(msg.sender, address(this), amount)) {
            revert TripleAErrors.PaymentFailed();
        } else {
            _agentRentBalances[agentId][token][collectionId] += amount;
            _agentHistoricalRentBalances[agentId][token][
                collectionId
            ] += amount;

            uint256[] storage activeCollections = _activatedAgents[agentId]
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
                i < _activatedAgents[agentId].collectionIdsHistory.length;
                i++
            ) {
                if (
                    _activatedAgents[agentId].collectionIdsHistory[i] ==
                    collectionId
                ) {
                    existsInHistory = true;
                    break;
                }
            }

            if (!existsInHistory) {
                _activatedAgents[agentId].collectionIdsHistory.push(
                    collectionId
                );
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

    function handleRewardsCalc() external onlyRewards {
        address[] memory _tokens = skyhuntersAccessControls.getAllTokens();

        for (uint8 i = 0; i < _tokens.length; i++) {
            IERC20(_tokens[i]).transfer(
                address(poolManager),
                _currentRewards[_tokens[i]]
            );
            poolManager.receiveRewards(_tokens[i], _currentRewards[_tokens[i]]);
            _currentRewards[_tokens[i]] = 0;
            emit RewardsCalculated(_tokens[i], _currentRewards[_tokens[i]]);
        }
    }

    function getAgentRentBalance(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) public view returns (uint256) {
        return _agentRentBalances[agentId][token][collectionId];
    }

    function getAgentHistoricalRentBalance(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) public view returns (uint256) {
        return _agentHistoricalRentBalances[agentId][token][collectionId];
    }

    function getAgentHistoricalBonusBalance(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) public view returns (uint256) {
        return _agentHistoricalBonusBalances[agentId][token][collectionId];
    }

    function getAgentBonusBalance(
        address token,
        uint256 agentId,
        uint256 collectionId
    ) public view returns (uint256) {
        return _agentBonusBalances[agentId][token][collectionId];
    }

    function getAllTimeServices(address token) public view returns (uint256) {
        return _allTimeServices[token];
    }

    function getServicesPaidByToken(
        address token
    ) public view returns (uint256) {
        return _services[token];
    }

    function getAgentCollectionIdsHistory(
        uint256 agentId
    ) public view returns (uint256[] memory) {
        return _activatedAgents[agentId].collectionIdsHistory;
    }

    function getAgentActiveCollectionIds(
        uint256 agentId
    ) public view returns (uint256[] memory) {
        return _activatedAgents[agentId].activeCollectionIds;
    }

    function getCollectorPaymentByToken(
        address token,
        address collector,
        uint256 collectionId
    ) public view returns (uint256) {
        return _collectorPayment[token][collector][collectionId];
    }

    function getAgentOwnerPaymentByToken(
        address token,
        address owner,
        uint256 collectionId
    ) public view returns (uint256) {
        return _ownerPayment[token][owner][collectionId];
    }

    function getDevPaymentByToken(address token) public view returns (uint256) {
        return _devPayment[token];
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function setSkyhuntersRewards(address _rewards) external onlyAdmin {
        rewards = _rewards;
    }

    function setSkyhuntersAccessControls(
        address _skyhuntersAccessControls
    ) external onlyAdmin {
        skyhuntersAccessControls = SkyhuntersAccessControls(
            _skyhuntersAccessControls
        );
    }

    function setMarket(address _market) external onlyAdmin {
        market = TripleAMarket(_market);
    }

    function setCollectionManager(
        address _collectionManager
    ) external onlyAdmin {
        collectionManager = TripleACollectionManager(_collectionManager);
    }

    function setSkyhuntersPoolManager(
        address payable _poolManager
    ) external onlyAdmin {
        poolManager = SkyhuntersPoolManager(_poolManager);
    }

    function setAmounts(
        uint256 _ownerAmountPercent,
        uint256 _distributionAmountPercent,
        uint256 _devAmountPercent
    ) external onlyAdmin {
        if (
            ownerAmountPercent + distributionAmountPercent + devAmountPercent !=
            100
        ) {
            revert TripleAErrors.BadUserInput();
        }
        ownerAmountPercent = _ownerAmountPercent;
        distributionAmountPercent = _distributionAmountPercent;
        devAmountPercent = _devAmountPercent;
    }

    receive() external payable {}

    fallback() external payable {}
}
