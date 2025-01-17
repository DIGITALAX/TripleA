// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./AAALibrary.sol";
import "./AAAErrors.sol";
import "./AAAAccessControls.sol";

contract AAACollectionManager {
    mapping(address => uint256[]) private _dropIdsByArtist;
    mapping(uint256 => AAALibrary.Collection) private _collections;
    mapping(uint256 => AAALibrary.Drop) private _drops;
    mapping(uint256 => mapping(uint256 => string))
        private _agentCustomInstructions;
    mapping(uint256 => mapping(uint256 => uint256))
        private _agentDailyFrequency;

    uint256 private _collectionCounter;
    uint256 private _dropCounter;
    address public market;
    AAAAccessControls public accessControls;

    event CollectionCreated(
        address artist,
        uint256 collectionId,
        uint256 indexed dropId
    );
    event CollectionPriceAdjusted(
        address token,
        uint256 collectionId,
        uint256 newPrice
    );
    event DropCreated(address artist, uint256 indexed dropId);
    event DropDeleted(address artist, uint256 indexed dropId);
    event CollectionDeleted(address artist, uint256 indexed collectionId);
    event AgentDetailsUpdated(
        string[] customInstructions,
        uint256[] dailyFrequency,
        uint256[] agentIds,
        uint256 collectionId
    );
    event CollectionDeactivated(uint256 collectionId);
    event CollectionActivated(uint256 collectionId);

    modifier onlyMarket() {
        if (market != msg.sender) {
            revert AAAErrors.OnlyMarketContract();
        }
        _;
    }

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert AAAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyArtist(uint256 collectionId) {
        if (_collections[collectionId].artist != msg.sender) {
            revert AAAErrors.NotArtist();
        }

        _;
    }

    constructor(address  _accessControls)  {
        accessControls = AAAAccessControls(_accessControls);
    }

    function create(
        AAALibrary.CollectionInput memory collectionInput,
        string memory dropMetadata,
        uint256 dropId
    ) external {
        uint256 _dropValue = dropId;

        if (
            collectionInput.agentIds.length !=
            collectionInput.customInstructions.length
        ) {
            revert AAAErrors.BadUserInput();
        }

        if (_dropValue == 0) {
            _dropCounter++;
            _dropValue = _dropCounter;

            _drops[_dropValue] = AAALibrary.Drop({
                id: _dropValue,
                artist: msg.sender,
                collectionIds: new uint256[](0),
                metadata: dropMetadata
            });

            _dropIdsByArtist[msg.sender].push(_dropValue);
            emit DropCreated(msg.sender, _dropValue);
        } else {
            if (_drops[_dropValue].id != _dropValue) {
                revert AAAErrors.DropInvalid();
            }
        }
        _collectionCounter++;

        _collections[_collectionCounter] = AAALibrary.Collection({
            id: _collectionCounter,
            dropId: _dropValue,
            erc20Tokens: collectionInput.tokens,
            prices: collectionInput.prices,
            agentIds: collectionInput.agentIds,
            metadata: collectionInput.metadata,
            artist: msg.sender,
            amount: collectionInput.amount,
            tokenIds: new uint256[](0),
            amountSold: 0,
            active: true
        });

        for (uint256 i = 0; i < collectionInput.agentIds.length; i++) {
            _agentCustomInstructions[_collectionCounter][
                collectionInput.agentIds[i]
            ] = collectionInput.customInstructions[i];

            _agentDailyFrequency[_collectionCounter][
                collectionInput.agentIds[i]
            ] = collectionInput.dailyFrequency[i];
        }

        _drops[_dropValue].collectionIds.push(_collectionCounter);
        emit CollectionCreated(msg.sender, _collectionCounter, _dropValue);
    }

    function updateAgentCollectionDetails(
        string[] memory customInstructions,
        uint256[] memory dailyFrequency,
        uint256[] memory agentIds,
        uint256 collectionId
    ) external {
        if (_collections[collectionId].artist != msg.sender) {
            revert AAAErrors.NotArtist();
        }

        if (
            agentIds.length != customInstructions.length &&
            customInstructions.length != dailyFrequency.length
        ) {
            revert AAAErrors.BadUserInput();
        }
        for (uint256 i = 0; i < agentIds.length; i++) {
            _agentCustomInstructions[collectionId][
                agentIds[i]
            ] = customInstructions[i];

            _agentDailyFrequency[collectionId][agentIds[i]] = dailyFrequency[i];
        }

        emit AgentDetailsUpdated(
            customInstructions,
            dailyFrequency,
            agentIds,
            collectionId
        );
    }

    function adjustCollectionPrice(
        address token,
        uint256 collectionId,
        uint256 newPrice
    ) external onlyArtist(collectionId) {
        uint256 _index = 0;
        bool _tokenFound = false;

        for (
            uint256 i = 0;
            i < _collections[collectionId].erc20Tokens.length;
            i++
        ) {
            if (_collections[collectionId].erc20Tokens[i] == token) {
                _index = i;
                _tokenFound = true;
                break;
            }
        }

        if (_tokenFound) {
            _collections[collectionId].prices[_index] = newPrice;

            emit CollectionPriceAdjusted(token, collectionId, newPrice);
        }
    }

    function deactivateCollection(
        uint256 collectionId
    ) external onlyArtist(collectionId) {
        if (!_collections[collectionId].active) {
            revert AAAErrors.CollectionAlreadyDeactivated();
        }

        _collections[collectionId].active = false;

        emit CollectionDeactivated(collectionId);
    }

    function activateCollection(
        uint256 collectionId
    ) external onlyArtist(collectionId) {
        if (_collections[collectionId].active) {
            revert AAAErrors.CollectionAlreadyActive();
        }

        _collections[collectionId].active = true;

        emit CollectionActivated(collectionId);
    }

    function deleteCollection(
        uint256 collectionId
    ) external onlyArtist(collectionId) {
        for (
            uint256 i = 0;
            i < _collections[collectionId].agentIds.length;
            i++
        ) {
            delete _agentCustomInstructions[collectionId][
                _collections[collectionId].agentIds[i]
            ];
            delete _agentDailyFrequency[collectionId][
                _collections[collectionId].agentIds[i]
            ];
        }

        if (_collections[collectionId].amountSold > 0) {
            revert AAAErrors.CantDeleteSoldCollection();
        }

        uint256 _dropId = _collections[collectionId].dropId;

        uint256[] storage _collectionIds = _drops[_dropId].collectionIds;
        for (uint256 i = 0; i < _collectionIds.length; i++) {
            if (_collectionIds[i] == collectionId) {
                _collectionIds[i] = _collectionIds[_collectionIds.length - 1];
                _collectionIds.pop();
                break;
            }
        }

        if (_collectionIds.length == 0) {
            address _artist = _drops[_dropId].artist;
            uint256[] storage _dropIds = _dropIdsByArtist[_artist];
            for (uint256 i = 0; i < _dropIds.length; i++) {
                if (_dropIds[i] == _dropId) {
                    _dropIds[i] = _dropIds[_dropIds.length - 1];
                    _dropIds.pop();
                    break;
                }
            }

            delete _drops[_dropId];
        }


        delete _collections[collectionId];

        emit CollectionDeleted(msg.sender, collectionId);
    }

    function deleteDrop(uint256 dropId) external {
        if (_drops[dropId].artist != msg.sender) {
            revert AAAErrors.NotArtist();
        }

        uint256[] storage _collectionIds = _drops[dropId].collectionIds;
        for (uint256 i = 0; i < _collectionIds.length; i++) {
            uint256 collectionId = _collectionIds[i];
            if (_collections[collectionId].amountSold > 0) {
                revert AAAErrors.CantDeleteSoldCollection();
            }
        
            delete _collections[collectionId];
        }

        delete _drops[dropId];

        uint256[] storage _dropIds = _dropIdsByArtist[msg.sender];
        for (uint256 i = 0; i < _dropIds.length; i++) {
            if (_dropIds[i] == dropId) {
                if (i != _dropIds.length - 1) {
                    _dropIds[i] = _dropIds[_dropIds.length - 1];
                }
                _dropIds.pop();
                break;
            }
        }
        emit DropDeleted(msg.sender, dropId);
    }

    function updateData(
        uint256[] memory mintedTokenIds,
        uint256 collectionId,
        uint256 amount
    ) external onlyMarket {
        _collections[collectionId].amountSold += amount;
        for (uint256 i = 0; i < mintedTokenIds.length; i++) {
            _collections[collectionId].tokenIds.push(mintedTokenIds[i]);
        }
    }

    function getCollectionCount() public view returns (uint256) {
        return _collectionCounter;
    }

    function getDropCount() public view returns (uint256) {
        return _dropCounter;
    }

    function getDropCollectionIds(
        uint256 dropId
    ) public view returns (uint256[] memory) {
        return _drops[dropId].collectionIds;
    }

    function getDropMetadata(
        uint256 dropId
    ) public view returns (string memory) {
        return _drops[dropId].metadata;
    }

    function getDropIdsByArtist(
        address artist
    ) public view returns (uint256[] memory) {
        return _dropIdsByArtist[artist];
    }

    function getCollectionERC20Tokens(
        uint256 collectionId
    ) public view returns (address[] memory) {
        return _collections[collectionId].erc20Tokens;
    }

    function getCollectionPrices(
        uint256 collectionId
    ) public view returns (uint256[] memory) {
        return _collections[collectionId].prices;
    }

    function getCollectionTokenIds(
        uint256 collectionId
    ) public view returns (uint256[] memory) {
        return _collections[collectionId].tokenIds;
    }

    function getCollectionAgentIds(
        uint256 collectionId
    ) public view returns (uint256[] memory) {
        return _collections[collectionId].agentIds;
    }

    function getCollectionMetadata(
        uint256 collectionId
    ) public view returns (string memory) {
        return _collections[collectionId].metadata;
    }

    function getCollectionArtist(
        uint256 collectionId
    ) public view returns (address) {
        return _collections[collectionId].artist;
    }

    function getCollectionDropId(
        uint256 collectionId
    ) public view returns (uint256) {
        return _collections[collectionId].dropId;
    }

    function getCollectionAmount(
        uint256 collectionId
    ) public view returns (uint256) {
        return _collections[collectionId].amount;
    }

    function getCollectionAmountSold(
        uint256 collectionId
    ) public view returns (uint256) {
        return _collections[collectionId].amountSold;
    }

    function getCollectionIsActive(
        uint256 collectionId
    ) public view returns (bool) {
        return _collections[collectionId].active;
    }

    function getAgentCollectionCustomInstructions(
        uint256 collectionId,
        uint256 agentId
    ) public view returns (string memory) {
        return _agentCustomInstructions[collectionId][agentId];
    }

    function getAgentCollectionDailyFrequency(
        uint256 collectionId,
        uint256 agentId
    ) public view returns (uint256) {
        return _agentDailyFrequency[collectionId][agentId];
    }

    function setMarket(address _market) external onlyAdmin {
        market = _market;
    }

    function setAccessControls(
        address  _accessControls
    ) external onlyAdmin {
        accessControls = AAAAccessControls(_accessControls);
    }
}
