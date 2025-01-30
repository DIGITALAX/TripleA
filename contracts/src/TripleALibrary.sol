// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TripleALibrary {
    enum CollectionType {
        Digital,
        IRL
    }

    struct Collection {
        EnumerableSet.AddressSet erc20Tokens;
        uint256[] agentIds;
        uint256[] tokenIds;
        string metadata;
        address artist;
        uint256 id;
        uint256 fulfillerId;
        uint256 dropId;
        uint256 amount;
        uint256 amountSold;
        uint256 remixId;
        CollectionType collectionType;
        bool active;
    }

    struct Drop {
        uint256[] collectionIds;
        string metadata;
        address artist;
        uint256 id;
    }

    struct CollectionInput {
        string[] customInstructions;
        address[] tokens;
        uint256[] prices;
        uint256[] agentIds;
        string metadata;
        CollectionType collectionType;
        uint256 amount;
        uint256 fulfillerId;
        uint256 remixId;
    }

    struct Agent {
        EnumerableSet.UintSet collectionIdsHistory;
        EnumerableSet.UintSet activeCollectionIds;
    }

    struct CollectionWorker {
        uint256 publishFrequency;
        uint256 remixFrequency;
        uint256 leadFrequency;
        bool publish;
        bool remix;
        bool lead;
    }

    struct Order {
        uint256[] mintedTokens;
        string fulfillmentDetails;
        address token;
        uint256 amount;
        uint256 totalPrice;
        uint256 id;
        uint256 collectionId;
        bool fulfilled;
    }

    struct OrderRent {
        address buyer;
        uint256 blockTimestamp;
    }

    struct Fulfiller {
        EnumerableSet.UintSet activeOrders;
        uint256[] orderHistory;
        string metadata;
        address wallet;
        uint256 id;
    }

    struct FulfillerInput {
        string metadata;
        address wallet;
    }
}
