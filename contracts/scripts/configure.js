const { ethers, keccak256, toUtf8Bytes } = require("ethers");
require("dotenv").config();
const accessAbi = require("../../server/abis/TripleAAccessControls.json");
const agentsAbi = require("../../server/abis/TripleAAgents.json");
const collectionAbi = require("../../server/abis/TripleACollectionManager.json");
const marketAbi = require("../../server/abis/TripleAMarket.json");
const fulfillerAbi = require("../../server/abis/TripleAFulfillerManager.json");
const nftAbi = require("../../server/abis/TripleANFT.json");
const skyhuntersAcAbi = require("../../server/abis/SkyhuntersAccessControls.json");
const skyhuntersAgentsAbi = require("../../server/abis/SkyhuntersAgentManager.json");
const feedAbi = require("../../server/abis/AgentFeedRule.json");

const provider = new ethers.JsonRpcProvider(
  "https://rpc.testnet.lens.dev",
  37111
);
const wallet = new ethers.Wallet("", provider);
const collectionManagerAddress = "0xAFA95137afe705526bc3afb17D1AAdf554d07160";
const marketAddress = "0x9F101Db166174A33ADd019cFf54Daa7965b14251";
const agentsAddress = "0xeD6a08221D7A3E69635dC2C4FaE9205bC45E18Ed";
const fulfillerAddress = "0xf6Ba2713Bc8043655aEfe599E71EA5cEe27b3f3B";
const accessControlsAddress = "0x4695Df1FDC39Ad972915545EA2E2403d4860592B";
const nftAddress = "0x3daCf95490d2a130bA9EAbd4967a0B1c1bE1D112";
const skyhuntersAcAddress = "0x2974ef777e002f33f9783b28209CB81d91E6eEFC";
const skyhuntersAgentAddress = "0xA3292bB2e4713662fF034A75adC7219c75876b9a";
const poolManagerAddress = "0x3D1f8A6D6584a1672d2817368783B9a2a36ae361";
const feedAddress = "0x27dfD1dc2867850E6c0930c1B5066854de0182e4";

const WGRASS = "0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8";
const MONA = "0x72ab7C7f3F6FF123D08692b0be196149d4951a41";
const BONSAI = "0x15B58c74A0Ef6D0A593340721055223f38F5721E";
const FULFILLER = "0x3D1f8A6D6584a1672d2817368783B9a2a36ae361";

(async () => {
  const cmContract = new ethers.Contract(
    collectionManagerAddress,
    collectionAbi,
    wallet
  );

  const marketContract = new ethers.Contract(marketAddress, marketAbi, wallet);

  const agentsContract = new ethers.Contract(agentsAddress, agentsAbi, wallet);

  const skyhuntersAcContract = new ethers.Contract(
    skyhuntersAcAddress,
    skyhuntersAcAbi,
    wallet
  );

  const skyhuntersAgentContract = new ethers.Contract(
    skyhuntersAgentAddress,
    skyhuntersAgentsAbi,
    wallet
  );

  const fmContract = new ethers.Contract(
    fulfillerAddress,
    fulfillerAbi,
    wallet
  );

  const acContract = new ethers.Contract(
    accessControlsAddress,
    accessAbi,
    wallet
  );

  const nftContract = new ethers.Contract(nftAddress, nftAbi, wallet);

  const feedContract = new ethers.Contract(feedAddress, feedAbi, wallet);

  // Configura contratos
  // const grassToken = await skyhuntersAcContract.setAcceptedToken(WGRASS);
  // await grassToken.wait();
  // const grass = await acContract.setTokenDetails(
  //   WGRASS,
  //   "100000000000000000",
  //   "10000000000000000",
  //   "50000000000000000",
  //   "30000000000000000",
  //   "70000000000000000",
  //   10,
  //   "2000000000000000000"
  // );
  // await grass.wait();

  // const monaToken = await skyhuntersAcContract.setAcceptedToken(MONA);
  // await monaToken.wait();
  // const mona = await acContract.setTokenDetails(
  //   MONA,
  //   "10000000000000000000",
  //   "1500000000000000000",
  //   "6000000000000000000",
  //   "4000000000000000000",
  //   "10000000000000000",
  //   6,
  //   "20000000000000000000"
  // );
  // await mona.wait();

  // const bonsaiToken = await skyhuntersAcContract.setAcceptedToken(BONSAI);
  // await bonsaiToken.wait();
  const bonsai = await acContract.setTokenDetails(
    BONSAI,
    "100000000000000000000",
    "12000000000000000000",
    "14500000000000000000",
    "13000000000000000000",
    "8000000000000000000",
    5,
    "50000000000000000000"
  );
  await bonsai.wait();

  await agentsContract.setAccessControls(accessControlsAddress);
  await cmContract.setAccessControls(accessControlsAddress);
  await fmContract.setAccessControls(accessControlsAddress);
  await marketContract.setAccessControls(accessControlsAddress);
  await nftContract.setAccessControls(accessControlsAddress);

  const tx0 = await agentsContract.setAgentManager(skyhuntersAgentAddress);
  await tx0.wait();

  const tx1 = await agentsContract.setMarket(marketAddress);
  await tx1.wait();

  const tx2 = await cmContract.setMarket(marketAddress);
  await tx2.wait();
  const tx3 = await cmContract.setAgents(agentsAddress);
  await tx3.wait();

  // const tx4 = await marketContract.setFulfillerManager(fulfillerAddress);
  // await tx4.wait();
  const tx4 = await fmContract.setMarket(marketAddress);
  await tx4.wait();
  const tx5 = await acContract.addFulfiller(FULFILLER);
  await tx5.wait();
  const tx6 = await fmContract.createFulfillerProfile({
    metadata: "ipfs://QmNSKfpUbPJe3cu5aDsmdG4S8xGJaiMCvNbrGnd1avqKRm",
    wallet: FULFILLER,
  });
  await tx6.wait();

  const tx7 = await nftContract.setMarket(marketAddress);
  await tx7.wait();

  const tx8 = await skyhuntersAcContract.setAgentsContract(
    skyhuntersAgentAddress
  );
  await tx8.wait();

  const tx9 = await agentsContract.setSkyhuntersPoolManager(poolManagerAddress);
  await tx9.wait();

  const tx10 = await marketContract.setAgents(agentsAddress);
  await tx10.wait();

  const tx11 = await agentsContract.setAmounts(30, 30, 40);
  await tx11.wait();

  // await skyhuntersAgentContract.createAgent(
  //   ["0x07ee9af365a7013ee7dc2f556f5d64cb1a51bd08"],
  //   ["0x26e3f8d2065a9bfdddffba7fddea0d7eb0ecff6f"],
  //   "ipfs://QmVZhDFGHFQWnx1P7uonTvGwDmX6fVUZF5mww6VMJrRXpx"
  // );

  // await agentsContract.setCollectionManager(collectionManagerAddress);
  // await marketContract.setCollectionManager(collectionManagerAddress);

  // const encodedData = ethers.AbiCoder.defaultAbiCoder().encode(
  //   ["address"],
  //   [skyhuntersAcAddress]
  // );

  // await feedContract.configure(encodedData);

  // const res1 = await cmContract.getCollectionIsActive(2);
  // const res2 = await skyhuntersAgentContract.getAgentOwners(1);
  // const res3 = await marketContract.getAllCollectorsByCollectionId(2);
  // const res4  = await agentsContract.getAgentRentBalance(MONA,1,2);
  // const res5 = await acContract.getTokenCycleRentRemix(MONA);
  // const res6 = await acContract.getTokenCycleRentLead(MONA);
  // const res7 = await acContract.getTokenCycleRentPublish(MONA);
  // const res8 = await agentsContract.getAgentActiveCollectionIds(1);
  // // const res9 = await skyhuntersAcContract.isAgent("0x5d5A2a9acd3bD842964D329f3c771CC43eE6B96D")
  // const res10 = await cmContract.getCollectionAmount(4);
  // const res11 = await cmContract.getCollectionAmountSold(4)
  // console.log({res10, res11})
  // console.log({ res1, res2, res3 , res4, res5: res5 + res6 + res7, res8, res9});

  // const res = await acContract.getTokenThreshold(MONA);
  // const res1 = await acContract.getTokenThreshold(BONSAI);

  // const res2 = await acContract.getTokenCycleRentPublish(MONA);
  // const res3 = await acContract.getTokenCycleRentLead(MONA);
  // const res4 = await acContract.getTokenCycleRentRemix(MONA);

  // const res5 = await acContract.getTokenCycleRentPublish(BONSAI);
  // const res6 = await acContract.getTokenCycleRentLead(BONSAI);
  // const res7 = await acContract.getTokenCycleRentRemix(BONSAI);

  // console.log({res, res1, res2, res3, res4, res5, res6, res7})
})();
