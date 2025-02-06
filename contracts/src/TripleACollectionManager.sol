// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleALibrary.sol";
import "./TripleAErrors.sol";
import "./TripleAAccessControls.sol";
import "./TripleAAgents.sol";
import "./skyhunters/SkyhuntersAccessControls.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TripleACollectionManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(address => EnumerableSet.UintSet) private _dropIdsByArtist;
    mapping(uint256 => TripleALibrary.Collection) private _collections;
    mapping(uint256 => TripleALibrary.Drop) private _drops;
    mapping(uint256 => mapping(uint256 => string))
        private _agentCustomInstructions;
    mapping(uint256 => mapping(address => uint256)) private _collectionPrices;

    uint256 private _collectionCounter;
    uint256 private _dropCounter;
    address public market;
    TripleAAccessControls public accessControls;
    TripleAAgents public agents;
    SkyhuntersAccessControls public skyhuntersAccessControls;

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
        uint256[] agentIds,
        uint256 collectionId
    );
    event CollectionDeactivated(uint256 collectionId);
    event CollectionActivated(uint256 collectionId);
    event Remixable(uint256 collectionId, bool remixable);

    modifier onlyMarket() {
        if (market != msg.sender) {
            revert TripleAErrors.OnlyMarketContract();
        }
        _;
    }

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    modifier onlyArtist(uint256 collectionId) {
        if (_collections[collectionId].artist != msg.sender) {
            revert TripleAErrors.NotArtist();
        }

        _;
    }

    constructor(
        address payable _accessControls,
        address payable _skyhuntersAccessControls
    ) payable {
        accessControls = TripleAAccessControls(_accessControls);
        skyhuntersAccessControls = SkyhuntersAccessControls(
            _skyhuntersAccessControls
        );
    }

    function create(
        TripleALibrary.CollectionInput memory collectionInput,
        TripleALibrary.CollectionWorker[] memory workers,
        string memory dropMetadata,
        uint256 dropId
    ) external {
        if (
            collectionInput.remixId > 0 &&
            !_collections[collectionInput.remixId].remixable
        ) {
            revert TripleAErrors.CannotRemix();
        }

        if (
            collectionInput.agentIds.length !=
            collectionInput.customInstructions.length ||
            collectionInput.agentIds.length != workers.length ||
            collectionInput.tokens.length != collectionInput.prices.length
        ) {
            revert TripleAErrors.BadUserInput();
        }
        if (
            collectionInput.collectionType == TripleALibrary.CollectionType.IRL
        ) {
            _checkTokens(collectionInput.tokens, collectionInput.prices);
        }

        for (uint8 i = 0; i < collectionInput.tokens.length; i++) {
            if (
                !skyhuntersAccessControls.isAcceptedToken(
                    collectionInput.tokens[i]
                )
            ) {
                revert TripleAErrors.TokenNotAccepted();
            }
        }

        uint256 _dropValue = dropId;

        if (_dropValue == 0) {
            _dropCounter++;
            _dropValue = _dropCounter;

            _drops[_dropValue] = TripleALibrary.Drop({
                id: _dropValue,
                artist: msg.sender,
                collectionIds: new uint256[](0),
                metadata: dropMetadata
            });

            _dropIdsByArtist[msg.sender].add(_dropValue);
            emit DropCreated(msg.sender, _dropValue);
        } else {
            if (_drops[_dropValue].id != _dropValue) {
                revert TripleAErrors.DropInvalid();
            }
        }
        _collectionCounter++;

        _collections[_collectionCounter].id = _collectionCounter;
        _collections[_collectionCounter].dropId = _dropValue;
        _collections[_collectionCounter].agentIds = collectionInput.agentIds;
        _collections[_collectionCounter].metadata = collectionInput.metadata;
        _collections[_collectionCounter].artist = msg.sender;
        _collections[_collectionCounter].amount = collectionInput.amount;
        _collections[_collectionCounter].collectionType = collectionInput
            .collectionType;
        _collections[_collectionCounter].fulfillerId = collectionInput
            .fulfillerId;
        _collections[_collectionCounter].remixId = collectionInput.remixId;
        _collections[_collectionCounter].active = true;
        _collections[_collectionCounter].remixable = collectionInput.remixable;

        if (skyhuntersAccessControls.isAgent(msg.sender)) {
            _collections[_collectionCounter].agent = true;
        }

        for (uint8 i = 0; i < collectionInput.agentIds.length; i++) {
            _agentCustomInstructions[_collectionCounter][
                collectionInput.agentIds[i]
            ] = collectionInput.customInstructions[i];

            agents.addWorker(
                workers[i],
                collectionInput.agentIds[i],
                _collectionCounter
            );
        }

        for (uint8 i = 0; i < collectionInput.prices.length; i++) {
            _collectionPrices[_collectionCounter][
                collectionInput.tokens[i]
            ] = collectionInput.prices[i];
        }

        _drops[_dropValue].collectionIds.push(_collectionCounter);
        emit CollectionCreated(msg.sender, _collectionCounter, _dropValue);
    }

    function _checkTokens(
        address[] memory tokens,
        uint256[] memory prices
    ) internal view {
        for (uint8 i = 0; i < tokens.length; i++) {
            uint256 _base = accessControls.getTokenBase(tokens[i]);
            uint256 _vig = accessControls.getTokenBase(tokens[i]);

            if (prices[i] < _base + prices[i] * _vig) {
                revert TripleAErrors.PriceTooLow();
            }
        }
    }

    function updateCollectionWorkerAndDetails(
        TripleALibrary.CollectionWorker[] memory workers,
        string[] memory customInstructions,
        uint256[] memory agentIds,
        uint256 collectionId
    ) public onlyArtist(collectionId) {
        if (_collections[collectionId].artist != msg.sender) {
            revert TripleAErrors.NotArtist();
        }

        if (
            agentIds.length != customInstructions.length ||
            workers.length != customInstructions.length
        ) {
            revert TripleAErrors.BadUserInput();
        }
        for (uint8 i = 0; i < agentIds.length; i++) {
            _agentCustomInstructions[collectionId][
                agentIds[i]
            ] = customInstructions[i];
        }

        for (uint8 i = 0; i < workers.length; i++) {
            agents.updateWorker(workers[i], agentIds[i], collectionId);
        }

        emit AgentDetailsUpdated(customInstructions, agentIds, collectionId);
    }

    function adjustCollectionPrice(
        address token,
        uint256 collectionId,
        uint256 newPrice
    ) external onlyArtist(collectionId) {
        if (!_collections[collectionId].erc20Tokens.contains(token)) {
            revert TripleAErrors.TokenNotAccepted();
        }

        _collectionPrices[collectionId][token] = newPrice;

        emit CollectionPriceAdjusted(token, collectionId, newPrice);
    }

    function deactivateCollection(
        uint256 collectionId
    ) external onlyArtist(collectionId) {
        if (!_collections[collectionId].active) {
            revert TripleAErrors.CollectionAlreadyDeactivated();
        }

        _collections[collectionId].active = false;

        emit CollectionDeactivated(collectionId);
    }

    function activateCollection(
        uint256 collectionId
    ) external onlyArtist(collectionId) {
        if (_collections[collectionId].active) {
            revert TripleAErrors.CollectionAlreadyActive();
        }

        _collections[collectionId].active = true;

        emit CollectionActivated(collectionId);
    }

    function deleteCollection(
        uint256 collectionId
    ) external onlyArtist(collectionId) {
        for (uint8 i = 0; i < _collections[collectionId].agentIds.length; i++) {
            delete _agentCustomInstructions[collectionId][
                _collections[collectionId].agentIds[i]
            ];
        }

        if (_collections[collectionId].amountSold > 0) {
            revert TripleAErrors.CantDeleteSoldCollection();
        }

        uint256 _dropId = _collections[collectionId].dropId;

        _dropIdsByArtist[_drops[_dropId].artist].remove(_dropId);
        delete _drops[_dropId];

        for (
            uint8 i = 0;
            i < _collections[collectionId].erc20Tokens.length();
            i++
        ) {
            delete _collectionPrices[collectionId][
                _collections[collectionId].erc20Tokens.at(i)
            ];
        }

        delete _collections[collectionId];

        emit CollectionDeleted(msg.sender, collectionId);
    }

    function deleteDrop(uint256 dropId) external {
        if (_drops[dropId].artist != msg.sender) {
            revert TripleAErrors.NotArtist();
        }

        uint256[] storage _collectionIds = _drops[dropId].collectionIds;
        for (uint8 i = 0; i < _collectionIds.length; i++) {
            uint256 collectionId = _collectionIds[i];
            if (_collections[collectionId].amountSold > 0) {
                revert TripleAErrors.CantDeleteSoldCollection();
            }

            delete _collections[collectionId];
        }

        _dropIdsByArtist[_drops[dropId].artist].remove(dropId);
        delete _drops[dropId];

        emit DropDeleted(msg.sender, dropId);
    }

    function updateData(
        uint256[] memory mintedTokenIds,
        uint256 collectionId,
        uint256 amount
    ) external onlyMarket {
        _collections[collectionId].amountSold += amount;
        for (uint8 i = 0; i < mintedTokenIds.length; i++) {
            _collections[collectionId].tokenIds.push(mintedTokenIds[i]);
        }
    }

    function changeRemixable(
        uint256 collectionId,
        bool remixable
    ) external onlyArtist(collectionId) {
        _collections[collectionId].remixable = remixable;

        emit Remixable(collectionId, remixable);
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
        return _dropIdsByArtist[artist].values();
    }

    function getCollectionERC20Tokens(
        uint256 collectionId
    ) public view returns (address[] memory) {
        return _collections[collectionId].erc20Tokens.values();
    }

    function getCollectionERC20TokensSet(
        address token,
        uint256 collectionId
    ) public view returns (bool) {
        return _collections[collectionId].erc20Tokens.contains(token);
    }

    function getCollectionTokenPrice(
        address token,
        uint256 collectionId
    ) public view returns (uint256) {
        return _collectionPrices[collectionId][token];
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

    function getCollectionType(
        uint256 collectionId
    ) public view returns (TripleALibrary.CollectionType) {
        return _collections[collectionId].collectionType;
    }

    function getCollectionAmount(
        uint256 collectionId
    ) public view returns (uint256) {
        return _collections[collectionId].amount;
    }

    function getCollectionFulfillerId(
        uint256 collectionId
    ) public view returns (uint256) {
        return _collections[collectionId].fulfillerId;
    }

    function getCollectionAmountSold(
        uint256 collectionId
    ) public view returns (uint256) {
        return _collections[collectionId].amountSold;
    }

    function getCollectionRemixId(
        uint256 collectionId
    ) public view returns (uint256) {
        return _collections[collectionId].remixId;
    }

    function getCollectionIsActive(
        uint256 collectionId
    ) public view returns (bool) {
        return _collections[collectionId].active;
    }

    function getCollectionIsRemixable(
        uint256 collectionId
    ) public view returns (bool) {
        return _collections[collectionId].remixable;
    }

    function getCollectionIsByAgent(
        uint256 collectionId
    ) public view returns (bool) {
        return _collections[collectionId].agent;
    }

    function getAgentCollectionCustomInstructions(
        uint256 collectionId,
        uint256 agentId
    ) public view returns (string memory) {
        return _agentCustomInstructions[collectionId][agentId];
    }

    function setMarket(address _market) external onlyAdmin {
        market = _market;
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function setSkyhuntersAccessControls(
        address payable _skyhuntersAccessControls
    ) external onlyAdmin {
        skyhuntersAccessControls = SkyhuntersAccessControls(
            _skyhuntersAccessControls
        );
    }

    function setAgents(address payable _agents) external onlyAdmin {
        agents = TripleAAgents(_agents);
    }
}
