// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleAErrors.sol";
import "./TripleAAccessControls.sol";
import "./TripleAAgents.sol";
import "./TripleAMarket.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TripleADevTreasury {
    TripleAAccessControls public accessControls;
    TripleAAgents public agents;
    TripleAMarket public market;
    uint256 public ownerAmountPercent;
    uint256 public distributionAmountPercent;
    uint256 public devAmountPercent;
    mapping(address => uint256) private _balance;
    mapping(address => uint256) private _services;
    mapping(address => uint256) private _treasury;
    mapping(uint256 => mapping(address => uint256)) private _collectorPayment;
    mapping(address => uint256) private _allTimeBalance;
    mapping(address => uint256) private _allTimeServices;

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

                _collectorPayment[collectionId][_collectors[j]] = payment;

                if (IERC20(token).transfer(_collectors[j], payment)) {
                    emit OrderPayment(token, _collectors[j], payment);
                }
            }
        }

        for (uint8 i = 0; i < owners.length; i++) {
            if (
                IERC20(token).transfer(owners[i], _ownerAmount / owners.length)
            ) {
                emit AgentOwnerPaid(
                    token,
                    owners[i],
                    _ownerAmount / owners.length
                );
            }
        }

        _treasury[token] += _devAmount;
        emit DevTreasuryAdded(token, _devAmount);
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
}
