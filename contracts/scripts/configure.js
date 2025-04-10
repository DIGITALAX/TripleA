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
  "https://rpc.lens.xyz",
  232
);
const wallet = new ethers.Wallet("", provider);
const collectionManagerAddress = "0xBa53Fd19053fceFc91D091A02c71AbDcD79d856f";
const marketAddress = "0x6c7a9d566F6c2a9829B940b7571A220c70817c1a";
const agentsAddress = "0x424Fa11D84e5674809Fd0112eBa4f86d6C4ed2aD";
const fulfillerAddress = "0x2eB287C1B3EAd0479127413d317670D11A2BC527";
const accessControlsAddress = "0x4F276081A4AC2d50eEE2aA6c78a3C4C06AAE9562";
const nftAddress = "0xeBd613aD9324D912Fcb3778baFc666c296deDd27";
const skyhuntersAcAddress = "0x79FbB9169678138A019deD3dc01Cf047f639Cc91";
const skyhuntersAgentAddress = "0xDb073899eef2Dcf496Ee987F5238c5E9FE5d5933";
const feedAddress = "0x27dfD1dc2867850E6c0930c1B5066854de0182e4";



const WGHO = "0x6bDc36E20D267Ff0dd6097799f82e78907105e2F";
// const MONA = "0x72ab7C7f3F6FF123D08692b0be196149d4951a41";
const WETH = "0xE5ecd226b3032910CEaa43ba92EE8232f8237553";
const BONSAI = "0xB0588f9A9cADe7CD5f194a5fe77AcD6A58250f82";
const FULFILLER = "0xfa3fea500eeDAa120f7EeC2E4309Fe094F854E61";

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

  // const feedContract = new ethers.Contract(feedAddress, feedAbi, wallet);

  // Configura contratos
  // const ethToken = await skyhuntersAcContract.setAcceptedToken(WETH);
  // await ethToken.wait();
  // const eth = await acContract.setTokenDetails(
  //   WETH,
  //   "31677246870000000",
  //   "316772469000000",
  //   "3801269624000000",
  //   "2534179749000000",
  //   "1900634812000000",
  //   10,
  //   "17739258250000000"
  // );
  // await eth.wait();

  // const ghoToken = await skyhuntersAcContract.setAcceptedToken(WGHO);
  // await ghoToken.wait();
  // const gho = await acContract.setTokenDetails(
  //   WGHO,
  //   "50000000000000000000",
  //   "500000000000000000",
  //   "6000000000000000000",
  //   "4000000000000000000",
  //   "3000000000000000000",
  //   9,
  //   "28000000000000000000"
  // );
  // await gho.wait();

  // const bonsaiToken = await skyhuntersAcContract.setAcceptedToken(BONSAI);
  // await bonsaiToken.wait();
  // const bonsai = await acContract.setTokenDetails(
  //   BONSAI,
  //   "15639850000000000000000",
  //   "156396621800000000000",
  //   "1876759462000000000000",
  //   "1251172975000000000000",
  //   "938379731000000000000",
  //   9,
  //   "8758210823000000000000"
  // );
  // await bonsai.wait();

  // await agentsContract.setAccessControls(accessControlsAddress);
  // await cmContract.setAccessControls(accessControlsAddress);
  // await fmContract.setAccessControls(accessControlsAddress);
  // await marketContract.setAccessControls(accessControlsAddress);
  // await nftContract.setAccessControls(accessControlsAddress);

  // const tx0 = await agentsContract.setAgentManager(skyhuntersAgentAddress);
  // await tx0.wait();

  // const tx1 = await agentsContract.setMarket(marketAddress);
  // await tx1.wait();

  // const tx2 = await cmContract.setMarket(marketAddress);
  // await tx2.wait();
  // const tx3 = await cmContract.setAgents(agentsAddress);
  // await tx3.wait();

  // const tx14 = await marketContract.setFulfillerManager(fulfillerAddress);
  // await tx14.wait();
  // const tx4 = await fmContract.setMarket(marketAddress);
  // await tx4.wait();
  // const tx5 = await acContract.addFulfiller(FULFILLER);
  // await tx5.wait();
  // const tx6 = await fmContract.createFulfillerProfile({
  //   metadata: "ipfs://QmNSKfpUbPJe3cu5aDsmdG4S8xGJaiMCvNbrGnd1avqKRm",
  //   wallet: FULFILLER,
  // });
  // await tx6.wait();

  // const tx7 = await nftContract.setMarket(marketAddress);
  // await tx7.wait();

  // const tx8 = await skyhuntersAcContract.setAgentsContract(
  //   skyhuntersAgentAddress
  // );
  // await tx8.wait();

  // const tx9 = await agentsContract.setSkyhuntersPoolManager(poolManagerAddress);
  // await tx9.wait();

  const tx10 = await marketContract.setAgents(agentsAddress);
  await tx10.wait();

  const tx11 = await agentsContract.setAmounts(30, 30, 40);
  await tx11.wait();
  await agentsContract.setCollectionManager(collectionManagerAddress);
  await marketContract.setCollectionManager(collectionManagerAddress);


  // await skyhuntersAgentContract.createAgent(
  //   ["0x07ee9af365a7013ee7dc2f556f5d64cb1a51bd08"],
  //   ["0x26e3f8d2065a9bfdddffba7fddea0d7eb0ecff6f"],
  //   "ipfs://QmVZhDFGHFQWnx1P7uonTvGwDmX6fVUZF5mww6VMJrRXpx"
  // );


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


  // const res = await skyhuntersAgentContract.getAgentStudio(1);
  // const res1 = await skyhuntersAcContract.isAdmin(wallet.address);
  // console.log({res1})
})();
