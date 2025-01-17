// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./AAALibrary.sol";
import "./AAANFT.sol";
import "./AAAAccessControls.sol";
import "./AAACollectionManager.sol";
import "./AAAAgents.sol";
import "./AAADevTreasury.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AAAMarket {
    uint256 private _orderCounter;
    AAANFT public nft;
    AAACollectionManager public collectionManager;
    AAAAccessControls public accessControls;
    AAAAgents public agents;
    AAADevTreasury public devTreasury;

    mapping(address => uint256[]) private _buyerToOrderIds;
    mapping(uint256 => AAALibrary.Order) private _orders;
    mapping(uint256 => address[]) private _allCollectorsByCollectionIds;

    event CollectionPurchased(
        uint256 indexed orderId,
        uint256 collectionId,
        uint256 amount,
        address buyer,
        address paymentToken
    );

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert AAAErrors.NotAdmin();
        }
        _;
    }

    constructor(
        address _nft,
        address _collectionManager,
        address payable _accessControls,
        address _agents
    ) payable {
        nft = AAANFT(_nft);
        collectionManager = AAACollectionManager(_collectionManager);
        accessControls = AAAAccessControls(_accessControls);
        agents = AAAAgents(_agents);
    }

    function buy(
        uint256 collectionId,
        uint256 amount,
        address paymentToken
    ) external {
        if (!collectionManager.getCollectionIsActive(collectionId)) {
            revert AAAErrors.CollectionNotActive();
        }

        uint256 _amount = collectionManager.getCollectionAmount(collectionId);
        if (
            amount + collectionManager.getCollectionAmountSold(collectionId) >
            _amount
        ) {
            revert AAAErrors.NotAvailable();
        }

        uint256 _tokenPrice = _checkTokens(paymentToken, collectionId);

        uint256 _totalPrice = _tokenPrice * amount;
        uint256 _artistShare = _totalPrice;
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
                revert AAAErrors.InsufficientBalance();
            }

            if (
                !IERC20(paymentToken).transferFrom(
                    msg.sender,
                    address(devTreasury),
                    _agentShare
                )
            ) {
                revert AAAErrors.PaymentFailed();
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
            revert AAAErrors.PaymentFailed();
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
            paymentToken,
            collectionId,
            amount,
            _totalPrice
        );
        emit CollectionPurchased(
            _orderCounter,
            collectionId,
            amount,
            msg.sender,
            paymentToken
        );
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

        for (uint256 i = 0; i < _agentIds.length; i++) {
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
        address token,
        uint256 collectionId,
        uint256 amount,
        uint256 totalPrice
    ) internal {
        _orderCounter++;
        _buyerToOrderIds[msg.sender].push(_orderCounter);
        _orders[_orderCounter] = AAALibrary.Order({
            id: _orderCounter,
            amount: amount,
            token: token,
            totalPrice: totalPrice,
            collectionId: collectionId,
            mintedTokens: mintedTokens
        });
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
        for (uint256 i = 0; i < _erc20Tokens.length; i++) {
            if (_erc20Tokens[i] == token) {
                _isTokenAccepted = true;
                _tokenPrice = _prices[i];
                break;
            }
        }

        if (!_isTokenAccepted) {
            revert AAAErrors.TokenNotAccepted();
        }

        return _tokenPrice;
    }

    function setCollectionManager(
        address _collectionManager
    ) external onlyAdmin {
        collectionManager = AAACollectionManager(_collectionManager);
    }

    function setNFT(address _nft) external onlyAdmin {
        nft = AAANFT(_nft);
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = AAAAccessControls(_accessControls);
    }

    function setAgents(address _agents) external onlyAdmin {
        agents = AAAAgents(_agents);
    }

    function setDevTreasury(address _devTreasury) external onlyAdmin {
        devTreasury = AAADevTreasury(_devTreasury);
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
