const { ethers, keccak256, toUtf8Bytes } = require("ethers");
require("dotenv").config();

const provider = new ethers.JsonRpcProvider(
  "https://rpc.testnet.lens.dev",
  37111
);
const wallet = new ethers.Wallet(
  "",
  provider
);
const collectionManagerAddress = "0x575da586767F54DC9ba7E08024844ce72480e234";
const marketAddress = "0x704D2A8e6385CbD203990E0C92397908d96Fc6dA";
const agentsAddress = "0xF880C84F7EF0E49039B87Dbd534aD88545FC2D29";
const fulfillerAddress = "0x1b372DB79C03B8EA13F4d9115F7ee6207Bb22443";
const accessControlsAddress = "0x1b37B6FD3457b7FbB09308752e3ECCA4a7734839";
const nftAddress = "0xA4Df48010Ff3A862152A50d481B9D5D085cfA63d";
const skyhuntersAcAddress = "0x127AD7cb800B24Cb4Ac961dd9A7B49E23546F2e4";
const skyhuntersAgentAddress = "0x48d2347BBF723D4AeB9Cc2a7d4D25a958586e4Ce";

const WGRASS = "0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8";
const MONA = "0x72ab7C7f3F6FF123D08692b0be196149d4951a41";
const BONSAI = "0x15B58c74A0Ef6D0A593340721055223f38F5721E";
const FULFILLER = "0x3D1f8A6D6584a1672d2817368783B9a2a36ae361";

(async () => {
  const cmContract = new ethers.Contract(
    collectionManagerAddress,
    [
      {
        type: "function",
        name: "getCollectionERC20Tokens",
        inputs: [
          { name: "collectionId", type: "uint256", internalType: "uint256" },
        ],
        outputs: [{ name: "", type: "address[]", internalType: "address[]" }],
        stateMutability: "view",
      },
      {
        type: "function",
        name: "setMarket",
        inputs: [
          {
            name: "setMarket",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
      {
        type: "function",
        name: "setAgents",
        inputs: [{ name: "token", type: "address", internalType: "address" }],
        outputs: [],
        stateMutability: "nonpayable",
      },
    ],
    wallet
  );

  // const res1 = await cmContract.getCollectionERC20Tokens(1);
  // const res2 = await cmContract.getCollectionERC20Tokens(2);

  const marketContract = new ethers.Contract(
    marketAddress,
    [
      {
        type: "function",
        name: "setCollectionManager",
        inputs: [
          {
            name: "_collectionManager",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
    ],
    wallet
  );

  const agentsContract = new ethers.Contract(
    agentsAddress,
    [
      {
        type: "function",
        name: "setCollectionManager",
        inputs: [
          {
            name: "_collectionManager",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
      {
        type: "function",
        name: "setMarket",
        inputs: [
          {
            name: "setMarket",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
    ],
    wallet
  );

  const skyhuntersAcContract = new ethers.Contract(
    skyhuntersAcAddress,
    [
      {
        type: "function",
        name: "setAcceptedToken",
        inputs: [{ name: "token", type: "address", internalType: "address" }],
        outputs: [],
        stateMutability: "nonpayable",
      },
      {
        type: "function",
        name: "setAgentsContract",
        inputs: [{ name: "token", type: "address", internalType: "address" }],
        outputs: [],
        stateMutability: "nonpayable",
      },
    ],
    wallet
  );

  const skyhuntersAgentContract = new ethers.Contract(
    skyhuntersAgentAddress,
    [
      {
        type: "function",
        name: "createAgent",
        inputs: [
          { name: "wallets", type: "address[]", internalType: "address[]" },
          { name: "owners", type: "address[]", internalType: "address[]" },
          { name: "metadata", type: "string", internalType: "string" },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
    ],
    wallet
  );

  const fmContract = new ethers.Contract(
    fulfillerAddress,
    [
      {
        type: "function",
        name: "setMarket",
        inputs: [
          {
            name: "setMarket",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
      {
        type: "function",
        name: "createFulfillerProfile",
        inputs: [
          {
            name: "input",
            type: "tuple",
            internalType: "struct TripleALibrary.FulfillerInput",
            components: [
              { name: "metadata", type: "string", internalType: "string" },
              { name: "wallet", type: "address", internalType: "address" },
            ],
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
    ],
    wallet
  );

  const acContract = new ethers.Contract(
    accessControlsAddress,
    [
      {
        type: "function",
        name: "addFulfiller",
        inputs: [
          { name: "fulfiller", type: "address", internalType: "address" },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
      {
        type: "function",
        name: "isFulfiller",
        inputs: [
          { name: "_address", type: "address", internalType: "address" },
        ],
        outputs: [{ name: "", type: "bool", internalType: "bool" }],
        stateMutability: "view",
      },
      {
        type: "function",
        name: "setTokenDetails",
        inputs: [
          { name: "token", type: "address", internalType: "address" },
          { name: "threshold", type: "uint256", internalType: "uint256" },
          { name: "rentLead", type: "uint256", internalType: "uint256" },
          { name: "rentRemix", type: "uint256", internalType: "uint256" },
          { name: "rentPublish", type: "uint256", internalType: "uint256" },
          { name: "vig", type: "uint256", internalType: "uint256" },
          { name: "base", type: "uint256", internalType: "uint256" },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
    ],
    wallet
  );

  const nftContract = new ethers.Contract(
    nftAddress,
    [
      {
        type: "function",
        name: "accessControls",
        inputs: [],
        outputs: [
          {
            name: "",
            type: "address",
            internalType: "contract TripleAAccessControls",
          },
        ],
        stateMutability: "view",
      },
      {
        type: "function",
        name: "setMarket",
        inputs: [
          {
            name: "setMarket",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
    ],
    wallet
  );

  // Configura contratos
  const grassToken = await skyhuntersAcContract.setAcceptedToken(WGRASS);
  await grassToken.wait();
  const grass = await acContract.setTokenDetails(
    WGRASS,
    "100000000000000000",
    "10000000000000000",
    "50000000000000000",
    "30000000000000000",
    10,
    "2000000000000000000"
  );
  await grass.wait();

  const monaToken = await skyhuntersAcContract.setAcceptedToken(MONA);
  await monaToken.wait();
  const mona = await acContract.setTokenDetails(
    MONA,
    "10000000000000000000",
    "1500000000000000000",
    "6000000000000000000",
    "4000000000000000000",
    6,
    "20000000000000000000"
  );
  await mona.wait();

  const bonsaiToken = await skyhuntersAcContract.setAcceptedToken(BONSAI);
  await bonsaiToken.wait();
  const bonsai = await acContract.setTokenDetails(
    BONSAI,
    "100000000000000000000",
    "12000000000000000000",
    "14500000000000000000",
    "13000000000000000000",
    5,
    "50000000000000000000"
  );
  await bonsai.wait();

  const tx1 = await agentsContract.setMarket(marketAddress);
  await tx1.wait();

  const tx2 = await cmContract.setMarket(marketAddress);
  await tx2.wait();
  const tx3 = await cmContract.setAgents(agentsAddress);
  await tx3.wait();

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

  const tx8 = await skyhuntersAcContract.setAgentsContract(agentsAddress);
  await tx8.wait();

  // await skyhuntersAgentContract.createAgent(
  //   ["0x07ee9af365a7013ee7dc2f556f5d64cb1a51bd08"],
  //   ["0x26e3f8d2065a9bfdddffba7fddea0d7eb0ecff6f"],
  //   "ipfs://QmVZhDFGHFQWnx1P7uonTvGwDmX6fVUZF5mww6VMJrRXpx"
  // );

  // await agentsContract.setCollectionManager(
  //   "0x575da586767F54DC9ba7E08024844ce72480e234"
  // );
  // await marketContract.setCollectionManager(
  //   "0x575da586767F54DC9ba7E08024844ce72480e234"
  // );
})();
