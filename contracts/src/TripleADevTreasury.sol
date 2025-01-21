// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleAErrors.sol";
import "./TripleAAccessControls.sol";
import "./TripleAAgents.sol";
import "./TripleAMarket.sol";
import "./TripleAMeme.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TripleADevTreasury {
    TripleAAccessControls public accessControls;
    TripleAAgents public agents;
    TripleAMarket public market;
    TripleAMeme public meme;
    uint256 public ownerAmountPercent;
    uint256 public distributionAmountPercent;
    uint256 public devAmountPercent;
    mapping(address => uint256) private _balance;
    mapping(address => uint256) private _services;
    mapping(address => uint256) private _treasury;
    mapping(uint256 => mapping(address => uint256)) private _collectorPayment;
    mapping(address => uint256) private _allTimeBalance;
    mapping(address => uint256) private _allTimeServices;
    mapping(address => uint256) private _collectorsMemeActivated;
    mapping(address => uint256) private _ownersMemeActivated;

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyAgents() {
        if (msg.sender != address(agents)) {
            revert TripleAErrors.OnlyAgentsContract();
        }

        _;
    }

    event FundsReceived(
        address indexed buyer,
        address indexed token,
        uint256 amount
    );
    event FundsWithdrawnTreasury(address indexed token, uint256 amount);
    event FundsWithdrawnServices(address indexed token, uint256 amount);
    event FundsWithdrawnWithoutReceive(address indexed token, uint256 amount);
    event TreasuryReceived(address token, uint256 amount);
    event AgentPaidRent(
        address[] tokens,
        uint256[] collectionIds,
        uint256[] amounts,
        uint256[] bonuses,
        uint256 indexed agentId
    );
    event OrderPayment(address token, address recipient, uint256 amount);
    event AgentOwnerPaid(address token, address owner, uint256 amount);
    event AddToServices(address token, uint256 amount);
    event DevTreasuryAdded(address token, uint256 amount);
    event CollectorMemeActivated(address collector, uint256 amount);
    event AgentOwnerMemeActivated(address owner, uint256 amount);
    event AgentOwnerMemeAllocation(
        address token,
        address owner,
        uint256 amount
    );
    event CollectorMemeAllocation(
        address token,
        address collector,
        uint256 amount
    );

    constructor(address payable _accessControls) payable {
        accessControls = TripleAAccessControls(_accessControls);
        ownerAmountPercent = 30;
        distributionAmountPercent = 30;
        devAmountPercent = 40;
    }

    function receiveFunds(
        address buyer,
        address paymentToken,
        uint256 amount
    ) external {
        if (msg.sender != address(market) && msg.sender != address(agents)) {
            revert TripleAErrors.OnlyMarketOrAgentContract();
        }

        _balance[paymentToken] += amount;
        _allTimeBalance[paymentToken] += amount;

        emit FundsReceived(buyer, paymentToken, amount);
    }

    function receiveTreasury(
        address token,
        uint256 amount
    ) external onlyAgents {
        _treasury[token] += amount;

        emit TreasuryReceived(token, amount);
    }

    function withdrawFundsTreasury(
        address token,
        uint256 amount
    ) external onlyAdmin {
        if (amount > _treasury[token]) {
            revert TripleAErrors.InsufficientBalance();
        }
        IERC20(token).transfer(msg.sender, amount);
        _balance[token] -= amount;
        _treasury[token] -= amount;

        emit FundsWithdrawnTreasury(token, amount);
    }

    function withdrawFundsWithoutReceive(
        address token,
        uint256 amount
    ) external onlyAdmin {
        IERC20(token).transfer(msg.sender, amount);

        emit FundsWithdrawnWithoutReceive(token, amount);
    }

    function withdrawFundsServices(
        address token,
        uint256 amount
    ) external onlyAdmin {
        if (amount > _services[token]) {
            revert TripleAErrors.InsufficientBalance();
        }

        IERC20(token).transfer(msg.sender, amount);
        _balance[token] -= amount;
        _services[token] -= amount;

        emit FundsWithdrawnServices(token, amount);
    }

    function addToServices(address token, uint256 amount) external onlyAgents {
        _services[token] += amount;
        _allTimeServices[token] += amount;

        emit AddToServices(token, amount);
    }

    function agentPayRent(
        address[] memory tokens,
        uint256[] memory collectionIds,
        uint256[] memory amounts,
        uint256[] memory bonuses,
        uint256 agentId
    ) external onlyAgents {
        address[] memory _owners = agents.getAgentOwners(agentId);

        for (uint8 i = 0; i < collectionIds.length; i++) {
            _services[tokens[i]] += amounts[i];
            _allTimeServices[tokens[i]] += amounts[i];

            if (bonuses[i] > 0) {
                _handleBonus(_owners, tokens[i], bonuses[i], collectionIds[i]);
            }
        }

        emit AgentPaidRent(tokens, collectionIds, amounts, bonuses, agentId);
    }

    function _handleBonus(
        address[] memory owners,
        address token,
        uint256 bonus,
        uint256 collectionId
    ) internal {
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

                _memeSplitCollector(
                    token,
                    _collectors[j],
                    payment,
                    collectionId
                );
            }
        }

        for (uint8 i = 0; i < owners.length; i++) {
            _memeSplitOwner(token, owners[i], _ownerAmount / owners.length);
        }

        _treasury[token] += _devAmount;
        emit DevTreasuryAdded(token, _devAmount);
    }

    function _memeSplitOwner(
        address token,
        address owner,
        uint256 amount
    ) internal {
        if (_ownersMemeActivated[owner] > 0) {
            uint256 _meme = (_ownersMemeActivated[owner] * amount) / 100;
            uint256 _paid = 0;
            if (amount > _meme) {
                _paid = amount - _meme;
            }

            if (IERC20(token).transfer(owner, _meme)) {
                emit AgentOwnerMemeAllocation(token, owner, _meme);
            }

            if (_paid > 0) {
                if (IERC20(token).transfer(owner, _paid)) {
                    emit AgentOwnerPaid(token, owner, _paid);
                }
            }
        } else {
            if (IERC20(token).transfer(owner, amount)) {
                emit AgentOwnerPaid(token, owner, amount);
            }
        }
    }

    function _memeSplitCollector(
        address token,
        address collector,
        uint256 amount,
        uint256 collectionId
    ) internal {
        if (_collectorsMemeActivated[collector] > 0) {
            uint256 _meme = (_collectorsMemeActivated[collector] * amount) /
                100;
            uint256 _paid = 0;
            if (amount > _meme) {
                _paid = amount - _meme;
            }

            if (IERC20(token).transfer(collector, _meme)) {
                emit CollectorMemeAllocation(token, collector, _meme);
            }

            if (_paid > 0) {
                if (IERC20(token).transfer(collector, _paid)) {
                    _collectorPayment[collectionId][collector] += _paid;
                    emit OrderPayment(token, collector, _paid);
                }
            }
        } else {
            if (IERC20(token).transfer(collector, amount)) {
                _collectorPayment[collectionId][collector] += amount;
                emit OrderPayment(token, collector, amount);
            }
        }
    }

    function getBalanceByToken(address token) public view returns (uint256) {
        return _balance[token];
    }

    function getServicesPaidByToken(
        address token
    ) public view returns (uint256) {
        return _services[token];
    }

    function getAllTimeBalanceByToken(
        address token
    ) public view returns (uint256) {
        return _allTimeBalance[token];
    }

    function getAllTimeServices(address token) public view returns (uint256) {
        return _allTimeServices[token];
    }

    function getTreasuryByToken(address token) public view returns (uint256) {
        return _treasury[token];
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function setAgents(address _agents) external onlyAdmin {
        agents = TripleAAgents(_agents);
    }

    function setMarket(address _market) external onlyAdmin {
        market = TripleAMarket(_market);
    }

    function setMeme(address payable _meme) external onlyAdmin {
        meme = TripleAMeme(_meme);
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

    function getCollectorMemeActivated(
        address collector
    ) public view returns (uint256) {
        return _collectorsMemeActivated[collector];
    }

    function getAgentOwnerMemeActivated(
        address owner
    ) public view returns (uint256) {
        return _ownersMemeActivated[owner];
    }

    function setCollectorMemeActivated(uint256 amount) public {
        _collectorsMemeActivated[msg.sender] = amount;
        emit CollectorMemeActivated(msg.sender, amount);
    }

    function setAgentOwnerMemeActivated(uint256 amount) public {
        _ownersMemeActivated[msg.sender] = amount;
        emit AgentOwnerMemeActivated(msg.sender, amount);
    }

    receive() external payable {}

    fallback() external payable {}
}
