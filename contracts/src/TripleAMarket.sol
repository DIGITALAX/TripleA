// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleALibrary.sol";
import "./TripleANFT.sol";
import "./TripleAAccessControls.sol";
import "./TripleACollectionManager.sol";
import "./TripleAAgents.sol";
import "./TripleAFulfillerManager.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract TripleAMarket {
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private _orderCounter;
    TripleANFT public nft;
    TripleACollectionManager public collectionManager;
    TripleAFulfillerManager public fulfillerManager;
    TripleAAccessControls public accessControls;
    TripleAAgents public agents;

    mapping(address => EnumerableSet.UintSet) private _buyerToOrderIds;
    mapping(uint256 => TripleALibrary.Order) private _orders;
    mapping(uint256 => address[]) private _allCollectorsByCollectionIds;

    event CollectionPurchased(
        address buyer,
        address paymentToken,
        uint256 orderId,
        uint256 collectionId,
        uint256 amount,
        uint256 artistShare,
        uint256 fulfillerShare,
        uint256 agentShare,
        uint256 remixShare
    );
    event FulfillmentUpdated(string fulfillment, uint256 orderId);

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

    modifier onlyCollector(uint256 orderId) {
        if (!_buyerToOrderIds[msg.sender].contains(orderId)) {
            revert TripleAErrors.OnlyCollector();
        }
        _;
    }

    constructor(
        address _nft,
        address _collectionManager,
        address payable _accessControls,
        address payable _agents,
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
            amount >
            _amount - collectionManager.getCollectionAmountSold(collectionId)
        ) {
            revert TripleAErrors.NotAvailable();
        }
        uint256 _tokenPrice = _checkTokens(paymentToken, collectionId);
        uint256 _totalPrice = _tokenPrice * amount;
        (
            uint256 _originalArtistShare,
            uint256 _fulfillerShare,
            address _fulfiller
        ) = _manageCollectionType(paymentToken, _totalPrice, collectionId);
        address _artist = collectionManager.getCollectionArtist(collectionId);

        TripleALibrary.ShareResponse memory _shares = _calculateShares(
            paymentToken,
            amount,
            collectionId,
            _originalArtistShare
        );
        if (_shares.agentShare > 0) {
            if (
                IERC20(paymentToken).balanceOf(msg.sender) < _shares.agentShare
            ) {
                revert TripleAErrors.InsufficientBalance();
            }

            if (
                !IERC20(paymentToken).transferFrom(
                    msg.sender,
                    address(agents),
                    _shares.agentShare
                )
            ) {
                revert TripleAErrors.PaymentFailed();
            }

            _manageAgents(
                paymentToken,
                collectionId,
                _shares.perAgentShare,
                amount
            );
        }
        if (_shares.remixArtist != address(0) && _shares.remixShare > 0) {
            if (
                !IERC20(paymentToken).transferFrom(
                    msg.sender,
                    _shares.remixArtist,
                    _shares.remixShare
                )
            ) {
                revert TripleAErrors.PaymentFailed();
            }
        }
        if (_artist != address(0) && _shares.artistShare > 0) {
            if (
                !IERC20(paymentToken).transferFrom(
                    msg.sender,
                    _artist,
                    _shares.artistShare
                )
            ) {
                revert TripleAErrors.PaymentFailed();
            }
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

        _createOrder(
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
            _shares.artistShare,
            _fulfillerShare,
            _shares.agentShare,
            _shares.remixShare
        );
    }

    function _calculateShares(
        address paymentToken,
        uint256 amount,
        uint256 collectionId,
        uint256 totalPrice
    ) internal view returns (TripleALibrary.ShareResponse memory) {
        address _remixArtist = address(0);
        uint256 _remixId = collectionManager.getCollectionRemixId(collectionId);
        uint256 _individualPrice = totalPrice / amount;
        uint256 _remixShare = 0;
        uint256 _perAgentShare = 0;
        uint256 _agentShare = 0;
        uint256 _artistShare = 0;

        if (_remixId > 0) {
            _remixArtist = collectionManager.getCollectionArtist(_remixId);

            if (collectionManager.getCollectionIsByAgent(collectionId)) {
                _agentShare = (totalPrice * 50) / 100;
                _remixShare = (totalPrice * 50) / 100;
                _artistShare = 0;
            } else {
                _artistShare = (totalPrice * 70) / 100;
                _agentShare = (totalPrice * 10) / 100;
                _remixShare = (totalPrice * 20) / 100;
            }
        } else {
            if (
                collectionManager.getCollectionAmount(collectionId) > 2 &&
                collectionManager.getCollectionTokenPrice(
                    paymentToken,
                    collectionId
                ) >
                accessControls.getTokenThreshold(paymentToken) &&
                collectionManager.getCollectionAgentIds(collectionId).length >
                0 &&
                amount +
                    collectionManager.getCollectionAmountSold(collectionId) <=
                collectionManager.getCollectionAmount(collectionId)
            ) {
                if (
                    collectionManager.getCollectionAmountSold(collectionId) ==
                    0 &&
                    amount > 1
                ) {
                    uint256 _additionalUnits = amount - 1;

                    _agentShare =
                        (_additionalUnits * _individualPrice * 10) /
                        100;

                    _perAgentShare =
                        _agentShare /
                        collectionManager
                            .getCollectionAgentIds(collectionId)
                            .length;

                    uint256 _artistShareForAdditionalUnits = (_additionalUnits *
                        _individualPrice *
                        90) /
                        100 +
                        _individualPrice;

                    _artistShare = _artistShareForAdditionalUnits;
                } else if (
                    collectionManager.getCollectionAmountSold(collectionId) +
                        amount >
                    1
                ) {
                    _agentShare = (totalPrice * 10) / 100;

                    _perAgentShare =
                        _agentShare /
                        collectionManager
                            .getCollectionAgentIds(collectionId)
                            .length;

                    if (_agentShare < totalPrice) {
                        _artistShare = totalPrice - _agentShare;
                    }
                }
            }
        }
        return
            TripleALibrary.ShareResponse({
                remixArtist: _remixArtist,
                remixShare: _remixShare,
                agentShare: _agentShare,
                perAgentShare: _perAgentShare,
                artistShare: _artistShare
            });
    }

    function updateFulfillmentDetails(
        string memory fulfillment,
        uint256 orderId
    ) public onlyCollector(orderId) {
        _orders[orderId].fulfillmentDetails = fulfillment;

        emit FulfillmentUpdated(fulfillment, orderId);
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

            uint256 _fulfillerShare = (totalPrice * _vig) / 100 + _base;

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
        string memory fulfillmentDetails,
        address token,
        uint256 collectionId,
        uint256 amount,
        uint256 totalPrice
    ) internal {
        uint256[] memory _mintedTokens = nft.mint(
            amount,
            msg.sender,
            collectionManager.getCollectionMetadata(collectionId)
        );

        collectionManager.updateData(_mintedTokens, collectionId, amount);
        _allCollectorsByCollectionIds[collectionId].push(msg.sender);

        _orderCounter++;
        _buyerToOrderIds[msg.sender].add(_orderCounter);
        _orders[_orderCounter] = TripleALibrary.Order({
            id: _orderCounter,
            amount: amount,
            token: token,
            totalPrice: totalPrice,
            collectionId: collectionId,
            mintedTokens: _mintedTokens,
            fulfillmentDetails: fulfillmentDetails,
            fulfilled: true
        });

        if (
            collectionManager.getCollectionType(collectionId) !=
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
        if (
            !collectionManager.getCollectionERC20TokensSet(token, collectionId)
        ) {
            revert TripleAErrors.TokenNotAccepted();
        }

        return collectionManager.getCollectionTokenPrice(token, collectionId);
    }

    function fulfillIRLOrder(uint256 orderId) external onlyFulfillerManager {
        _orders[orderId].fulfilled = true;
    }

    function setCollectionManager(
        address _collectionManager
    ) external onlyAdmin {
        collectionManager = TripleACollectionManager(_collectionManager);
    }

    function setFulfillerManager(address _fulfillerManager) external onlyAdmin {
        fulfillerManager = TripleAFulfillerManager(_fulfillerManager);
    }

    function setNFT(address _nft) external onlyAdmin {
        nft = TripleANFT(_nft);
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function setAgents(address payable _agents) external onlyAdmin {
        agents = TripleAAgents(_agents);
    }

    function getBuyerToOrderIds(
        address buyer
    ) public view returns (uint256[] memory) {
        return _buyerToOrderIds[buyer].values();
    }

    function getOrderIsFulfilled(uint256 orderId) public view returns (bool) {
        return _orders[orderId].fulfilled;
    }

    function getOrderFulfillmentDetails(
        uint256 orderId
    ) public view returns (string memory) {
        return _orders[orderId].fulfillmentDetails;
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
