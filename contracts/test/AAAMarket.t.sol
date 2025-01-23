// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "./../src/TripleAMarket.sol";
import "./../src/TripleANFT.sol";
import "./../src/TripleADevTreasury.sol";
import "./../src/TripleAAgents.sol";
import "./../src/TripleACollectionManager.sol";
import "./../src/TripleAAccessControls.sol";
import "./../src/TripleAFulfillerManager.sol";
import "./../src/skyhunters/SkyhuntersAccessControls.sol";
import "./../src/skyhunters/SkyhuntersPools.sol";
import "./../src/skyhunters/SkyhuntersReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TripleAMarketTest is Test {
    TripleAMarket private market;
    TripleADevTreasury private devTreasury;
    TripleAAgents private agents;
    TripleAFulfillerManager private fulfillerManager;
    TripleACollectionManager private collectionManager;
    TripleAAccessControls private accessControls;
    TripleANFT private nft;
    MockERC20 private token1;
    MockERC20 private token2;

    SkyhuntersReceiver private receiver;
    SkyhuntersAccessControls private skyhuntersAccess;
    SkyhuntersPools private pools;

    address private admin = address(0x123);
    address private artist = address(0x456);
    address private buyer = address(0x789);
    address private fulfiller = address(0x1324);

    function _skyhunters() public {
        vm.startPrank(admin);
        skyhuntersAccess = new SkyhuntersAccessControls();
        pools = new SkyhuntersPools(payable(address(accessControls)));
        receiver = new SkyhuntersReceiver(payable(address(accessControls)));

        vm.stopPrank();
    }

    function setUp() public {
        accessControls = new TripleAAccessControls();
        collectionManager = new TripleACollectionManager(
            payable(address(accessControls))
        );
        fulfillerManager = new TripleAFulfillerManager(
            payable(address(accessControls))
        );
        nft = new TripleANFT(
            "Triple A NFT",
            "TripleANFT",
            payable(address(accessControls))
        );
        devTreasury = new TripleADevTreasury(payable(address(accessControls)));
        agents = new TripleAAgents(
            payable(address(accessControls)),
            payable(address(devTreasury)),
            address(collectionManager)
        );
        market = new TripleAMarket(
            address(nft),
            address(collectionManager),
            payable(address(accessControls)),
            address(agents),
            address(fulfillerManager)
        );

        token1 = new MockERC20("Token1", "TK1");
        token2 = new MockERC20("Token2", "TK2");

        accessControls.addAdmin(admin);

        _skyhunters();

        vm.startPrank(admin);
        collectionManager.setMarket(address(market));
        collectionManager.setAgents(address(agents));
        accessControls.setAgentsContract(address(agents));
        nft.setMarket(address(market));
        market.setDevTreasury(payable(address(devTreasury)));
        agents.setMarket(address(market));
        accessControls.setAcceptedToken(address(token1));
        accessControls.setTokenDetails(
            address(token1),
            100000000,
            110,
            105,
            10,
            3000000000000000000,
            15000000000000000000
        );
        accessControls.setAcceptedToken(address(token2));
        accessControls.setTokenDetails(
            address(token2),
            100000000,
            120,
            125,
            12,
            5000000000000000000,
            12000000000000000000
        );
        devTreasury.setMarket(address(market));
        devTreasury.setAgents(address(agents));
        devTreasury.setReceiver(payable(address(receiver)));
        fulfillerManager.setMarket(address(market));
        accessControls.addFulfiller(fulfiller);
        vm.stopPrank();

        vm.startPrank(fulfiller);
        fulfillerManager.createFulfillerProfile(
            TripleALibrary.FulfillerInput({
                metadata: "fulfiller metadata",
                wallet: fulfiller
            })
        );

        vm.stopPrank();
    }

    function testBuyCollection() public {
        vm.startPrank(artist);

        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                cycleFrequency: new uint256[](1),
                customInstructions: new string[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;
        inputs_1.customInstructions[0] = "custom";
        inputs_1.cycleFrequency[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        token1.mint(buyer, 100 ether);

        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);

        vm.startPrank(buyer);
        token1.approve(address(market), 50 ether);
        token1.approve(address(devTreasury), 50 ether);
        token1.allowance(buyer, address(market));
        token1.allowance(buyer, address(devTreasury));
        market.buy("fulfillment", address(token1), 1, 1);

        uint256 buyerExpectedBalance = buyerInitialBalance - (10 ether);
        uint256 artistExpectedBalance = artistInitialBalance + (10 ether);

        assertEq(token1.balanceOf(buyer), buyerExpectedBalance);
        assertEq(token1.balanceOf(artist), artistExpectedBalance);

        uint256 amountSold = collectionManager.getCollectionAmountSold(1);
        assertEq(amountSold, 1);
    }

    function testBuyWithInvalidToken() public {
        vm.startPrank(artist);

        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                cycleFrequency: new uint256[](1),
                customInstructions: new string[](1),
                metadata: "Metadata 2",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;
        inputs_1.customInstructions[0] = "custom";
        inputs_1.cycleFrequency[0] = 1;
        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true
        });
        collectionManager.create(inputs_1, workers_1, "some 2 drop", 0);
        vm.stopPrank();

        token2.mint(buyer, 100 ether);
        vm.startPrank(buyer);
        token2.approve(address(devTreasury), 50 ether);
        token2.approve(address(market), 50 ether);
        token2.allowance(buyer, address(market));
        token2.allowance(buyer, address(devTreasury));

        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.TokenNotAccepted.selector)
        );
        market.buy("fulfillment", address(token2), 1, 2);
        vm.stopPrank();
    }

    function createAgent() public {
        vm.startPrank(admin);
        address[] memory wallets = new address[](1);
        wallets[0] = address(0x789);
        address[] memory owners = new address[](1);
        owners[0] = admin;
        agents.createAgent(wallets, owners, "Agent Metadata");
    }

    function testBuyCollectionOverThreshold() public {
        createAgent();
        vm.startPrank(artist);

        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                customInstructions: new string[](1),
                cycleFrequency: new uint256[](1),
                metadata: "Metadata Over Threshold",
                amount: 10,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 70 ether;
        inputs_1.agentIds[0] = 1;
        inputs_1.customInstructions[0] = "custom";
        inputs_1.cycleFrequency[0] = 1;
        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true
        });
        collectionManager.create(inputs_1, workers_1, "some 3 drop", 0);
        vm.stopPrank();

        token1.mint(buyer, 250 ether);
        vm.startPrank(buyer);
        token1.approve(address(market), 250 ether);
        token1.approve(address(devTreasury), 250 ether);
        token1.allowance(buyer, address(market));
        token1.allowance(buyer, address(devTreasury));

        market.buy("fulfillment", address(token1), 1, 1);

        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);
        uint256 devTreasuryInitialBalance = token1.balanceOf(
            address(devTreasury)
        );

        market.buy("fulfillment", address(token1), 1, 2);
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
        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1));
        assertEq(agentBalance, rent);
        assertEq(bonusBalance, agentShare - rent);

        uint256 amountSold = collectionManager.getCollectionAmountSold(1);
        assertEq(amountSold, 3);
    }

    function testSetCollectionManager() public {
        vm.startPrank(admin);
        TripleACollectionManager newCollectionManager = new TripleACollectionManager(
                payable(address(accessControls))
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
        TripleANFT newNFT = new TripleANFT(
            "Triple A NFT",
            "TripleANFT",
            payable(address(accessControls))
        );
        market.setNFT(address(newNFT));
        assertEq(address(market.nft()), address(newNFT));
        vm.stopPrank();
    }

    function testSetAccessControls() public {
        vm.startPrank(admin);
        TripleAAccessControls newAccessControls = new TripleAAccessControls();
        market.setAccessControls(payable(address(newAccessControls)));
        assertEq(address(market.accessControls()), address(newAccessControls));
        vm.stopPrank();
    }

    function testOnlyAdminReverts() public {
        vm.prank(artist);
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.NotAdmin.selector)
        );
        market.setCollectionManager(address(collectionManager));
    }
}
