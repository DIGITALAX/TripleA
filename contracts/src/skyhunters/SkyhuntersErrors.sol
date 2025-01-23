// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.24;

contract SkyhuntersErrors {
    error AdminDoesntExist();
    error AdminAlreadyExists();
    error CannotRemoveSelf();
    error NotAdmin();
    error ContractDoesntExist();
    error ContractAlreadyExists();
    
    error NotVerifiedContract();
    error InvalidFunds();
}
