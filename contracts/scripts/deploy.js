const { Provider, Wallet, ContractFactory } = require("zksync-ethers");
require("dotenv").config();
const fs = require("fs");

const provider = new Provider("https://rpc.testnet.lens.dev", 37111);
const wallet = new Wallet(
  "",
  provider
);

(async () => {
  const skyhuntersAcJson = JSON.parse(
    fs.readFileSync(
      "./../../contracts/zkout/SkyhuntersAccessControls.sol/SkyhuntersAccessControls.json",
      "utf8"
    )
  );
  const skyhuntersAcContractFactory = new ContractFactory(
    skyhuntersAcJson.abi,
    skyhuntersAcJson.bytecode.object,
    wallet
  );
  const skyhuntersAcContract = await skyhuntersAcContractFactory.deploy();
  console.log(
    "Skyhunters AC Contract deployed at:",
    skyhuntersAcContract.target
  );

  const skyhuntersAgentsJson = JSON.parse(
    fs.readFileSync(
      "./../../contracts/zkout/SkyhuntersAgentManager.sol/SkyhuntersAgentManager.json",
      "utf8"
    )
  );
  const skyhuntersAgentsContractFactory = new ContractFactory(
    skyhuntersAgentsJson.abi,
    skyhuntersAgentsJson.bytecode.object,
    wallet
  );
  const skyhuntersAgentsContract = await skyhuntersAgentsContractFactory.deploy(
    skyhuntersAcContract.target
  );
  console.log(
    "Skyhunters Agents Contract deployed at:",
    skyhuntersAgentsContract.target
  );
  const tripleAACJson = JSON.parse(
    fs.readFileSync(
      "./../../contracts/zkout/TripleAAccessControls.sol/TripleAAccessControls.json",
      "utf8"
    )
  );

  const tripleAACContractFactory = new ContractFactory(
    tripleAACJson.abi,
    tripleAACJson.bytecode.object,
    wallet
  );

  const tripleAACContract = await tripleAACContractFactory.deploy(
    skyhuntersAcContract.target
  );
  console.log(
    "Access Controls Contract deployed at:",
    tripleAACContract.target
  );

  const tripleAFulfillerJson = JSON.parse(
    fs.readFileSync(
      "./../../contracts/zkout/TripleAFulfillerManager.sol/TripleAFulfillerManager.json",
      "utf8"
    )
  );
  const tripleAFulfillerContractFactory = new ContractFactory(
    tripleAFulfillerJson.abi,
    tripleAFulfillerJson.bytecode.object,
    wallet
  );
  const tripleAFulfillerContract = await tripleAFulfillerContractFactory.deploy(
    tripleAACContract.target
  );
  console.log(
    "Fulfiller Contract deployed at:",
    tripleAFulfillerContract.target
  );

  const tripleANFTJson = JSON.parse(
    fs.readFileSync(
      "./../../contracts/zkout/TripleANFT.sol/TripleANFT.json",
      "utf8"
    )
  );
  const tripleANFTContractFactory = new ContractFactory(
    tripleANFTJson.abi,
    tripleANFTJson.bytecode.object,
    wallet
  );
  const tripleANFTContract = await tripleANFTContractFactory.deploy(
    "TripleA NFT",
    "AAA",
    tripleAACContract.target
  );
  console.log("NFT Contract deployed at:", tripleANFTContract.target);

  const tripleACollectionJson = JSON.parse(
    fs.readFileSync(
      "./../../contracts/zkout/TripleACollectionManager.sol/TripleACollectionManager.json",
      "utf8"
    )
  );
  const tripleACollectionContractFactory = new ContractFactory(
    tripleACollectionJson.abi,
    tripleACollectionJson.bytecode.object,
    wallet
  );
  const tripleACollectionContract =
    await tripleACollectionContractFactory.deploy(
      tripleAACContract.target,
      skyhuntersAcContract.target,
      skyhuntersAgentsContract.target
    );
  console.log(
    "Collection Contract deployed at:",
    tripleACollectionContract.target
  );

  const tripleAAgentsJson = JSON.parse(
    fs.readFileSync(
      "./../../contracts/zkout/TripleAAgents.sol/TripleAAgents.json",
      "utf8"
    )
  );
  const tripleAAgentsContractFactory = new ContractFactory(
    tripleAAgentsJson.abi,
    tripleAAgentsJson.bytecode.object,
    wallet
  );
  const tripleAAgentsContract = await tripleAAgentsContractFactory.deploy(
    tripleAACContract.target,
    tripleACollectionContract.target,
    skyhuntersAcContract.target,
    skyhuntersAgentsContract.target
  );
  console.log("Agents Contract deployed at:", tripleAAgentsContract.target);

  const tripleAMarketJson = JSON.parse(
    fs.readFileSync(
      "./../../contracts/zkout/TripleAMarket.sol/TripleAMarket.json",
      "utf8"
    )
  );
  const tripleAMarketContractFactory = new ContractFactory(
    tripleAMarketJson.abi,
    tripleAMarketJson.bytecode.object,
    wallet
  );
  const tripleAMarketContract = await tripleAMarketContractFactory.deploy(
    tripleANFTContract.target,
    tripleACollectionContract.target,
    tripleAACContract.target,
    tripleAAgentsContract.target,
    tripleAFulfillerContract.target,
    skyhuntersAcContract.target,
    skyhuntersAgentsContract.target
  );
  console.log("Market Contract deployed at:", tripleAMarketContract.target);
})();
