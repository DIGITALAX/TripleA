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
const collectionManagerAddress = "0x4ed83239189a803885cc888A6e470d1a13F7Ff4b";
const marketAddress = "0x58c292A06Abe5A7996C32921e3DB48f7909D5D1B";
const agentsAddress = "0x155198Ea8c654D611eCf611fF817076838184506";
const fulfillerAddress = "0x49a81387572072FC2af31E7D659034D22e34b7b3";
const accessControlsAddress = "0x0064d596558Ca3Dae49B7919AEe821330203C2A6";
const nftAddress = "0x0aF54336b55E0F422a2E9f2a9614035AbF907791";
const skyhuntersAcAddress = "0xBdFF7eDe4d58c95EeaAd5f5a2F4127bc5de621A1";
const skyhuntersAgentAddress = "0xd23fd2228D0D0dD442422c1704e4DB8abb5884d9";
const poolManagerAddress = "0x3D1f8A6D6584a1672d2817368783B9a2a36ae361";

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
        name: "setAccessControls",
        inputs: [
          {
            name: "setAccessControls",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
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

  const marketContract = new ethers.Contract(
    marketAddress,
    [
      {
        type: "function",
        name: "setAccessControls",
        inputs: [
          {
            name: "setAccessControls",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
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
        name: "setAgents",
        inputs: [{ name: "token", type: "address", internalType: "address" }],
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
        name: "setAccessControls",
        inputs: [
          {
            name: "setAccessControls",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
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
      {
        type: "function",
        name: "setSkyhuntersPoolManager",
        inputs: [
          {
            name: "setSkyhuntersPoolManager",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
      {
        type: "function",
        name: "setAmounts",
        inputs: [
          {
            name: "_ownerAmountPercent",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "_distributionAmountPercent",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "_devAmountPercent",
            type: "uint256",
            internalType: "uint256",
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
        name: "setAccessControls",
        inputs: [
          {
            name: "setAccessControls",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
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
        name: "setAccessControls",
        inputs: [
          {
            name: "setAccessControls",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
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
        name: "setAccessControls",
        inputs: [
          {
            name: "setAccessControls",
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
        name: "setAccessControls",
        inputs: [
          {
            name: "setAccessControls",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
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
        name: "setAccessControls",
        inputs: [
          {
            name: "setAccessControls",
            type: "address",
            internalType: "address",
          },
        ],
        outputs: [],
        stateMutability: "nonpayable",
      },
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

  await agentsContract.setAccessControls(accessControlsAddress);
  await cmContract.setAccessControls(accessControlsAddress);
  await fmContract.setAccessControls(accessControlsAddress);
  await marketContract.setAccessControls(accessControlsAddress);
  await nftContract.setAccessControls(accessControlsAddress);

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

  const tx8 = await skyhuntersAcContract.setAgentsContract(skyhuntersAgentAddress);
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

  await agentsContract.setCollectionManager(
    "0x4ed83239189a803885cc888A6e470d1a13F7Ff4b"
  );
  await marketContract.setCollectionManager(
    "0x4ed83239189a803885cc888A6e470d1a13F7Ff4b"
  );
})();
