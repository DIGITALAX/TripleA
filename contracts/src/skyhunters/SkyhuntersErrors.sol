// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.24;

contract SkyhuntersErrors {
    error AdminDoesntExist();
    error AdminAlreadyExists();
    error CannotRemoveSelf();
    error NotAdmin();
    error OnlyAgentContract();
    error AgentAlreadyExists();
    error AgentDoesntExist();
    error ContractDoesntExist();
    error ContractAlreadyExists();
    error PoolAlreadyExists();
    error PoolDoesntExist();
    error TokenDoesntExist();
    error TokenAlreadyExists();

    error NotVerifiedContract();
    error InvalidFunds();

    error NotAgentOwner();
    error NotAgentCreator();
    error NotAgentOrAdmin();
    error AgentStillActive();
    error InvalidScore();
    error InvalidAmount();
}
