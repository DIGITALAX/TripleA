// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

contract TripleALibrary {
    enum CollectionType {
        Digital,
        IRL
    }

    struct Collection {
        address[] erc20Tokens;
        uint256[] prices;
        uint256[] agentIds;
        uint256[] tokenIds;
        string metadata;
        address artist;
        uint256 id;
        uint256 fulfillerId;
        uint256 dropId;
        uint256 amount;
        uint256 amountSold;
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
        uint256[] cycleFrequency;
        string metadata;
        CollectionType collectionType;
        uint256 amount;
        uint256 fulfillerId;
    }

    struct Agent {
        uint256[] collectionIdsHistory;
        uint256[] activeCollectionIds;
        address[] agentWallets;
        address[] owners;
        string metadata;
        address creator;
        uint256 id;
    }

    struct CollectionWorker {
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
        uint256[] orderHistory;
        uint256[] activeOrders;
        string metadata;
        address wallet;
        uint256 id;
    }

    struct FulfillerInput {
        string metadata;
        address wallet;
    }
}
