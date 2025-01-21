// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleALibrary.sol";
import "./TripleANFT.sol";
import "./TripleAAccessControls.sol";
import "./TripleACollectionManager.sol";
import "./TripleAAgents.sol";
import "./TripleADevTreasury.sol";
import "./TripleAFulfillerManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TripleAMarket {
    uint256 private _orderCounter;
    TripleANFT public nft;
    TripleACollectionManager public collectionManager;
    TripleAFulfillerManager public fulfillerManager;
    TripleAAccessControls public accessControls;
    TripleAAgents public agents;
    TripleADevTreasury public devTreasury;

    mapping(address => uint256[]) private _buyerToOrderIds;
    mapping(uint256 => TripleALibrary.Order) private _orders;
    mapping(uint256 => address[]) private _allCollectorsByCollectionIds;

    event CollectionPurchased(
        address buyer,
        address paymentToken,
        uint256 orderId,
        uint256 collectionId,
        uint256 amount,
        uint256 artistShare,
        uint256 fulfillerShare
    );

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyFulfillerManager() {
        if (msg.sender != address(fulfillerManager)) {
            revert TripleAErrors.OnlyFulfillerManager();
        }
        _;
    }

    constructor(
        address _nft,
        address _collectionManager,
        address payable _accessControls,
        address _agents,
        address _fulfillerManager
    ) payable {
        nft = TripleANFT(_nft);
        collectionManager = TripleACollectionManager(_collectionManager);
        accessControls = TripleAAccessControls(_accessControls);
        agents = TripleAAgents(_agents);
        fulfillerManager = TripleAFulfillerManager(_fulfillerManager);
    }

    function buy(
        string memory fulfillmentDetails,
        address paymentToken,
        uint256 collectionId,
        uint256 amount
    ) external {
        if (!collectionManager.getCollectionIsActive(collectionId)) {
            revert TripleAErrors.CollectionNotActive();
        }

        uint256 _amount = collectionManager.getCollectionAmount(collectionId);
        if (
            amount + collectionManager.getCollectionAmountSold(collectionId) >
            _amount
        ) {
            revert TripleAErrors.NotAvailable();
        }

        uint256 _tokenPrice = _checkTokens(paymentToken, collectionId);
        uint256 _totalPrice = _tokenPrice * amount;
        (
            uint256 _artistShare,
            uint256 _fulfillerShare,
            address _fulfiller
        ) = _manageCollectionType(paymentToken, _totalPrice, collectionId);
        uint256 _perAgentShare = 0;
        uint256 _agentShare = 0;

        if (
            collectionManager.getCollectionAmountSold(collectionId) == 0 &&
            amount > 1
        ) {
            _artistShare = _tokenPrice;
            uint256 _additionalUnits = amount - 1;

            if (
                collectionManager.getCollectionAmount(collectionId) > 2 &&
                collectionManager.getCollectionPrices(collectionId)[0] >
                accessControls.getTokenThreshold(paymentToken) &&
                collectionManager.getCollectionAgentIds(collectionId).length > 0
            ) {
                _agentShare = (_additionalUnits * _tokenPrice * 10) / 100;

                _perAgentShare =
                    _agentShare /
                    collectionManager
                        .getCollectionAgentIds(collectionId)
                        .length;

                uint256 _artistShareForAdditionalUnits = (_additionalUnits *
                    _tokenPrice *
                    90) / 100;
                _artistShare += _artistShareForAdditionalUnits;
            }
        } else {
            if (
                collectionManager.getCollectionAmountSold(collectionId) +
                    amount >
                1 &&
                collectionManager.getCollectionAmount(collectionId) > 2 &&
                collectionManager.getCollectionPrices(collectionId)[0] >
                accessControls.getTokenThreshold(paymentToken) &&
                collectionManager.getCollectionAgentIds(collectionId).length > 0
            ) {
                _agentShare = (_totalPrice * 10) / 100;

                _perAgentShare =
                    _agentShare /
                    collectionManager
                        .getCollectionAgentIds(collectionId)
                        .length;

                if (_agentShare < _totalPrice) {
                    _artistShare = _totalPrice - _agentShare;
                }
            }
        }

        if (_agentShare > 0) {
            if (IERC20(paymentToken).balanceOf(msg.sender) < _agentShare) {
                revert TripleAErrors.InsufficientBalance();
            }

            if (
                !IERC20(paymentToken).transferFrom(
                    msg.sender,
                    address(devTreasury),
                    _agentShare
                )
            ) {
                revert TripleAErrors.PaymentFailed();
            }

            devTreasury.receiveFunds(msg.sender, paymentToken, _agentShare);

            _manageAgents(paymentToken, collectionId, _perAgentShare, amount);
        }

        if (
            !IERC20(paymentToken).transferFrom(
                msg.sender,
                collectionManager.getCollectionArtist(collectionId),
                _artistShare
            )
        ) {
            revert TripleAErrors.PaymentFailed();
        }

        if (_fulfiller != address(0) && _fulfillerShare > 0) {
            if (
                !IERC20(paymentToken).transferFrom(
                    msg.sender,
                    _fulfiller,
                    _fulfillerShare
                )
            ) {
                revert TripleAErrors.PaymentFailed();
            }
        }

        uint256[] memory _mintedTokenIds = nft.mint(
            amount,
            msg.sender,
            collectionManager.getCollectionMetadata(collectionId)
        );

        collectionManager.updateData(_mintedTokenIds, collectionId, amount);
        _allCollectorsByCollectionIds[collectionId].push(msg.sender);

        _createOrder(
            _mintedTokenIds,
            fulfillmentDetails,
            paymentToken,
            collectionId,
            amount,
            _totalPrice
        );

        emit CollectionPurchased(
            msg.sender,
            paymentToken,
            _orderCounter,
            collectionId,
            amount,
            _artistShare,
            _fulfillerShare
        );
    }

    function _manageCollectionType(
        address token,
        uint256 totalPrice,
        uint256 collectionId
    ) internal view returns (uint256, uint256, address) {
        if (
            collectionManager.getCollectionType(collectionId) ==
            TripleALibrary.CollectionType.Digital
        ) {
            return (totalPrice, 0, address(0));
        } else {
            uint256 _fulfillerId = collectionManager.getCollectionFulfillerId(
                collectionId
            );
            address _fulfillerAddress = fulfillerManager.getFulfillerWallet(
                _fulfillerId
            );

            uint256 _vig = accessControls.getTokenVig(token);
            uint256 _base = accessControls.getTokenBase(token);

            uint256 _fulfillerShare = (totalPrice * _vig) + _base;

            return (
                totalPrice - _fulfillerShare,
                _fulfillerShare,
                _fulfillerAddress
            );
        }
    }

    function _manageAgents(
        address paymentToken,
        uint256 collectionId,
        uint256 perAgentShare,
        uint256 amount
    ) internal {
        bool soldOut = false;

        if (
            amount + collectionManager.getCollectionAmountSold(collectionId) ==
            collectionManager.getCollectionAmount(collectionId)
        ) {
            soldOut = true;
        }

        uint256[] memory _agentIds = collectionManager.getCollectionAgentIds(
            collectionId
        );

        for (uint8 i = 0; i < _agentIds.length; i++) {
            agents.addBalance(
                paymentToken,
                _agentIds[i],
                perAgentShare,
                collectionId,
                soldOut
            );
        }
    }

    function _createOrder(
        uint256[] memory mintedTokens,
        string memory fulfillmentDetails,
        address token,
        uint256 collectionId,
        uint256 amount,
        uint256 totalPrice
    ) internal {
        _orderCounter++;
        _buyerToOrderIds[msg.sender].push(_orderCounter);
        _orders[_orderCounter] = TripleALibrary.Order({
            id: _orderCounter,
            amount: amount,
            token: token,
            totalPrice: totalPrice,
            collectionId: collectionId,
            mintedTokens: mintedTokens,
            fulfillmentDetails: fulfillmentDetails,
            fulfilled: true
        });

        if (
            collectionManager.getCollectionType(collectionId) ==
            TripleALibrary.CollectionType.Digital
        ) {
            uint256 _fulfillerId = collectionManager.getCollectionFulfillerId(
                collectionId
            );
            fulfillerManager.addOrder(_fulfillerId, _orderCounter);
            _orders[_orderCounter].fulfilled = false;
        }
    }

    function _checkTokens(
        address token,
        uint256 collectionId
    ) internal view returns (uint256) {
        bool _isTokenAccepted = false;
        uint256 _tokenPrice;
        address[] memory _erc20Tokens = collectionManager
            .getCollectionERC20Tokens(collectionId);
        uint256[] memory _prices = collectionManager.getCollectionPrices(
            collectionId
        );
        for (uint8 i = 0; i < _erc20Tokens.length; i++) {
            if (_erc20Tokens[i] == token) {
                _isTokenAccepted = true;
                _tokenPrice = _prices[i];
                break;
            }
        }

        if (!_isTokenAccepted) {
            revert TripleAErrors.TokenNotAccepted();
        }

        return _tokenPrice;
    }

    function fulfillIRLOrder(uint256 orderId) external onlyFulfillerManager {
        _orders[orderId].fulfilled = true;
    }

    function setCollectionManager(
        address _collectionManager
    ) external onlyAdmin {
        collectionManager = TripleACollectionManager(_collectionManager);
    }

    function setNFT(address _nft) external onlyAdmin {
        nft = TripleANFT(_nft);
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function setAgents(address _agents) external onlyAdmin {
        agents = TripleAAgents(_agents);
    }

    function setDevTreasury(address _devTreasury) external onlyAdmin {
        devTreasury = TripleADevTreasury(_devTreasury);
    }

    function getBuyerToOrderIds(
        address buyer
    ) public view returns (uint256[] memory) {
        return _buyerToOrderIds[buyer];
    }

    function getOrderAmount(uint256 orderId) public view returns (uint256) {
        return _orders[orderId].amount;
    }

    function getOrderToken(uint256 orderId) public view returns (address) {
        return _orders[orderId].token;
    }

    function getOrderCollectionId(
        uint256 orderId
    ) public view returns (uint256) {
        return _orders[orderId].collectionId;
    }

    function getOrderMintedTokens(
        uint256 orderId
    ) public view returns (uint256[] memory) {
        return _orders[orderId].mintedTokens;
    }

    function getOrderTotalPrice(uint256 orderId) public view returns (uint256) {
        return _orders[orderId].totalPrice;
    }

    function getOrderCounter() public view returns (uint256) {
        return _orderCounter;
    }

    function getAllCollectorsByCollectionId(
        uint256 collectionId
    ) public view returns (address[] memory) {
        return _allCollectorsByCollectionIds[collectionId];
    }
}
