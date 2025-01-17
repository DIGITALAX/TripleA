// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "src/AAACollectionManager.sol";
import "src/AAAAccessControls.sol";
import "src/AAAErrors.sol";
import "src/AAALibrary.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract AAACollectionManagerTest is Test {
    AAACollectionManager private collectionManager;
    AAAAccessControls private accessControls;
    address private admin = address(0x123);
    address private artist = address(0x456);
    address private market = address(0x789);

    MockERC20 private token1;
    MockERC20 private token2;

    function setUp() public {
        accessControls = new AAAAccessControls();
        collectionManager = new AAACollectionManager(
            payable(address(accessControls))
        );
        token1 = new MockERC20("Token1", "TK1");
        token2 = new MockERC20("Token2", "TK2");
        accessControls.addAdmin(admin);
        vm.startPrank(admin);
        collectionManager.setMarket(market);
        vm.stopPrank();
    }

    function testCreateDropAndCollections() public {
        vm.startPrank(artist);
        AAALibrary.CollectionInput memory inputs_1 = AAALibrary
            .CollectionInput({
                tokens: new address[](2),
                prices: new uint256[](2),
                agentIds: new uint256[](3),
                customInstructions: new string[](3),
                dailyFrequency: new uint256[](3),
                metadata: "Metadata 1",
                amount: 1
            });
        inputs_1.tokens[0] = address(token1);
        inputs_1.tokens[1] = address(token2);
        inputs_1.prices[0] = 10000000000000000000;
        inputs_1.prices[1] = 25000000000000000000;
        inputs_1.agentIds[0] = 1;
        inputs_1.agentIds[1] = 3;
        inputs_1.agentIds[2] = 5;
        inputs_1.customInstructions[0] = "custom1";
        inputs_1.customInstructions[1] = "custom2";
        inputs_1.customInstructions[2] = "custom3";
        inputs_1.dailyFrequency[0] = 1;
        inputs_1.dailyFrequency[1] = 2;
        inputs_1.dailyFrequency[2] = 3;

        AAALibrary.CollectionInput memory inputs_2 = AAALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 2",
                customInstructions: new string[](1),
                dailyFrequency: new uint256[](1),
                amount: 10
            });

        inputs_2.tokens[0] = address(token2);
        inputs_2.prices[0] = 13200000000000000000;
        inputs_2.agentIds[0] = 3;
        inputs_2.customInstructions[0] = "another custom";
        inputs_2.dailyFrequency[0] = 1;

        collectionManager.create(inputs_1, "some drop URI", 0);
        collectionManager.create(inputs_2, "", 1);

        uint256[] memory dropIds = collectionManager.getDropIdsByArtist(artist);
        assertEq(dropIds.length, 1);
        assertEq(dropIds[0], 1);

        uint256[] memory collectionIds = collectionManager.getDropCollectionIds(
            1
        );
        assertEq(collectionIds.length, 2);
        assertEq(
            collectionManager.getCollectionMetadata(collectionIds[0]),
            "Metadata 1"
        );
        assertEq(
            collectionManager.getCollectionMetadata(collectionIds[1]),
            "Metadata 2"
        );
        assertEq(
            collectionManager.getCollectionERC20Tokens(collectionIds[0])[0],
            address(token1)
        );
        assertEq(
            collectionManager.getCollectionERC20Tokens(collectionIds[0])[1],
            address(token2)
        );

        assertEq(
            collectionManager.getCollectionPrices(collectionIds[0])[0],
            10000000000000000000
        );
        assertEq(
            collectionManager.getCollectionPrices(collectionIds[0])[1],
            25000000000000000000
        );
        assertEq(
            collectionManager.getCollectionAgentIds(collectionIds[0])[0],
            1
        );
        assertEq(
            collectionManager.getCollectionAgentIds(collectionIds[0])[1],
            3
        );
        assertEq(
            collectionManager.getCollectionAgentIds(collectionIds[0])[2],
            5
        );
        assertEq(collectionManager.getCollectionAmount(collectionIds[0]), 1);

        assertEq(
            collectionManager.getCollectionMetadata(collectionIds[1]),
            "Metadata 2"
        );
        assertEq(
            collectionManager.getCollectionERC20Tokens(collectionIds[1])[0],
            address(token2)
        );
        assertEq(
            collectionManager.getCollectionPrices(collectionIds[1])[0],
            13200000000000000000
        );
        assertEq(
            collectionManager.getCollectionAgentIds(collectionIds[1])[0],
            3
        );
        assertEq(collectionManager.getCollectionAmount(collectionIds[1]), 10);

        assertEq(
            collectionManager.getAgentCollectionCustomInstructions(
                collectionIds[0],
                1
            ),
            "custom1"
        );
        assertEq(
            collectionManager.getAgentCollectionCustomInstructions(
                collectionIds[0],
                3
            ),
            "custom2"
        );
        assertEq(
            collectionManager.getAgentCollectionCustomInstructions(
                collectionIds[0],
                5
            ),
            "custom3"
        );
  

        vm.stopPrank();
    }

    function testCreateCollectionExistingDrop() public {
        testCreateDropAndCollections();

        vm.startPrank(artist);
        AAALibrary.CollectionInput memory inputs_1 = AAALibrary
            .CollectionInput({
                tokens: new address[](2),
                prices: new uint256[](2),
                agentIds: new uint256[](3),
                customInstructions: new string[](3),
                dailyFrequency: new uint256[](3),
                metadata: "Metadata 2",
                amount: 1
            });
        inputs_1.tokens[0] = address(token1);
        inputs_1.tokens[1] = address(token2);
        inputs_1.prices[0] = 10000000000000000000;
        inputs_1.prices[1] = 25000000000000000000;
        inputs_1.agentIds[0] = 1;
        inputs_1.agentIds[1] = 3;
        inputs_1.agentIds[2] = 5;
        inputs_1.customInstructions[0] = "custom1";
        inputs_1.customInstructions[1] = "custom2";
        inputs_1.customInstructions[2] = "custom3";
        inputs_1.dailyFrequency[0] = 1;
        inputs_1.dailyFrequency[1] = 2;
        inputs_1.dailyFrequency[2] = 3;

        AAALibrary.CollectionInput memory inputs_2 = AAALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                customInstructions: new string[](1),
                dailyFrequency: new uint256[](1),
                metadata: "Metadata 3",
                amount: 10
            });

        inputs_2.tokens[0] = address(token2);
        inputs_2.prices[0] = 13200000000000000000;
        inputs_2.agentIds[0] = 3;
        inputs_2.customInstructions[0] = "another custom";
        inputs_2.dailyFrequency[0] = 1;
        collectionManager.create(inputs_1, "", 1);
        collectionManager.create(inputs_2, "", 1);

        uint256[] memory dropIds = collectionManager.getDropIdsByArtist(artist);

        assertEq(dropIds.length, 1);
        assertEq(dropIds[0], 1);

        uint256[] memory collectionIds = collectionManager.getDropCollectionIds(
            1
        );
        assertEq(collectionIds.length, 4);

        vm.expectRevert(abi.encodeWithSelector(AAAErrors.DropInvalid.selector));
        collectionManager.create(inputs_1, "", 2);
    }

    function testDeleteCollection() public {
        testCreateDropAndCollections();

        vm.startPrank(artist);
        collectionManager.deleteCollection(1);

        vm.startPrank(admin);
        vm.expectRevert(abi.encodeWithSelector(AAAErrors.NotArtist.selector));
        collectionManager.deleteCollection(2);

        uint256[] memory dropIds = collectionManager.getDropIdsByArtist(artist);
        assertEq(dropIds.length, 1);
        assertEq(dropIds[0], 1);

        uint256[] memory collectionIds = collectionManager.getDropCollectionIds(
            1
        );
        assertEq(collectionIds.length, 1);
        assertEq(collectionIds[0], 2);

        vm.startPrank(artist);
        collectionManager.deleteCollection(2);

        uint256[] memory dropIds_saved = collectionManager.getDropIdsByArtist(
            artist
        );
        assertEq(dropIds_saved.length, 0);
    }

    function testDeleteDrop() public {
        testCreateDropAndCollections();
        uint256[] memory dropIds_first = collectionManager.getDropIdsByArtist(
            artist
        );
        assertEq(dropIds_first.length, 1);

        vm.startPrank(artist);
        collectionManager.deleteDrop(1);

        uint256[] memory dropIds = collectionManager.getDropIdsByArtist(artist);
        assertEq(dropIds.length, 0);
    }

    function testSetMarket() public {
        vm.startPrank(admin);
        collectionManager.setMarket(address(0x1234));
        assertEq(collectionManager.market(), address(0x1234));
        vm.stopPrank();
    }

    function testSetAccessControls() public {
        AAAAccessControls newAccessControls = new AAAAccessControls();
        vm.startPrank(admin);
        collectionManager.setAccessControls(
            payable(address(newAccessControls))
        );
        assertEq(
            address(collectionManager.accessControls()),
            address(newAccessControls)
        );
        vm.stopPrank();
    }

    function testOnlyMarketModifier() public {
        vm.prank(artist);
        uint256[] memory mintedTokenIds = new uint256[](1);
        mintedTokenIds[0] = 1;
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.OnlyMarketContract.selector)
        );
        collectionManager.updateData(mintedTokenIds, 1, 1);
    }

    function testOnlyAdminModifier() public {
        vm.prank(artist);
        vm.expectRevert(abi.encodeWithSelector(AAAErrors.NotAdmin.selector));
        collectionManager.setMarket(address(0x1234));
    }
}
