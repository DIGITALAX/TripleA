// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

contract TripleAErrors {
    error NotAdmin();
    error AlreadyAdmin();
    error CannotRemoveSelf();
    error AdminDoesntExist();
    error AdminAlreadyExists();
    error TokenAlreadyExists();
    error TokenDoesntExist();
    error InsufficientFunds();
    error TransferFailed();
    error FulfillerAlreadyExists();
    error FulfillerDoesntExist();
    error OnlyCollectionContract();

    error DropInvalid();
    error CannotRemix();

    error OnlyMarketContract();
    error OnlyMarketOrAgentContract();
    error ZeroAddress();
    error InvalidAmount();
    error NotArtist();
    error CantDeleteSoldCollection();
    error PriceTooLow();
    error OnlyFulfillerManager();
    error OnlyPoolManagerContract();
    error BadUserInput();

    error NotAvailable();
    error TokenNotAccepted();
    error PaymentFailed();

    error OnlyAgentsContract();
    error NotAgentOwner();
    error NotAgentCreator();
    error InvalidWorker();
    error NotAgent();
    error InsufficientBalance();
    error NoActiveAgents();
    error CollectionSoldOut();

    error CollectionAlreadyDeactivated();
    error CollectionAlreadyActive();
    error CollectionNotActive();

    error NotFulfiller();
    error ActiveOrders();

    error OnlyCollector();
}
