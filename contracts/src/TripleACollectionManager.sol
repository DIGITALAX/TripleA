// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./TripleALibrary.sol";
import "./TripleAErrors.sol";
import "./TripleAAccessControls.sol";
import "./TripleAAgents.sol";
import "./skyhunters/SkyhuntersAccessControls.sol";
import "./skyhunters/SkyhuntersAgentManager.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract TripleACollectionManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(address => EnumerableSet.UintSet) private _dropIdsByArtist;
    mapping(uint256 => TripleALibrary.Collection) private _collections;
    mapping(uint256 => TripleALibrary.Drop) private _drops;
    mapping(uint256 => mapping(address => uint256)) private _collectionPrices;
    mapping(address => EnumerableSet.UintSet) private _activeCollections;

    uint256 private _collectionCounter;
    uint256 private _dropCounter;
    address public market;
    TripleAAccessControls public accessControls;
    TripleAAgents public agents;
    SkyhuntersAccessControls public skyhuntersAccessControls;
    SkyhuntersAgentManager public skyhuntersAgentManager;

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

    modifier onlyArtistOrAgentOwner(
        uint256 collectionId,
        uint256 agentId,
        bool drop
    ) {
        bool _revert = false;

        if (agentId > 0) {
            address _artist = _collections[collectionId].artist;
            if (drop) {
                _artist = _drops[collectionId].artist;
            }

            if (
                !skyhuntersAgentManager.getIsAgentOwner(msg.sender, agentId) &&
                skyhuntersAgentManager.getIsAgentWallet(_artist, agentId)
            ) {
                _revert = true;
            }
        } else {
            if (drop) {
                if (_drops[collectionId].artist != msg.sender) {
                    _revert = true;
                }
            } else {
                if (_collections[collectionId].artist != msg.sender) {
                    _revert = true;
                }
            }
        }

        if (_revert) {
            revert TripleAErrors.NotArtist();
        }

        _;
    }

    constructor(
        address payable _accessControls,
        address payable _skyhuntersAccessControls,
        address _skyhuntersAgentManager
    ) payable {
        accessControls = TripleAAccessControls(_accessControls);
        skyhuntersAccessControls = SkyhuntersAccessControls(
            _skyhuntersAccessControls
        );
        skyhuntersAgentManager = SkyhuntersAgentManager(
            _skyhuntersAgentManager
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
            collectionInput.agentIds.length != workers.length ||
            collectionInput.tokens.length != collectionInput.prices.length
        ) {
            revert TripleAErrors.BadUserInput();
        }

        _checkTokens(
            collectionInput.tokens,
            collectionInput.prices,
            collectionInput.collectionType,
            collectionInput.agentIds.length > 0
        );

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

            _drops[_dropValue].id = _dropValue;
            _drops[_dropValue].artist = msg.sender;
            _drops[_dropValue].metadata = dropMetadata;

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
        _collections[_collectionCounter].metadata = collectionInput.metadata;
        _collections[_collectionCounter].artist = msg.sender;
        _collections[_collectionCounter].amount = collectionInput.amount;
        _collections[_collectionCounter].collectionType = collectionInput
            .collectionType;
        _collections[_collectionCounter].remixId = collectionInput.remixId;
        _collections[_collectionCounter].active = true;
        _collections[_collectionCounter].remixable = collectionInput.remixable;

        if (
            collectionInput.collectionType == TripleALibrary.CollectionType.IRL
        ) {
            _collections[_collectionCounter].fulfillerId = collectionInput
                .fulfillerId;
        }

        if (skyhuntersAccessControls.isAgent(msg.sender)) {
            _collections[_collectionCounter].agent = true;

            if (collectionInput.remixId == 0) {
                _collections[_collectionCounter].forArtist = collectionInput
                    .forArtist;
            }
        }

        for (uint8 i = 0; i < collectionInput.agentIds.length; i++) {
            agents.addWorker(
                workers[i],
                collectionInput.agentIds[i],
                _collectionCounter
            );
        }

        for (uint8 i = 0; i < collectionInput.agentIds.length; i++) {
            _collections[_collectionCounter].agentIds.add(
                collectionInput.agentIds[i]
            );
        }

        for (uint8 i = 0; i < collectionInput.prices.length; i++) {
            _collectionPrices[_collectionCounter][
                collectionInput.tokens[i]
            ] = collectionInput.prices[i];
            _collections[_collectionCounter].erc20Tokens.add(
                collectionInput.tokens[i]
            );
        }

        _activeCollections[msg.sender].add(_collectionCounter);
        _drops[_dropValue].collectionIds.add(_collectionCounter);
        emit CollectionCreated(msg.sender, _collectionCounter, _dropValue);
    }

    function _checkTokens(
        address[] memory tokens,
        uint256[] memory prices,
        TripleALibrary.CollectionType collectionType,
        bool useAgent
    ) internal view {
        for (uint8 i = 0; i < tokens.length; i++) {
            uint256 _base = accessControls.getTokenBase(tokens[i]);
            if (
                (collectionType == TripleALibrary.CollectionType.IRL &&
                    prices[i] < _base) ||
                (prices[i] < accessControls.getTokenThreshold(tokens[i]) &&
                    useAgent)
            ) {
                revert TripleAErrors.PriceTooLow();
            }
        }
    }

    function updateCollectionWorkerAndDetails(
        TripleALibrary.CollectionWorker[] memory workers,
        string[] memory customInstructions,
        uint256[] memory agentIds,
        uint256 collectionId,
        uint256 agentId
    ) public onlyArtistOrAgentOwner(collectionId, agentId, false) {
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
            if (!_collections[collectionId].agentIds.contains(agentIds[i])) {
                revert TripleAErrors.CantChangeAgents();
            }
        }

        for (uint8 i = 0; i < workers.length; i++) {
            agents.updateWorker(workers[i], agentIds[i], collectionId);
        }

        emit AgentDetailsUpdated(customInstructions, agentIds, collectionId);
    }

    function adjustCollectionPrice(
        address token,
        uint256 collectionId,
        uint256 newPrice,
        uint256 agentId
    ) external onlyArtistOrAgentOwner(collectionId, agentId, false) {
        if (!_collections[collectionId].erc20Tokens.contains(token)) {
            revert TripleAErrors.TokenNotAccepted();
        }

        _collectionPrices[collectionId][token] = newPrice;

        emit CollectionPriceAdjusted(token, collectionId, newPrice);
    }

    function deactivateCollection(
        uint256 collectionId,
        uint256 agentId
    ) external onlyArtistOrAgentOwner(collectionId, agentId, false) {
        if (!_collections[collectionId].active) {
            revert TripleAErrors.CollectionAlreadyDeactivated();
        }

        _collections[collectionId].active = false;
        _activeCollections[_collections[collectionId].artist].remove(
            collectionId
        );

        if (
            _activeCollections[_collections[collectionId].artist].length() < 1
        ) {
            _updateAgentBalance(collectionId);
        }

        emit CollectionDeactivated(collectionId);
    }

    function activateCollection(
        uint256 collectionId,
        uint256 agentId
    ) external onlyArtistOrAgentOwner(collectionId, agentId, false) {
        if (_collections[collectionId].active) {
            revert TripleAErrors.CollectionAlreadyActive();
        }

        _collections[collectionId].active = true;
        _activeCollections[_collections[collectionId].artist].add(collectionId);
        emit CollectionActivated(collectionId);
    }

    function deleteCollection(
        uint256 collectionId,
        uint256 agentId
    ) external onlyArtistOrAgentOwner(collectionId, agentId, false) {
        if (_collections[collectionId].amountSold > 0) {
            revert TripleAErrors.CantDeleteSoldCollection();
        }

        for (
            uint8 i = 0;
            i < _collections[collectionId].agentIds.length();
            i++
        ) {
            agents.removeWorker(
                _collections[collectionId].agentIds.at(i),
                collectionId
            );
            agents.transferBalance(
                _collections[collectionId].erc20Tokens.values(),
                _collections[collectionId].artist,
                _collections[collectionId].agentIds.at(i)
            );
        }

        uint256 _dropId = _collections[collectionId].dropId;

        _drops[_dropId].collectionIds.remove(collectionId);

        for (
            uint8 i = 0;
            i < _collections[collectionId].erc20Tokens.length();
            i++
        ) {
            delete _collectionPrices[collectionId][
                _collections[collectionId].erc20Tokens.at(i)
            ];
        }
        _activeCollections[msg.sender].remove(collectionId);

        if (
            _activeCollections[_collections[collectionId].artist].length() < 1
        ) {
            _updateAgentBalance(collectionId);
        }
        delete _collections[collectionId];

        emit CollectionDeleted(msg.sender, collectionId);
    }

    function deleteDrop(
        uint256 dropId,
        uint256 agentId
    ) external onlyArtistOrAgentOwner(dropId, agentId, true) {
        uint256[] memory _collectionIds = _drops[dropId].collectionIds.values();
        for (uint8 i = 0; i < _collectionIds.length; i++) {
            if (_collections[_collectionIds[i]].amountSold > 0) {
                revert TripleAErrors.CantDeleteSoldCollection();
            }

            delete _collections[_collectionIds[i]];
            _activeCollections[msg.sender].remove(_collectionIds[i]);
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

        if (
            _collections[collectionId].amountSold ==
            _collections[collectionId].amount
        ) {
            if (
                _activeCollections[_collections[collectionId].artist]
                    .length() == 1
            ) {
                _activeCollections[_collections[collectionId].artist].remove(
                    collectionId
                );
                _updateAgentBalance(collectionId);
            }
        }
    }

    function changeRemixable(
        uint256 collectionId,
        uint256 agentId,
        bool remixable
    ) external onlyArtistOrAgentOwner(collectionId, agentId, false) {
        _collections[collectionId].remixable = remixable;

        emit Remixable(collectionId, remixable);
    }

    function _updateAgentBalance(uint256 collectionId) internal {
        for (
            uint8 i = 8;
            i < _collections[collectionId].agentIds.length();
            i++
        ) {
            agents.transferBalance(
                _collections[collectionId].erc20Tokens.values(),
                _collections[collectionId].artist,
                _collections[collectionId].agentIds.at(i)
            );
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
        return _drops[dropId].collectionIds.values();
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
        return _collections[collectionId].agentIds.values();
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

    function getCollectionForArtist(
        uint256 collectionId
    ) public view returns (address) {
        return _collections[collectionId].forArtist;
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

    function getArtistActiveCollections(
        address artist
    ) public view returns (uint256[] memory) {
        return _activeCollections[artist].values();
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

    function setSkyhuntersAgentManager(
        address payable _skyhuntersAgentManager
    ) external onlyAdmin {
        skyhuntersAgentManager = SkyhuntersAgentManager(
            _skyhuntersAgentManager
        );
    }

    function setAgents(address payable _agents) external onlyAdmin {
        agents = TripleAAgents(_agents);
    }
}
