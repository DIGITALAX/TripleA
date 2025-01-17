// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "./../src/AAAMarket.sol";
import "./../src/AAANFT.sol";
import "./../src/AAADevTreasury.sol";
import "./../src/AAAAgents.sol";
import "./../src/AAACollectionManager.sol";
import "./../src/AAAAccessControls.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract AAAMarketTest is Test {
    AAAMarket private market;
    AAADevTreasury private devTreasury;
    AAAAgents private agents;
    AAACollectionManager private collectionManager;
    AAAAccessControls private accessControls;
    AAANFT private nft;
    MockERC20 private token1;
    MockERC20 private token2;

    address private admin = address(0x123);
    address private artist = address(0x456);
    address private buyer = address(0x789);

    function setUp() public {
        accessControls = new AAAAccessControls();
        collectionManager = new AAACollectionManager(
            (address(accessControls))
        );

        nft = new AAANFT(
            "Triple A NFT",
            "AAANFT",
            (address(accessControls))
        );
        devTreasury = new AAADevTreasury((address(accessControls)));
        agents = new AAAAgents(
            (address(accessControls)),
            address(devTreasury),
            address(collectionManager)
        );
        market = new AAAMarket(
            address(nft),
            address(collectionManager),
            (address(accessControls)),
            address(agents)
        );

        token1 = new MockERC20("Token1", "TK1");
        token2 = new MockERC20("Token2", "TK2");

        accessControls.addAdmin(admin);

        vm.startPrank(admin);
        collectionManager.setMarket(address(market));
        accessControls.setAgentsContract(address(agents));
        nft.setMarket(address(market));
        market.setDevTreasury(address(devTreasury));
        agents.setMarket(address(market));
        accessControls.setAcceptedToken(address(token1));
        accessControls.setTokenThresholdAndRent(
            address(token1),
            60000000000000000000,
            1000000000
        );
        accessControls.setAcceptedToken(address(token2));
        accessControls.setTokenThresholdAndRent(
            address(token2),
            100000000000000000000,
            100000000
        );
        devTreasury.setMarket(address(market));
        devTreasury.setAgents(address(agents));
        vm.stopPrank();
    }

    function testBuyCollection() public {
        vm.startPrank(artist);

        AAALibrary.CollectionInput memory inputs_1 = AAALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                dailyFrequency: new uint256[](1),
                customInstructions: new string[](1),
                metadata: "Metadata 1",
                amount: 5
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;
        inputs_1.customInstructions[0] = "custom";
        inputs_1.dailyFrequency[0] = 1;
        collectionManager.create(inputs_1, "some drop uri", 0);
        vm.stopPrank();

        token1.mint(buyer, 100 ether);

        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);

        vm.startPrank(buyer);
        token1.approve(address(market), 50 ether);
        token1.approve(address(devTreasury), 50 ether);
        token1.allowance(buyer, address(market));
        token1.allowance(buyer, address(devTreasury));
        market.buy(1, 1, address(token1));

        uint256 buyerExpectedBalance = buyerInitialBalance - (10 ether);
        uint256 artistExpectedBalance = artistInitialBalance + (10 ether);

        assertEq(token1.balanceOf(buyer), buyerExpectedBalance);
        assertEq(token1.balanceOf(artist), artistExpectedBalance);

        uint256 amountSold = collectionManager.getCollectionAmountSold(1);
        assertEq(amountSold, 1);
    }

    function testBuyWithInvalidToken() public {
        vm.startPrank(artist);

        AAALibrary.CollectionInput memory inputs_1 = AAALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                dailyFrequency: new uint256[](1),
                customInstructions: new string[](1),
                metadata: "Metadata 2",
                amount: 5
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;
        inputs_1.customInstructions[0] = "custom";
        inputs_1.dailyFrequency[0] = 1;
        collectionManager.create(inputs_1, "some 2 drop", 0);
        vm.stopPrank();

        token2.mint(buyer, 100 ether);
        vm.startPrank(buyer);
        token2.approve(address(devTreasury), 50 ether);
        token2.approve(address(market), 50 ether);
        token2.allowance(buyer, address(market));
        token2.allowance(buyer, address(devTreasury));

        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.TokenNotAccepted.selector)
        );
        market.buy(1, 2, address(token2));
        vm.stopPrank();
    }

    function createAgent() public {
        vm.startPrank(admin);
        address[] memory wallets = new address[](1);
        wallets[0] = address(0x789);
        agents.createAgent(wallets, "Agent Metadata");
    }

    function testBuyCollectionOverThreshold() public {
        createAgent();
        vm.startPrank(artist);

        AAALibrary.CollectionInput memory inputs_1 = AAALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                customInstructions: new string[](1),
                dailyFrequency: new uint256[](1),
                metadata: "Metadata Over Threshold",
                amount: 10
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 70 ether;
        inputs_1.agentIds[0] = 1;
        inputs_1.customInstructions[0] = "custom";
        inputs_1.dailyFrequency[0] = 1;

        collectionManager.create(inputs_1, "some 3 drop", 0);
        vm.stopPrank();

        token1.mint(buyer, 250 ether);
        vm.startPrank(buyer);
        token1.approve(address(market), 250 ether);
        token1.approve(address(devTreasury), 250 ether);
        token1.allowance(buyer, address(market));
        token1.allowance(buyer, address(devTreasury));

        market.buy(1, 1, address(token1));

        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);
        uint256 devTreasuryInitialBalance = token1.balanceOf(
            address(devTreasury)
        );

        market.buy(1, 2, address(token1));
        vm.stopPrank();

        uint256 totalPrice = 70 ether * 2;
        uint256 agentShare = (totalPrice * 10) / 100;
        uint256 artistShare = totalPrice - agentShare;

        uint256 buyerExpectedBalance = buyerInitialBalance - totalPrice;
        uint256 artistExpectedBalance = artistInitialBalance + artistShare;
        uint256 devTreasuryExpectedBalance = devTreasuryInitialBalance +
            agentShare;

        assertEq(token1.balanceOf(buyer), buyerExpectedBalance);
        assertEq(token1.balanceOf(artist), artistExpectedBalance);
        assertEq(
            token1.balanceOf(address(devTreasury)),
            devTreasuryExpectedBalance
        );

        uint256 agentBalance = agents.getAgentActiveBalance(
            address(token1),
            1,
            1
        );
        uint256 bonusBalance = agents.getAgentBonusBalance(
            address(token1),
            1,
            1
        );
        uint256 rent = accessControls.getTokenDailyRent(address(token1));
        assertEq(agentBalance, rent);
        assertEq(bonusBalance, agentShare - rent);

        uint256 amountSold = collectionManager.getCollectionAmountSold(1);
        assertEq(amountSold, 3);
    }

    function testSetCollectionManager() public {
        vm.startPrank(admin);
        AAACollectionManager newCollectionManager = new AAACollectionManager(
            (address(accessControls))
        );
        market.setCollectionManager(address(newCollectionManager));
        assertEq(
            address(market.collectionManager()),
            address(newCollectionManager)
        );
        vm.stopPrank();
    }

    function testSetNFT() public {
        vm.startPrank(admin);
        AAANFT newNFT = new AAANFT(
            "Triple A NFT",
            "AAANFT",
            (address(accessControls))
        );
        market.setNFT(address(newNFT));
        assertEq(address(market.nft()), address(newNFT));
        vm.stopPrank();
    }

    function testSetAccessControls() public {
        vm.startPrank(admin);
        AAAAccessControls newAccessControls = new AAAAccessControls();
        market.setAccessControls((address(newAccessControls)));
        assertEq(address(market.accessControls()), address(newAccessControls));
        vm.stopPrank();
    }

    function testOnlyAdminReverts() public {
        vm.prank(artist);
        vm.expectRevert(abi.encodeWithSelector(AAAErrors.NotAdmin.selector));
        market.setCollectionManager(address(collectionManager));
    }
}
