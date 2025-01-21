// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleAErrors.sol";
import "./TripleAAccessControls.sol";
import "./TripleALibrary.sol";
import "./TripleAMarket.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TripleAFulfillerManager {
    TripleAAccessControls public accessControls;
    TripleAMarket public market;
    uint256 private _fulfillerCounter;
    mapping(uint256 => TripleALibrary.Fulfiller) private _fulfillers;

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyFulfiller() {
        if (!accessControls.isFulfiller(msg.sender)) {
            revert TripleAErrors.NotFulfiller();
        }

        _;
    }

    modifier onlyAdminOrMarket {
        if (!accessControls.isAdmin(msg.sender) && msg.sender != address(market)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    event OrderAdded(uint256 fulfillerId, uint256 orderId);
    event FulfillerCreated(address wallet, uint256 fulfillerId);
    event FulfillerDeleted(uint256 fulfillerId);
    event OrderFulfilled(uint256 fulfillerId, uint256 orderId);

    constructor(address payable _accessControls) payable {
        accessControls = TripleAAccessControls(_accessControls);
        _fulfillerCounter = 0;
    }

    function createFulfillerProfile(
        TripleALibrary.FulfillerInput memory input
    ) public onlyFulfiller {
        _fulfillerCounter++;

        _fulfillers[_fulfillerCounter] = TripleALibrary.Fulfiller({
            id: _fulfillerCounter,
            wallet: input.wallet,
            activeOrders: new uint256[](0),
            orderHistory: new uint256[](0),
            metadata: input.metadata
        });

        emit FulfillerCreated( input.wallet, _fulfillerCounter);
    }

    function deleteFulfillerProfile(uint256 fulfillerId) public onlyFulfiller {
        if (_fulfillers[fulfillerId].wallet != msg.sender) {
            TripleAErrors.NotFulfiller();
        }

        if (_fulfillers[fulfillerId].activeOrders.length > 0) {
            revert TripleAErrors.ActiveOrders();
        }

        delete _fulfillers[fulfillerId];

        emit FulfillerDeleted(fulfillerId);
    }

    function addOrder(
        uint256 fulfillerId,
        uint256 orderId
    ) external onlyAdminOrMarket {
        _fulfillers[fulfillerId].activeOrders.push(orderId);
        _fulfillers[fulfillerId].orderHistory.push(orderId);

        emit OrderAdded(fulfillerId, orderId);
    }

    function fulfillOrder(uint256 fulfillerId, uint256 orderId) public {
        if (_fulfillers[fulfillerId].wallet != msg.sender) {
            TripleAErrors.NotFulfiller();
        }

        for (
            uint8 i = 0;
            i < _fulfillers[fulfillerId].activeOrders.length;
            i++
        ) {
            if (_fulfillers[fulfillerId].activeOrders[i] == orderId) {
                _fulfillers[fulfillerId].activeOrders[i] = _fulfillers[
                    fulfillerId
                ].activeOrders[_fulfillers[fulfillerId].activeOrders.length - 1];
                _fulfillers[fulfillerId].activeOrders.pop();
                break;
            }
        }

        market.fulfillIRLOrder(orderId);

        emit OrderFulfilled(fulfillerId, orderId);
    }

    function getFulfillerActiveOrders(
        uint256 fulfillerId
    ) public view returns (uint256[] memory) {
        return _fulfillers[fulfillerId].activeOrders;
    }

    function getFulfillerOrderHistory(
        uint256 fulfillerId
    ) public view returns (uint256[] memory) {
        return _fulfillers[fulfillerId].orderHistory;
    }

    function getFulfillerWallet(
        uint256 fulfillerId
    ) public view returns (address) {
        return _fulfillers[fulfillerId].wallet;
    }

    function getFulfillerMetadata(
        uint256 fulfillerId
    ) public view returns (string memory) {
        return _fulfillers[fulfillerId].metadata;
    }

    function getFulfillerCounter() public view returns (uint256) {
        return _fulfillerCounter;
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function setMarket(address _market) external onlyAdmin {
        market = TripleAMarket(_market);
    }
}
