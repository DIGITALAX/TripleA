// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.24;

import "./SkyhuntersErrors.sol";

contract SkyhuntersAccessControls {
    mapping(address => bool) private _admins;
    mapping(address => bool) private _verifiedContracts;

    modifier onlyAdmin() {
        if (!_admins[msg.sender]) {
            revert SkyhuntersErrors.NotAdmin();
        }
        _;
    }

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event VerifiedContractAdded(address indexed admin);
    event VerifiedContractRemoved(address indexed admin);

    constructor() {
        _admins[msg.sender] = true;
    }

    function addAdmin(address admin) external onlyAdmin {
        if (_admins[admin]) {
            revert SkyhuntersErrors.AdminAlreadyExists();
        }
        _admins[admin] = true;
        emit AdminAdded(admin);
    }

    function removeAdmin(address admin) external onlyAdmin {
        if (!_admins[admin]) {
            revert SkyhuntersErrors.AdminDoesntExist();
        }

        if (admin == msg.sender) {
            revert SkyhuntersErrors.CannotRemoveSelf();
        }

        _admins[admin] = false;
        emit AdminRemoved(admin);
    }

    function addVerifiedContract(address verifiedContract) external onlyAdmin {
        if (_verifiedContracts[verifiedContract]) {
            revert SkyhuntersErrors.ContractAlreadyExists();
        }
        _verifiedContracts[verifiedContract] = true;
        emit VerifiedContractAdded(verifiedContract);
    }

    function removeVerifiedContract(
        address verifiedContract
    ) external onlyAdmin {
        if (!_verifiedContracts[verifiedContract]) {
            revert SkyhuntersErrors.ContractDoesntExist();
        }

        _verifiedContracts[verifiedContract] = false;
        emit VerifiedContractRemoved(verifiedContract);
    }

    function isAdmin(address admin) public view returns (bool) {
        return _admins[admin];
    }

    function isVerifiedContract(
        address verifiedContract
    ) public view returns (bool) {
        return _verifiedContracts[verifiedContract];
    }
}
