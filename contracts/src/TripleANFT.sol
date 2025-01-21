// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./TripleAErrors.sol";
import "./TripleAAccessControls.sol";

contract TripleANFT is ERC721 {
    uint256 private _tokenCounter;
    address public marketplace;
    TripleAAccessControls public accessControls;
    mapping(uint256 => string) private _tokenURIs;

    modifier onlyAdmin() {
        if (!accessControls.isAdmin(msg.sender)) {
            revert TripleAErrors.NotAdmin();
        }
        _;
    }

    event NFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        string tokenURI
    );

    modifier onlyMarket() {
        if (msg.sender != marketplace) {
            revert TripleAErrors.OnlyMarketContract();
        }
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address payable _accessControls
    ) payable ERC721(name, symbol) {
        accessControls = TripleAAccessControls(_accessControls);
    }

    function mint(
        uint256 amount,
        address to,
        string memory newTokenURI
    ) external onlyMarket returns (uint256[] memory) {
        if (to == address(0)) {
            revert TripleAErrors.ZeroAddress();
        }

        if (amount <= 0) {
            revert TripleAErrors.InvalidAmount();
        }

        uint256[] memory mintedTokenIds = new uint256[](amount);

        for (uint8 i = 0; i < amount; i++) {
            _tokenCounter++;
            uint256 _newTokenId = _tokenCounter;

            _safeMint(to, _newTokenId);
            _tokenURIs[_newTokenId] = newTokenURI;

            mintedTokenIds[i] = _newTokenId;
            emit NFTMinted(to, _newTokenId, newTokenURI);
        }

        return mintedTokenIds;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function getTokenCounter() public view returns (uint256) {
        return _tokenCounter;
    }

    function setMarket(address _marketplace) external onlyAdmin {
        marketplace = _marketplace;
    }

    function setAccessControls(
        address payable _accessControls
    ) external onlyAdmin {
        accessControls = TripleAAccessControls(_accessControls);
    }
}
