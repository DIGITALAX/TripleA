// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "src/TripleAAgents.sol";
import "src/TripleAErrors.sol";
import "src/TripleALibrary.sol";
import "src/TripleAAccessControls.sol";
import "src/TripleACollectionManager.sol";
import "src/TripleANFT.sol";
import "src/TripleAMarket.sol";
import "src/TripleAFulfillerManager.sol";
import "./../src/skyhunters/SkyhuntersAccessControls.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

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

contract TripleAAgentsTest is Test {
    TripleACollectionManager private collectionManager;
    TripleAAccessControls private accessControls;
    TripleAFulfillerManager private fulfillerManager;
    SkyhuntersAccessControls private skyhuntersAccess;
    SkyhuntersAgentManager private skyhuntersAgent;
    TripleAAgents private agents;
    TripleANFT private nft;
    TripleAMarket private market;
    string private metadata = "Agent Metadata";
    address private agentWallet = address(0x789);
    string private metadata2 = "Agent Metadata1";
    address private agentWallet2 = address(0x78219);
    address private admin = address(0x123);
    address private artist = address(0x456);
    address private artist2 = address(0x126);
    address private recharger = address(0x78932);
    address private recharger2 = address(0x78988);
    address private agentOwner = address(0x131);
    address private agentOwner2 = address(0x135);
    address private agentOwner3 = address(0x125);
    address private buyer = address(0x132);
    address private buyer2 = address(0x1323);
    address private fulfiller = address(0x1324);
    address private poolManager = address(0x154);

    MockERC20 private token1;
    MockERC20 private token2;

    function setUp() public {
        skyhuntersAccess = new SkyhuntersAccessControls();
        skyhuntersAgent = new SkyhuntersAgentManager(
            payable(address(skyhuntersAccess))
        );
        accessControls = new TripleAAccessControls(
            payable(address(skyhuntersAccess))
        );
        collectionManager = new TripleACollectionManager(
            payable(address(accessControls)),
            payable(address(skyhuntersAccess)),
            address(skyhuntersAgent)
        );
        nft = new TripleANFT("NFT", "NFT", payable(address(accessControls)));
        fulfillerManager = new TripleAFulfillerManager(
            payable(address(accessControls))
        );
        agents = new TripleAAgents(
            payable(address(accessControls)),
            address(collectionManager),
            payable(address(skyhuntersAccess)),
            address(skyhuntersAgent),
            payable(address(poolManager))
        );
        market = new TripleAMarket(
            address(nft),
            address(collectionManager),
            payable(address(accessControls)),
            payable(address(agents)),
            address(fulfillerManager),
            payable(address(skyhuntersAccess)),
            address(skyhuntersAgent)
        );
        token1 = new MockERC20("Token1", "TK1");
        token2 = new MockERC20("Token2", "TK2");
        skyhuntersAccess.setAcceptedToken(address(token1));
        skyhuntersAccess.setAcceptedToken(address(token2));
        skyhuntersAccess.setAgentsContract(address(skyhuntersAgent));
        accessControls.addAdmin(admin);
        accessControls.addFulfiller(fulfiller);
        accessControls.setTokenDetails(
            address(token1),
            10000000000000000000,
            15000000000000000,
            60000000000000000,
            40000000000000000,
            20000000000000000,
            6,
            20000000000000000
        );
        accessControls.setTokenDetails(
            address(token2),
            100000000000000000,
            10000000000000000,
            20000000000000000,
            10000000000000000,
            10000000000000000,
            10,
            20000000000000000
        );

        vm.startPrank(admin);

        agents.setMarket(address(market));
        agents.setAmounts(30, 30, 40);

        collectionManager.setMarket(address(market));
        collectionManager.setAgents(payable(address(agents)));
        nft.setMarket(address(market));

        fulfillerManager.setMarket(address(market));
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
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        uint256 agentId = skyhuntersAgent.getAgentCounter();
        assertEq(agentId, 1);
        assertEq(skyhuntersAgent.getAgentWallets(agentId)[0], agentWallet);
        assertEq(skyhuntersAgent.getAgentMetadata(agentId), metadata);

        vm.stopPrank();
    }

    function testEditAgent() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);

        uint256 agentId = skyhuntersAgent.getAgentCounter();
        string memory newMetadata = "Updated Metadata";

        skyhuntersAgent.editAgent(newMetadata, agentId);

        assertEq(skyhuntersAgent.getAgentMetadata(agentId), newMetadata);

        vm.stopPrank();
    }

    function testEditAgentRevertIfNotAgentOwner() public {
        vm.startPrank(admin);
        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        uint256 agentId = skyhuntersAgent.getAgentCounter();
        vm.stopPrank();

        vm.startPrank(address(0xABC));
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.NotAgentOwner.selector)
        );

        skyhuntersAgent.editAgent("New Metadata", agentId);
        vm.stopPrank();
    }

    function testDeleteAgent() public {
        vm.startPrank(agentOwner);
        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);

        uint256 agentId = skyhuntersAgent.getAgentCounter();

        skyhuntersAgent.deleteAgent(agentId);

        vm.stopPrank();
    }

    function testDeleteAgentRevertIfNotAgentOwner() public {
        vm.startPrank(admin);
        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        uint256 agentId = skyhuntersAgent.getAgentCounter();
        vm.stopPrank();

        vm.startPrank(address(0xABC));
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.NotAgentOwner.selector)
        );
        skyhuntersAgent.deleteAgent(agentId);
        vm.stopPrank();
    }

    function testAgentCounterIncrements() public {
        vm.startPrank(admin);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = admin;
        owners[1] = agentOwner2;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        uint256 firstAgentId = skyhuntersAgent.getAgentCounter();

        address[] memory newWallets = new address[](1);
        newWallets[0] = address(0xDEF);
        address[] memory newOwners = new address[](1);
        newOwners[0] = agentOwner3;
        skyhuntersAgent.createAgent(
            newWallets,
            newOwners,
            "Another Metadata",
            false,
            false
        );
        uint256 secondAgentId = skyhuntersAgent.getAgentCounter();

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
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 1,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(admin);
        token1.mint(recharger, 300 ether);
        vm.stopPrank();

        vm.startPrank(recharger);
        uint256 rechargerInitialBalance = token1.balanceOf(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));

        agents.rechargeAgentRentBalance(address(token1), 1, 1, 123400000);
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.TokenNotAccepted.selector)
        );
        agents.rechargeAgentRentBalance(address(token2), 1, 1, 100000000);

        vm.stopPrank();

        uint256 activeBalance = agents.getAgentRentBalance(
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
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 20,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 40 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });
        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(admin);
        token1.mint(recharger, 500 ether);
        token1.mint(buyer, 600 ether);
        vm.stopPrank();

        vm.startPrank(recharger);
        uint256 rechargerInitialBalance = token1.balanceOf(recharger);
        token1.approve(address(agents), 100 ether);
        token1.allowance(recharger, address(agents));
        token2.approve(address(agents), 100 ether);
        token2.allowance(recharger, address(agents));

        agents.rechargeAgentRentBalance(address(token1), 1, 1, 123400000);
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.TokenNotAccepted.selector)
        );
        agents.rechargeAgentRentBalance(address(token2), 1, 1, 100000000);

        vm.stopPrank();

        uint256 activeBalance = agents.getAgentRentBalance(
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
        token1.approve(address(market), 300 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 1, 2, 0);
        uint256 buyerExpectedBalance = buyerInitialBalance - (80 ether);
        uint256 artistExpectedBalance = artistInitialBalance + (76 ether);
        vm.stopPrank();

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist));

        vm.startPrank(buyer);
        market.buy("fulfillment details", address(token1), 1, 1, 0);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1)) +
            accessControls.getTokenCycleRentMint(address(token1));
        uint256 activeBalance_after = agents.getAgentRentBalance(
            address(token1),
            1,
            1
        );
        uint256 bonusBalance_after = agents.getAgentBonusBalance(
            address(token1),
            1,
            1
        );

        assertEq(activeBalance_after, 123400000 + rent * 2);
        assertEq(bonusBalance_after, 8 ether - rent * 2);
    }

    function testBuyRemixFromAgent() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_agent = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_agent.tokens[0] = address(token1);
        inputs_agent.prices[0] = 10 ether;
        inputs_agent.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });
        collectionManager.create(inputs_agent, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 1,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_2 = new TripleALibrary.CollectionWorker[](1);

        workers_2[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });
        collectionManager.create(inputs_1, workers_2, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(admin);
        token1.mint(buyer, 500 ether);
        vm.stopPrank();

        uint256 agentsInitialBalance = token1.balanceOf(address(agents));
        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);

        vm.startPrank(buyer);
        token1.approve(address(market), 600 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 2, 5, 0);
        vm.stopPrank();

        uint256 buyerExpectedBalance = buyerInitialBalance - 50 ether;
        uint256 artistExpectedBalance = artistInitialBalance + 35 ether;
        uint256 agentsExpectedBalance = agentsInitialBalance + 15 ether;

        assertEq(agentsExpectedBalance, token1.balanceOf(address(agents)));
        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist));
        assertEq(token1.balanceOf(agentWallet), 0);
    }

    function testBuyAgentCollection() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](0),
                metadata: "Metadata 1",
                amount: 20,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: artist2
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](0);

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();
        token1.mint(buyer, 200 ether);

        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 agentsInitialBalance = token1.balanceOf(address(agents));
        vm.startPrank(buyer);
        token1.approve(address(market), 200 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 1, 5, 1);
        vm.stopPrank();

        uint256 buyerExpectedBalance = buyerInitialBalance - 50 ether;
        uint256 agentsExpectedBalance = agentsInitialBalance + 50 ether;

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(0, token1.balanceOf(artist2));
        assertEq(agentsExpectedBalance, token1.balanceOf(address(agents)));
        assertEq(
            50 ether,
            agents.getArtistCollectBalanceByToken(
                address(artist2),
                address(token1),
                1
            )
        );
    }

    function testBuyAgentCollectionIRLAgents() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.IRL,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: artist2
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);
        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();
        token1.mint(buyer, 200 ether);
        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 agentsInitialBalance = token1.balanceOf(address(agents));

        vm.startPrank(buyer);
        token1.approve(address(market), 200 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 1, 5, 1);
        vm.stopPrank();

        uint256 buyerExpectedBalance = buyerInitialBalance - 50 ether;
        uint256 fulfillerExpectedBalance = (50 ether *
            accessControls.getTokenVig(address(token1))) /
            100 +
            accessControls.getTokenBase(address(token1));
        uint256 agentsExpectedBalance = agentsInitialBalance +
            50 ether -
            fulfillerExpectedBalance;
        uint256 price = 50 ether - fulfillerExpectedBalance;
        uint256 collectExpectedBalance = (price / 5) +
            (90 * (((price * 4) / 5))) /
            100;

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(0, token1.balanceOf(artist2));
        assertEq(agentsExpectedBalance, token1.balanceOf(address(agents)));
        assertEq(fulfillerExpectedBalance, token1.balanceOf(fulfiller));
        assertEq(
            collectExpectedBalance,
            agents.getArtistCollectBalanceByToken(
                address(artist2),
                address(token1),
                1
            )
        );
    }

    function testAgentBuysCollection() public {
        testBuyAgentCollection();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](0),
                metadata: "Metadata 1",
                amount: 20,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: artist2
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 200 ether;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](0);

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();
        token1.mint(buyer, 2000 ether);

        vm.startPrank(buyer);
        token1.approve(address(market), 2000 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 2, 5, 1);
        vm.stopPrank();

        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet2;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist2);
        TripleALibrary.CollectionInput memory inputs_buy = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_buy.tokens[0] = address(token1);
        inputs_buy.prices[0] = 14 ether;
        inputs_buy.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_buy = new TripleALibrary.CollectionWorker[](1);
        workers_buy[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });

        collectionManager.create(inputs_buy, workers_buy, "some drop uri", 0);
        vm.stopPrank();
        token1.mint(buyer, 100 ether);
        uint256 agentsInitialBalance = token1.balanceOf(address(agents));
        uint256 artistsInitialBalance = token1.balanceOf(address(artist2));

        vm.startPrank(buyer);
        token1.approve(address(market), 100 ether);
        token1.allowance(buyer, address(market));
        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.NotAgent.selector)
        );
        market.agentBuy(address(token1), 3, 2, 1);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        token1.approve(address(market), 20 ether);
        token1.allowance(agentWallet, address(market));
        market.agentBuy(address(token1), 3, 2, 1);
        vm.stopPrank();

        uint256 agentsExpectedBalance = agentsInitialBalance -
            14 ether -
            (90 * 14 ether) /
            100;
        uint256 artistExpectedBalance = artistsInitialBalance +
            14 ether +
            (90 * 14 ether) /
            100;

        assertEq(artistExpectedBalance, token1.balanceOf(artist2));
        assertEq(agentsExpectedBalance, token1.balanceOf(address(agents)));
        assertEq(0, token1.balanceOf(agentWallet));
    }

    function buyOneCollection() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);
        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        token1.mint(buyer, 200 ether);
        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);

        vm.startPrank(buyer);
        token1.approve(address(market), 200 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 1, 1, 1);
        vm.stopPrank();

        uint256 buyerExpectedBalance = buyerInitialBalance - 10 ether;
        uint256 artistExpectedBalance = artistInitialBalance + 10 ether;

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist));
    }

    function testDeleteByAgentOwner() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);
        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.NotArtist.selector)
        );
        vm.startPrank(agentOwner3);
        collectionManager.deleteCollection(1, 0);

        collectionManager.deleteCollection(1, 1);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_2 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_2.tokens[0] = address(token1);
        inputs_2.prices[0] = 10 ether;
        inputs_2.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_2 = new TripleALibrary.CollectionWorker[](1);
        workers_2[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });

        collectionManager.create(inputs_2, workers_2, "some drop uri", 0);
        vm.stopPrank();

        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.NotArtist.selector)
        );
        vm.startPrank(agentOwner3);
        collectionManager.deleteDrop(2, 0);

        collectionManager.deleteDrop(2, 1);
        vm.stopPrank();
    }

    function testCollectionWithoutAgents() public {
        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](0),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](0);

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        token1.mint(buyer, 50 ether);
        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);

        vm.startPrank(buyer);
        token1.approve(address(market), 50 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 1, 5, 0);
        vm.stopPrank();
        uint256 buyerExpectedBalance = buyerInitialBalance - 50 ether;
        uint256 artistExpectedBalance = artistInitialBalance + 50 ether;

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist));
    }

    function testPayRentWithoutBonus() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 5,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });
        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(admin);
        token1.mint(recharger, 500 ether);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1)) +
            accessControls.getTokenCycleRentMint(address(token1));

        vm.startPrank(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));
        agents.rechargeAgentRentBalance(address(token1), 1, 1, rent * 3);
        vm.stopPrank();

        address[] memory tokens = new address[](1);
        tokens[0] = address(token1);
        uint256[] memory collectionIds = new uint256[](1);
        collectionIds[0] = 1;

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        vm.stopPrank();

        uint256 allServices = agents.getAllTimeServices(address(token1));
        uint256 oneServices = agents.getServicesPaidByToken(address(token1));

        assertEq(allServices, rent);
        assertEq(oneServices, rent);

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        agents.payRent(tokens, collectionIds, 1);

        uint256 allServices_after3 = agents.getAllTimeServices(address(token1));
        uint256 oneServices_after3 = agents.getServicesPaidByToken(
            address(token1)
        );

        assertEq(allServices_after3, rent * 3);
        assertEq(oneServices_after3, rent * 3);

        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.InsufficientBalance.selector)
        );
        agents.payRent(tokens, collectionIds, 1);
    }

    function testWithRemixWithAgent() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_2 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 2",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 1,
                remixable: true,
                forArtist: address(0)
            });

        inputs_2.tokens[0] = address(token1);
        inputs_2.prices[0] = 10 ether;
        inputs_2.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_2 = new TripleALibrary.CollectionWorker[](1);

        workers_2[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_2, workers_2, "some drop uri", 0);
        vm.stopPrank();

        token1.mint(buyer, 600 ether);
        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);
        uint256 agentInitialBalance = token1.balanceOf(address(agents));

        vm.startPrank(buyer);
        token1.approve(address(market), 600 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 2, 5, 0);

        uint256 buyerExpectedBalance = buyerInitialBalance - (50 ether);
        uint256 artistExpectedBalance = artistInitialBalance + (25 ether);
        uint256 agentExpectedBalance = agentInitialBalance + (25 ether);
        vm.stopPrank();

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist));
        assertEq(agentExpectedBalance, token1.balanceOf(address(agents)));
    }

    function testRemixWithoutAgent() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(artist2);
        TripleALibrary.CollectionInput memory inputs_2 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 2",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 1,
                remixable: true,
                forArtist: address(0)
            });

        inputs_2.tokens[0] = address(token1);
        inputs_2.prices[0] = 10 ether;
        inputs_2.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_2 = new TripleALibrary.CollectionWorker[](1);

        workers_2[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_2, workers_2, "some drop uri", 0);
        vm.stopPrank();

        token1.mint(buyer, 600 ether);
        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist2);
        uint256 agentInitialBalance = token1.balanceOf(address(agents));
        uint256 remixInitialBalance = token1.balanceOf(artist);

        vm.startPrank(buyer);
        token1.approve(address(market), 600 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 2, 5, 0);

        uint256 buyerExpectedBalance = buyerInitialBalance - (50 ether);
        uint256 artistExpectedBalance = artistInitialBalance + (35 ether);
        uint256 agentExpectedBalance = agentInitialBalance + (5 ether);
        uint256 remixExpectedBalance = remixInitialBalance + (10 ether);
        vm.stopPrank();

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist2));
        assertEq(agentExpectedBalance, token1.balanceOf(address(agents)));
        assertEq(remixExpectedBalance, token1.balanceOf(address(artist)));
    }

    function testIRLWithoutAgent() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.IRL,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(artist2);
        TripleALibrary.CollectionInput memory inputs_2 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 2",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.IRL,
                fulfillerId: 1,
                remixId: 1,
                remixable: true,
                forArtist: address(0)
            });

        inputs_2.tokens[0] = address(token1);
        inputs_2.prices[0] = 10 ether;
        inputs_2.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_2 = new TripleALibrary.CollectionWorker[](1);

        workers_2[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_2, workers_2, "some drop uri", 0);
        vm.stopPrank();

        token1.mint(buyer, 600 ether);
        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist2);
        uint256 agentInitialBalance = token1.balanceOf(address(agents));
        uint256 remixInitialBalance = token1.balanceOf(artist);
        uint256 fulfillerInitialBalance = token1.balanceOf(fulfiller);

        vm.startPrank(buyer);
        token1.approve(address(market), 600 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 2, 5, 0);

        uint256 fulfillerShare = (50 ether *
            accessControls.getTokenVig(address(token1))) /
            100 +
            accessControls.getTokenBase(address(token1));
        uint256 otherShare = 50 ether - fulfillerShare;

        uint256 buyerExpectedBalance = buyerInitialBalance - (50 ether);
        uint256 artistExpectedBalance = artistInitialBalance +
            (70 * otherShare) /
            100;
        uint256 agentExpectedBalance = agentInitialBalance +
            (10 * otherShare) /
            100;
        uint256 remixExpectedBalance = remixInitialBalance +
            (20 * otherShare) /
            100;
        uint256 fulfillerExpectedBalance = fulfillerInitialBalance +
            fulfillerShare;
        vm.stopPrank();

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist2));
        assertEq(agentExpectedBalance, token1.balanceOf(address(agents)));
        assertEq(remixExpectedBalance, token1.balanceOf(address(artist)));
        assertEq(fulfillerExpectedBalance, token1.balanceOf(fulfiller));
    }

    function testIRLWithAgent() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.IRL,
                fulfillerId: 1,
                remixId: 0,
                remixable: true,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_2 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 2",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.IRL,
                fulfillerId: 1,
                remixId: 1,
                remixable: true,
                forArtist: address(0)
            });

        inputs_2.tokens[0] = address(token1);
        inputs_2.prices[0] = 10 ether;
        inputs_2.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_2 = new TripleALibrary.CollectionWorker[](1);

        workers_2[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_2, workers_2, "some drop uri", 0);
        vm.stopPrank();

        uint256 fulfillerShare = (50 ether *
            accessControls.getTokenVig(address(token1))) /
            100 +
            accessControls.getTokenBase(address(token1));
        uint256 otherShare = 50 ether - fulfillerShare;

        token1.mint(buyer, 600 ether);
        uint256 buyerInitialBalance = token1.balanceOf(buyer);
        uint256 artistInitialBalance = token1.balanceOf(artist);
        uint256 agentInitialBalance = token1.balanceOf(address(agents));
        uint256 fulfillerInitialBalance = token1.balanceOf(fulfiller);

        vm.startPrank(buyer);
        token1.approve(address(market), 600 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 2, 5, 0);

        uint256 buyerExpectedBalance = buyerInitialBalance - (50 ether);
        uint256 artistExpectedBalance = artistInitialBalance + otherShare / 2;
        uint256 agentExpectedBalance = agentInitialBalance + otherShare / 2;
        uint256 fulfillerExpectedBalance = fulfillerInitialBalance +
            fulfillerShare;
        vm.stopPrank();

        assertEq(buyerExpectedBalance, token1.balanceOf(buyer));
        assertEq(artistExpectedBalance, token1.balanceOf(artist));
        assertEq(fulfillerExpectedBalance, token1.balanceOf(fulfiller));
        assertEq(agentExpectedBalance, token1.balanceOf(address(agents)));
    }

    function cantMintRemix() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.IRL,
                fulfillerId: 1,
                remixId: 0,
                remixable: false,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 10 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        TripleALibrary.CollectionInput memory inputs_2 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 2",
                amount: 6,
                collectionType: TripleALibrary.CollectionType.IRL,
                fulfillerId: 1,
                remixId: 1,
                remixable: true,
                forArtist: address(0)
            });

        inputs_2.tokens[0] = address(token1);
        inputs_2.prices[0] = 10 ether;
        inputs_2.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_2 = new TripleALibrary.CollectionWorker[](1);

        workers_2[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "custom"
        });

        vm.expectRevert(
            abi.encodeWithSelector(TripleAErrors.CannotRemix.selector)
        );
        collectionManager.create(inputs_2, workers_2, "some drop uri", 0);
        vm.stopPrank();
    }

    function testPayRentWithBonus() public {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](2),
                prices: new uint256[](2),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 20,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: false,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.tokens[1] = address(token2);
        inputs_1.prices[0] = 20 ether;
        inputs_1.prices[1] = 5 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "aqui"
        });
        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(admin);
        token1.mint(recharger, 100 ether);
        token2.mint(recharger, 100 ether);
        vm.stopPrank();

        vm.startPrank(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));
        token2.approve(address(agents), 50 ether);
        token2.allowance(recharger, address(agents));
        agents.rechargeAgentRentBalance(address(token1), 1, 1, 10 ether);
        agents.rechargeAgentRentBalance(address(token2), 1, 1, 8 ether);
        vm.stopPrank();

        vm.startPrank(buyer);
        token1.mint(buyer, 400 ether);
        token1.approve(address(market), 400 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 1, 4, 0);
        market.buy("fulfillment details", address(token1), 1, 3, 0);
        vm.stopPrank();

        address[] memory tokens = new address[](1);
        tokens[0] = address(token1);
        uint256[] memory collectionIds = new uint256[](1);
        collectionIds[0] = 1;
        address[] memory tokens2 = new address[](1);
        tokens2[0] = address(token2);

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1)) +
            accessControls.getTokenCycleRentMint(address(token1));
        uint256 rent1 = accessControls.getTokenCycleRentLead(address(token2)) +
            accessControls.getTokenCycleRentPublish(address(token2)) +
            accessControls.getTokenCycleRentRemix(address(token2)) +
            accessControls.getTokenCycleRentMint(address(token2));

        uint256 allServices = agents.getAllTimeServices(address(token1));
        uint256 oneServices = agents.getServicesPaidByToken(address(token1));

        assertEq(allServices, rent);
        assertEq(oneServices, rent);

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        vm.stopPrank();

        vm.startPrank(recharger);
        token1.approve(address(agents), 50 ether);
        token1.allowance(recharger, address(agents));
        agents.rechargeAgentRentBalance(address(token1), 1, 1, 10 ether);
        vm.stopPrank();

        vm.startPrank(agentWallet);
        agents.payRent(tokens, collectionIds, 1);
        agents.payRent(tokens2, collectionIds, 1);
        vm.stopPrank();

        uint256 allServices_after3 = agents.getAllTimeServices(address(token1));
        uint256 oneServices_after3 = agents.getServicesPaidByToken(
            address(token1)
        );
        uint256 allServices1_after3 = agents.getAllTimeServices(
            address(token2)
        );
        uint256 oneServices1_after3 = agents.getServicesPaidByToken(
            address(token2)
        );

        assertEq(allServices_after3, rent * 3);
        assertEq(oneServices_after3, rent * 3);

        assertEq(allServices1_after3, rent1);
        assertEq(oneServices1_after3, rent1);
    }

    function _collectionOne() internal {
        vm.startPrank(agentOwner);

        address[] memory wallets = new address[](1);
        wallets[0] = agentWallet;
        address[] memory owners = new address[](2);
        owners[0] = agentOwner;
        owners[1] = agentOwner3;
        skyhuntersAgent.createAgent(wallets, owners, metadata, false, false);
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_1 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](1),
                metadata: "Metadata 1",
                amount: 20,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: false,
                forArtist: address(0)
            });

        inputs_1.tokens[0] = address(token1);
        inputs_1.prices[0] = 5 ether;
        inputs_1.agentIds[0] = 1;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](1);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });
        collectionManager.create(inputs_1, workers_1, "some drop uri", 0);
        vm.stopPrank();

        vm.startPrank(admin);
        token1.mint(recharger, 300 ether);
        token1.mint(buyer, 300 ether);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1)) +
            accessControls.getTokenCycleRentMint(address(token1));

        vm.startPrank(recharger);
        token1.approve(address(agents), 300 ether);
        token1.allowance(recharger, address(agents));
        agents.rechargeAgentRentBalance(address(token1), 1, 1, rent * 4);
        vm.stopPrank();
        vm.startPrank(buyer);
        token1.approve(address(market), 300 ether);
        token1.allowance(buyer, address(market));
        market.buy("fulfillment details", address(token1), 1, 10, 0);
        market.buy("fulfillment details", address(token1), 1, 1, 0);
        vm.stopPrank();
    }

    function _collectionTwo() internal {
        vm.startPrank(agentOwner2);

        address[] memory wallets_2 = new address[](1);
        wallets_2[0] = agentWallet2;
        address[] memory owners_2 = new address[](2);
        owners_2[0] = agentOwner2;
        owners_2[1] = agentOwner3;
        skyhuntersAgent.createAgent(
            wallets_2,
            owners_2,
            metadata2,
            false,
            false
        );
        vm.stopPrank();

        vm.startPrank(artist);
        TripleALibrary.CollectionInput memory inputs_2 = TripleALibrary
            .CollectionInput({
                tokens: new address[](1),
                prices: new uint256[](1),
                agentIds: new uint256[](2),
                metadata: "Metadata 2",
                amount: 40,
                collectionType: TripleALibrary.CollectionType.Digital,
                fulfillerId: 1,
                remixId: 0,
                remixable: false,
                forArtist: address(0)
            });

        inputs_2.tokens[0] = address(token1);
        inputs_2.prices[0] = 5 ether;
        inputs_2.agentIds[0] = 1;
        inputs_2.agentIds[1] = 2;

        TripleALibrary.CollectionWorker[]
            memory workers_1 = new TripleALibrary.CollectionWorker[](2);

        workers_1[0] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });
        workers_1[1] = TripleALibrary.CollectionWorker({
            publish: true,
            remix: true,
            lead: true,
            publishFrequency: 1,
            remixFrequency: 1,
            leadFrequency: 1,
            mintFrequency: 1,
            mint: true,
            instructions: "algo"
        });
        collectionManager.create(inputs_2, workers_1, "some drop uri2", 0);
        vm.stopPrank();

        vm.startPrank(admin);
        token1.mint(recharger2, 500 ether);
        token1.mint(buyer2, 500 ether);
        vm.stopPrank();

        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1)) +
            accessControls.getTokenCycleRentMint(address(token1));

        vm.startPrank(recharger2);
        token1.approve(address(agents), 500 ether);
        token1.allowance(recharger2, address(agents));
        agents.rechargeAgentRentBalance(address(token1), 1, 2, rent);
        agents.rechargeAgentRentBalance(address(token1), 2, 2, rent);
        vm.stopPrank();

        vm.startPrank(buyer2);
        token1.approve(address(market), 500 ether);
        token1.allowance(buyer2, address(market));
        market.buy("fulfillment details", address(token1), 2, 20, 0);
        market.buy("fulfillment details", address(token1), 2, 1, 0);
        vm.stopPrank();
    }

    function testPayRentWithMultipleCollections()
        public
        returns (uint256, uint256)
    {
        accessControls.setTokenDetails(
            address(token1),
            3000000000000000000,
            15000000000000000,
            60000000000000000,
            40000000000000000,
            20000000000000000,
            6,
            2000000000000000000
        );
        accessControls.setTokenDetails(
            address(token2),
            100000000000000000,
            10000000000000000,
            50000000000000000,
            30000000000000000,
            20000000000000000,
            10,
            200000000000000000
        );

        _collectionOne();
        _collectionTwo();

        uint256 buyerBalance1 = token1.balanceOf(address(buyer));
        uint256 buyerBalance2 = token1.balanceOf(address(buyer2));

        // pay rent
        address[] memory tokens = new address[](2);
        tokens[0] = address(token1);
        tokens[1] = address(token1);
        uint256[] memory collectionIds = new uint256[](2);
        collectionIds[0] = 1;
        collectionIds[1] = 2;

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
            accessControls.getTokenCycleRentRemix(address(token1)) +
            accessControls.getTokenCycleRentMint(address(token1));

        uint256 allServices = agents.getAllTimeServices(address(token1));
        uint256 oneServices = agents.getServicesPaidByToken(address(token1));

        assertEq(allServices, rent * 3);
        assertEq(oneServices, rent * 3);

        return (buyerBalance1, buyerBalance2);
    }

    function testCollectorsAndOwnerBonusPaid() public {
        uint256 agentBalance = token1.balanceOf(address(agents));
        (
            uint256 buyerBalance1,
            uint256 buyerBalance2
        ) = testPayRentWithMultipleCollections();

        _bonusesCalc(agentBalance, buyerBalance1, buyerBalance2);
    }

    function _bonusesCalc(
        uint256 _agentBalance,
        uint256 _buyerBalance1,
        uint256 _buyerBalance2
    ) internal view {
        uint256 rent = accessControls.getTokenCycleRentLead(address(token1)) +
            accessControls.getTokenCycleRentPublish(address(token1)) +
            accessControls.getTokenCycleRentRemix(address(token1)) +
            accessControls.getTokenCycleRentMint(address(token1));

        uint256 bonusAmount = (((5 ether * 32) - 10 ether) * 10) / 100;

        assertEq(
            token1.balanceOf(address(agents)),
            _agentBalance + rent * 6 + (40 * (bonusAmount - rent * 6)) / 100
        );

        // 2 agents for col 2 x 2
        // 1 agent for col 1 x 1
        // 6 rent payments
        assertEq(
            agents.getDevPaymentByToken(address(token1)),
            (40 * (bonusAmount - rent * 6)) / 100
        );

        // collectors
        assertEq(
            token1.balanceOf(buyer2),
            _buyerBalance2 + (((30 * (bonusAmount - rent * 6)) / 100) * 2) / 3
        );

        assertEq(
            token1.balanceOf(buyer),
            _buyerBalance1 + (((30 * (bonusAmount - rent * 6)) / 100) * 1) / 3
        );

        uint256 ownerTotal = ((30 * (bonusAmount - rent * 6)) / 100);

        // owners
        assertEq(token1.balanceOf(agentOwner), (ownerTotal / 6) * 2);
        assertEq(token1.balanceOf(agentOwner2), ownerTotal / 6);
        assertEq(token1.balanceOf(agentOwner3), (ownerTotal / 6) * 3);
    }

    function testWithdrawServices() public {
        testPayRentWithMultipleCollections();

        uint256 historical = agents.getAllTimeServices(address(token1));
        vm.startPrank(admin);
        agents.withdrawServices(address(token1));
        vm.stopPrank();

        assertEq(agents.getAllTimeServices(address(token1)), historical);
        assertEq(agents.getServicesPaidByToken(address(token1)), 0);
    }
}
