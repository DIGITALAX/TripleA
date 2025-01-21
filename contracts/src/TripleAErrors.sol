// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

contract TripleAErrors {
    error NotAdmin();
    error AlreadyAdmin();
    error CannotRemoveSelf();
    error AgentDoesntExist();
    error AdminDoesntExist();
    error AdminAlreadyExists();
    error AgentAlreadyExists();
    error OnlyAgentContract();
    error TokenAlreadyExists();
    error TokenDoesntExist();
    error NotAgentOrAdmin();
    error InsufficientFunds();
    error TransferFailed();
    error FulfillerAlreadyExists();
    error FulfillerDoesntExist();
    error OnlyCollectionContract();

    error DropInvalid();

    error OnlyMarketContract();
    error OnlyMarketOrAgentContract();
    error ZeroAddress();
    error InvalidAmount();
    error NotArtist();
    error CantDeleteSoldCollection();
    error PriceTooLow();
    error OnlyFulfillerManager();

    error NotAvailable();
    error TokenNotAccepted();
    error PaymentFailed();

    error OnlyAgentsContract();

    error NotAgent();
    error InsufficientBalance();
    error NotAgentOwner();
    error NotAgentCreator();
    error AgentStillActive();
    error BadUserInput();
    error NoActiveAgents();
    error CollectionSoldOut();
    error InvalidWorker();

    error CollectionAlreadyDeactivated();
    error CollectionAlreadyActive();
    error CollectionNotActive();

    error NotFulfiller();
    error ActiveOrders();
}
