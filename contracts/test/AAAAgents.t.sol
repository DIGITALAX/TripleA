// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "src/TripleAAgents.sol";
import "src/TripleAErrors.sol";
import "src/TripleALibrary.sol";
import "src/TripleAAccessControls.sol";
import "src/TripleADevTreasury.sol";
import "src/TripleACollectionManager.sol";
import "src/TripleANFT.sol";
import "src/TripleAMarket.sol";
import "src/TripleAFulfillerManager.sol";
import "./../src/skyhunters/SkyhuntersAccessControls.sol";
import "./../src/skyhunters/SkyhuntersPools.sol";
import "./../src/skyhunters/SkyhuntersReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

struct BuyersInput {
    uint256 agent1Coll1Bonus;
    uint256 agent1Coll2Bonus;
    uint256 agent2Coll2Bonus;
    uint256 buyerBalance1;
    uint256 buyerBalance2;
}

struct BonusInput {
    uint256 ownerBalanceAgent1;
    uint256 ownerBalanceAgent2;
    uint256 treasuryBalance;
}

contract TripleAAgentsTest is Test {
    TripleAAgents private agents;
    TripleAAccessControls private accessControls;
    TripleACollectionManager private collectionManager;
    TripleADevTreasury private devTreasury;
    TripleAMarket private market;
    TripleANFT private nft;
    TripleAFulfillerManager private fulfillerManager;
    string private metadata = "Agent Metadata";
    address private agentWallet = address(0x789);
    string private metadata2 = "Agent Metadata1";
    address private agentWallet2 = address(0x78219);
    address private admin = address(0x123);
    address private artist = address(0x456);
    address private recharger = address(0x78932);
    address private recharger2 = address(0x78988);
    address private agentOwner = address(0x131);
    address private agentOwner2 = address(0x135);
    address private agentOwner3 = address(0x125);
    address private buyer = address(0x132);
    address private buyer2 = address(0x1323);
    address private fulfiller = address(0x1324);

    MockERC20 private token1;
    MockERC20 private token2;

        SkyhuntersReceiver private receiver;
    SkyhuntersAccessControls private skyhuntersAccess;
    SkyhuntersPools private pools;


      function _skyhunters() public {
        vm.startPrank(admin);
        skyhuntersAccess = new SkyhuntersAccessControls();
        pools = new SkyhuntersPools(payable(address(accessControls)));
        receiver = new SkyhuntersReceiver(payable(address(accessControls)));

        vm.stopPrank();
    }

    function setUp() public {
        accessControls = new TripleAAccessControls();
        devTreasury = new TripleADevTreasury(payable(address(accessControls)));
        nft = new TripleANFT(
            "Triple A NFT",
            "TripleANFT",
            payable(address(accessControls))
        );
        fulfillerManager = new TripleAFulfillerManager(
            payable(address(accessControls))
        );
        collectionManager = new TripleACollectionManager(
            payable(address(accessControls))
        );
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
        nft.setMarket(address(market));
        market.setDevTreasury(payable(address(devTreasury)));
        agents.setMarket(address(market));
        accessControls.setAgentsContract(address(agents));
        collectionManager.setMarket(address(market));
          collectionManager.setAgents(address(agents));
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

    function testCreateAgent() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);
        uint256 agentId = agents.getAgentCounter();
        assertEq(agentId, 1);
        assertEq(agents.getAgentWallets(agentId)[0], agentWallet);
        assertEq(agents.getAgentMetadata(agentId), metadata);

        vm.stopPrank();
    }

    function testEditAgent() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);

        uint256 agentId = agents.getAgentCounter();
        string memory newMetadata = "Updated Metadata";

        agents.editAgent(newMetadata, agentId);

        assertEq(agents.getAgentMetadata(agentId), newMetadata);

        vm.stopPrank();
    }

    function testEditAgentRevertIfNotAgentOwner() public {
        vm.startPrank(admin);
        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);
        uint256 agentId = agents.getAgentCounter();
        vm.stopPrank();

        vm.startPrank(address(0xABC));
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.NotAgentOwner.selector)
        );

        agents.editAgent("New Metadata", agentId);
        vm.stopPrank();
    }

    function testDeleteAgent() public {
        vm.startPrank(agentOwner);
        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);

        uint256 agentId = agents.getAgentCounter();

        agents.deleteAgent(agentId);

        vm.stopPrank();
    }

    function testDeleteAgentRevertIfNotAgentOwner() public {
        vm.startPrank(admin);
        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);
        uint256 agentId = agents.getAgentCounter();
        vm.stopPrank();

        vm.startPrank(address(0xABC));
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.NotAgentOwner.selector)
        );
        agents.deleteAgent(agentId);
        vm.stopPrank();
    }

    function testAgentCounterIncrements() public {
        vm.startPrank(admin);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = admin;
        owners[1] = agentOwner2;
        agents.createAgent(wallets, owners, metadata);
        uint256 firstAgentId = agents.getAgentCounter();

        address[] memory newWallets = new address[](1);
        newWallets[0] = address(0xDEF);
        address[] memory newOwners = new address[](1);
        newOwners[0] = agentOwner3;
        agents.createAgent(newWallets, newOwners, "Another Metadata");
        uint256 secondAgentId = agents.getAgentCounter();

        assertEq(firstAgentId, 1);
        assertEq(secondAgentId, 2);

        vm.stopPrank();
    }

    function testRechargeAgentActiveBalanceWithoutSale() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);
        vm.stopPrank();

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

        vm.startPrank(admin);
        token1.mint(recharger, 100 ether);
        vm.stopPrank();

        vm.startPrank(recharger);
        uint256 rechargerInitialBalance = token1.balanceOf(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));

        agents.rechargeAgentActiveBalance(address(token1), 1, 1, 123400000);
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.TokenNotAccepted.selector)
        );
        agents.rechargeAgentActiveBalance(address(token2), 1, 1, 100000000);

        vm.stopPrank();

        uint256 activeBalance = agents.getAgentActiveBalance(
            address(token1),
            1,
            1
        );
        uint256 bonusBalance = agents.getAgentBonusBalance(
            address(token1),
            1,
            1
        );
        assertEq(activeBalance, 123400000);

        assertEq(bonusBalance, 0);
        uint256 rechargerCurrentBalance = token1.balanceOf(recharger);
        assertEq(rechargerCurrentBalance, rechargerInitialBalance - 123400000);
    }

    function testRechargeAgentActiveBalanceWithSale() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                cycleFrequency: new uint256[](1),
                customInstructions: new string[](1),
                metadata: "Metadata 1",
                amount: 10,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 5 ether;
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

        vm.startPrank(admin);
        token1.mint(recharger, 100 ether);
        token1.mint(buyer, 100 ether);
        vm.stopPrank();

        vm.startPrank(recharger);
        uint256 rechargerInitialBalance = token1.balanceOf(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));

        agents.rechargeAgentActiveBalance(address(token1), 1, 1, 123400000);
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.TokenNotAccepted.selector)
        );
        agents.rechargeAgentActiveBalance(address(token2), 1, 1, 100000000);

        vm.stopPrank();

        uint256 activeBalance = agents.getAgentActiveBalance(
            address(token1),
            1,
            1
        );
        uint256 bonusBalance = agents.getAgentBonusBalance(
            address(token1),
            1,
            1
        );
        assertEq(activeBalance, 123400000);

        assertEq(bonusBalance, 0);
        uint256 rechargerCurrentBalance = token1.balanceOf(recharger);
        assertEq(rechargerCurrentBalance, rechargerInitialBalance - 123400000);

        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);

        vm.startPrank(buyer);
        token1.approve(address(market), 50 ether);
        token1.approve(address(devTreasury), 50 ether);
        token1.allowance(buyer, address(market));
        token1.allowance(buyer, address(devTreasury));
        market.buy("fulfillment details", address(token1), 1, 2);
        uint256 buyerExpectedBalance = buyerInitialBalance - (10 ether);
        uint256 artistExpectedBalance = artistInitialBalance + (9.5 ether);
        vm.stopPrank();

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist));

        vm.startPrank(buyer);
        market.buy("fulfillment details", address(token1), 1, 1);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1));
        uint256 activeBalance_after = agents.getAgentActiveBalance(
            address(token1),
            1,
            1
        );
        uint256 bonusBalance_after = agents.getAgentBonusBalance(
            address(token1),
            1,
            1
        );

        assertEq(bonusBalance_after, ((10 / 100) * 10 ether) - rent * 2);
        assertEq(activeBalance_after, 123400000 + rent * 2);
    }

    function testPayRentWithoutBonus() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);
        vm.stopPrank();

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

        vm.startPrank(admin);
        token1.mint(recharger, 100 ether);
        vm.stopPrank();

        vm.startPrank(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));
        agents.rechargeAgentActiveBalance(address(token1), 1, 1, 3000000000);
        vm.stopPrank();

        address[] memory tokens = new address[](1);
        tokens[0] = address(token1);
        uint256[] memory collectionIds = new uint256[](1);
        collectionIds[0] = 1;

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1));

        uint256 allBalance = devTreasury.getAllTimeBalanceByToken(
            address(token1)
        );
        uint256 oneBalance = devTreasury.getBalanceByToken(address(token1));
        uint256 allServices = devTreasury.getAllTimeServices(address(token1));
        uint256 oneServices = devTreasury.getServicesPaidByToken(
            address(token1)
        );

        assertEq(allBalance, 3000000000);
        assertEq(oneBalance, 3000000000);
        assertEq(allServices, rent);
        assertEq(oneServices, rent);

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        agents.payRent(tokens, collectionIds, 1);

        uint256 allBalance_after3 = devTreasury.getAllTimeBalanceByToken(
            address(token1)
        );
        uint256 oneBalance_after3 = devTreasury.getBalanceByToken(
            address(token1)
        );
        uint256 allServices_after3 = devTreasury.getAllTimeServices(
            address(token1)
        );
        uint256 oneServices_after3 = devTreasury.getServicesPaidByToken(
            address(token1)
        );

        assertEq(allBalance_after3, 3000000000);
        assertEq(oneBalance_after3, 3000000000);
        assertEq(allServices_after3, rent * 3);
        assertEq(oneServices_after3, rent * 3);

        // vm.expectRevert(
        //     abi.encodeWithSelector(TripleAErrors.InsufficientBalance.selector)
        // );
        agents.payRent(tokens, collectionIds, 1);
        // vm.stopPrank();
    }

    function testPayRentWithBonus() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                cycleFrequency: new uint256[](1),
                customInstructions: new string[](1),
                metadata: "Metadata 1",
                amount: 10,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 5 ether;
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

        vm.startPrank(admin);
        token1.mint(recharger, 100 ether);
        token1.mint(buyer, 100 ether);
        vm.stopPrank();

        vm.startPrank(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));
        agents.rechargeAgentActiveBalance(address(token1), 1, 1, 3000000000);
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.TokenNotAccepted.selector)
        );
        agents.rechargeAgentActiveBalance(address(token2), 1, 1, 3000000000);
        vm.stopPrank();

        vm.startPrank(buyer);
        token1.approve(address(market), 50 ether);
        token1.approve(address(devTreasury), 50 ether);
        token1.allowance(buyer, address(market));
        token1.allowance(buyer, address(devTreasury));
        market.buy("fulfillment details", address(token1), 1, 2);
        market.buy("fulfillment details", address(token1), 1, 1);
        vm.stopPrank();

        address[] memory tokens = new address[](1);
        tokens[0] = address(token1);
        uint256[] memory collectionIds = new uint256[](1);
        collectionIds[0] = 1;

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1));

        uint256 allBalance = devTreasury.getAllTimeBalanceByToken(
            address(token1)
        );
        uint256 oneBalance = devTreasury.getBalanceByToken(address(token1));
        uint256 allServices = devTreasury.getAllTimeServices(address(token1));
        uint256 oneServices = devTreasury.getServicesPaidByToken(
            address(token1)
        );

        assertEq(allBalance, ((10 / 100) * 10 ether) + 3000000000);
        assertEq(oneBalance, ((10 / 100) * 10 ether) + 3000000000);
        assertEq(allServices, rent);
        assertEq(oneServices, rent);

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        agents.payRent(tokens, collectionIds, 1);

        uint256 allBalance_after3 = devTreasury.getAllTimeBalanceByToken(
            address(token1)
        );
        uint256 oneBalance_after3 = devTreasury.getBalanceByToken(
            address(token1)
        );
        uint256 allServices_after3 = devTreasury.getAllTimeServices(
            address(token1)
        );
        uint256 oneServices_after3 = devTreasury.getServicesPaidByToken(
            address(token1)
        );

        assertEq(allBalance_after3, ((10 / 100) * 10 ether) + 3000000000);
        assertEq(oneBalance_after3, ((10 / 100) * 10 ether) + 3000000000);
        assertEq(allServices_after3, rent * 3);
        assertEq(oneServices_after3, rent * 3);

        vm.stopPrank();
    }

    function _collectionOne() internal {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        agents.createAgent(wallets, owners, metadata);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                cycleFrequency: new uint256[](1),
                customInstructions: new string[](1),
                metadata: "Metadata 1",
                amount: 10,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 5 ether;
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

        vm.startPrank(admin);
        token1.mint(recharger, 100 ether);
        token1.mint(buyer, 100 ether);
        vm.stopPrank();

        vm.startPrank(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));
        agents.rechargeAgentActiveBalance(address(token1), 1, 1, 3000000000);
        vm.stopPrank();
        vm.startPrank(buyer);
        token1.approve(address(market), 50 ether);
        token1.approve(address(devTreasury), 50 ether);
        token1.allowance(buyer, address(market));
        token1.allowance(buyer, address(devTreasury));
        market.buy("fulfillment details", address(token1), 1, 2);
        market.buy("fulfillment details", address(token1), 1, 1);
        vm.stopPrank();
    }

    function _collectionTwo() internal {
        vm.startPrank(agentOwner2);

        address[] memory wallets_2 = new address[](1);
        wallets_2[0] = agentWallet2;
        address[] memory owners_2 = new address[](2);
        owners_2[0] = agentOwner2;
        owners_2[1] = agentOwner3;
        agents.createAgent(wallets_2, owners_2, metadata2);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_2 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](2),
                cycleFrequency: new uint256[](2),
                customInstructions: new string[](2),
                metadata: "Metadata 2",
                amount: 10,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1
            });

        inputs_2.tokens[0] = address(token1);
        inputs_2.prices[0] = 5 ether;
        inputs_2.agentIds[0] = 1;
        inputs_2.agentIds[1] = 2;
        inputs_2.customInstructions[0] = "custom1";
        inputs_2.customInstructions[1] = "custom2";
        inputs_2.cycleFrequency[0] = 1;
        inputs_2.cycleFrequency[1] = 2;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](2);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true
        });
          workers_1[1] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true
        });
        collectionManager.create(inputs_2, workers_1, "some drop uri2", 0);
        vm.stopPrank();

        vm.startPrank(admin);
        token1.mint(recharger2, 100 ether);
        token1.mint(buyer2, 100 ether);
        vm.stopPrank();

        vm.startPrank(recharger2);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger2, address(agents));
        agents.rechargeAgentActiveBalance(address(token1), 1, 2, 3000000000);
        agents.rechargeAgentActiveBalance(address(token1), 2, 2, 3000000000);
        vm.stopPrank();

        vm.startPrank(buyer2);
        token1.approve(address(market), 50 ether);
        token1.approve(address(devTreasury), 50 ether);
        token1.allowance(buyer2, address(market));
        token1.allowance(buyer2, address(devTreasury));
        market.buy("fulfillment details", address(token1), 2, 2);
        market.buy("fulfillment details", address(token1), 2, 1);
        vm.stopPrank();
    }

    function testPayRentWithMultipleCollections()
        public
        returns (uint256, uint256)
    {
        _collectionOne();
        _collectionTwo();

        // pay rent

        address[] memory tokens = new address[](2);
        tokens[0] = address(token1);
        tokens[1] = address(token1);
        uint256[] memory collectionIds = new uint256[](2);
        collectionIds[0] = 1;
        collectionIds[1] = 2;

        uint256 buyerBalance1 = token1.balanceOf(address(buyer));
        uint256 buyerBalance2 = token1.balanceOf(address(buyer2));

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        vm.stopPrank();

        address[] memory tokens_2 = new address[](1);
        tokens_2[0] = address(token1);
        uint256[] memory collectionIds_2 = new uint256[](1);
        collectionIds_2[0] = 2;

        vm.startPrank(agentWallet2);
        agents.payRent(tokens_2, collectionIds_2, 2);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1));

        uint256 allBalance = devTreasury.getAllTimeBalanceByToken(
            address(token1)
        );
        uint256 oneBalance = devTreasury.getBalanceByToken(address(token1));
        uint256 allServices = devTreasury.getAllTimeServices(address(token1));
        uint256 oneServices = devTreasury.getServicesPaidByToken(
            address(token1)
        );

        // Two purchases for 10% + 10% of 5 ether
        // Recharged with 3000000000 3 times

        assertEq(allBalance, ((20 / 100) * 10 ether) + 9000000000);
        assertEq(oneBalance, ((20 / 100) * 10 ether) + 9000000000);
        assertEq(allServices, rent * 3);
        assertEq(oneServices, rent * 3);

        return (buyerBalance1, buyerBalance2);
    }

    function testCollectorsAndOwnerBonusPaid() public {
        uint256 ownerBalanceAgent1 = token1.balanceOf(address(agentOwner));
        uint256 ownerBalanceAgent2 = token1.balanceOf(address(agentOwner2));
        uint256 treasuryBalance = devTreasury.getTreasuryByToken(
            address(token1)
        );
        (
            uint256 buyerBalance1,
            uint256 buyerBalance2
        ) = testPayRentWithMultipleCollections();

        (
            uint256 agent1Coll1Bonus,
            uint256 agent1Coll2Bonus,
            uint256 agent2Coll2Bonus
        ) = _bonusesCalc(
                BonusInput({
                    ownerBalanceAgent1: ownerBalanceAgent1,
                    ownerBalanceAgent2: ownerBalanceAgent2,
                    treasuryBalance: treasuryBalance
                })
            );

        _buyersCalc(
            BuyersInput({
                agent1Coll1Bonus: agent1Coll1Bonus,
                agent1Coll2Bonus: agent1Coll2Bonus,
                agent2Coll2Bonus: agent2Coll2Bonus,
                buyerBalance1: buyerBalance1,
                buyerBalance2: buyerBalance2
            })
        );
    }

    function _buyersCalc(BuyersInput memory _buyersInput) internal view {
        // buyer1 buys 3 of collection 1 (1 agent)
        // buyer2 buys 3 of collection 2 (2 agents)
        uint256 buyerBalance1_after = token1.balanceOf(address(buyer));
        uint256 buyerBalance2_after = token1.balanceOf(address(buyer2));

        assertEq(
            buyerBalance1_after,
            _buyersInput.buyerBalance1 +
                ((_buyersInput.agent1Coll1Bonus * 30) / 100)
        );
        assertEq(
            buyerBalance2_after,
            _buyersInput.buyerBalance2 +
                ((_buyersInput.agent2Coll2Bonus * 30) / 100) +
                ((_buyersInput.agent1Coll2Bonus * 30) / 100)
        );
    }

    function _bonusesCalc(
        BonusInput memory _bonusInput
    ) internal view returns (uint256, uint256, uint256) {
        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1));
        uint256 agentShare_coll1 = ((10 / 100) * 5 ether); // one agent
        uint256 agentShare_coll2 = ((10 / 100) * 5 ether) / 2; // two agents

        uint256 agent1Coll1Bonus =( agentShare_coll1 - rent) * 2;
        uint256 agent1Coll2Bonus = (agentShare_coll2 - rent) * 2;
        uint256 agent2Coll2Bonus = (agentShare_coll2 - rent) * 2;

        assertEq(
            token1.balanceOf(address(agentOwner)),
           _bonusInput.ownerBalanceAgent1 +
                ((agent1Coll1Bonus * 30) / 100) / 2 +
                ((agent1Coll2Bonus * 30) / 100) / 2
        );
        assertEq(
            token1.balanceOf(address(agentOwner2)),
            _bonusInput.ownerBalanceAgent2 + ((agent2Coll2Bonus * 30) / 100) / 2
        );

        assertEq(
            devTreasury.getTreasuryByToken(address(token1)),
            _bonusInput.treasuryBalance +
                ((agent1Coll1Bonus * 40) / 100) +
                ((agent1Coll2Bonus * 40) / 100) +
                ((agent2Coll2Bonus * 40) / 100)
        );

        return (agent1Coll1Bonus, agent1Coll2Bonus, agent2Coll2Bonus);
    }

    function testWithDrawTreasuryAndServices() public {
        testPayRentWithMultipleCollections();
        uint256 allBalance_after = devTreasury.getAllTimeBalanceByToken(
            address(token1)
        );
        uint256 oneBalance_after = devTreasury.getBalanceByToken(
            address(token1)
        );
        uint256 allServices_after = devTreasury.getAllTimeServices(
            address(token1)
        );
        uint256 oneServices_after = devTreasury.getServicesPaidByToken(
            address(token1)
        );
        uint256 treasury_after = devTreasury.getTreasuryByToken(
            address(token1)
        );

        vm.startPrank(admin);
        devTreasury.withdrawFundsTreasury(address(token1), 200000);
        vm.stopPrank();

        assertEq(
            devTreasury.getAllTimeBalanceByToken(address(token1)),
            allBalance_after
        );
        assertEq(
            devTreasury.getBalanceByToken(address(token1)),
            oneBalance_after - 200000
        );
        assertEq(
            devTreasury.getAllTimeServices(address(token1)),
            allServices_after
        );
        assertEq(
            devTreasury.getServicesPaidByToken(address(token1)),
            oneServices_after
        );
        assertEq(
            devTreasury.getTreasuryByToken(address(token1)),
            treasury_after - 200000
        );

        // vm.startPrank(admin);
        // devTreasury.withdrawFundsServices(address(token1), 400000);
        // vm.stopPrank();

        assertEq(
            devTreasury.getAllTimeBalanceByToken(address(token1)),
            allBalance_after
        );
        assertEq(
            devTreasury.getTreasuryByToken(address(token1)),
            treasury_after - 200000
        );

        assertEq(
            devTreasury.getBalanceByToken(address(token1)),
            oneBalance_after - 200000 
        );
        assertEq(
            devTreasury.getAllTimeServices(address(token1)),
            allServices_after
        );
        assertEq(
            devTreasury.getServicesPaidByToken(address(token1)),
            oneServices_after 
        );
    }
}
