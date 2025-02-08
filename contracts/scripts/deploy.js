const { ethers, keccak256, toUtf8Bytes } = require("ethers");
require("dotenv").config();

const provider = new ethers.JsonRpcProvider(
  "https://rpc.testnet.lens.dev",
  37111
);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const collectionManagerAddress = "0xf29244D172dc0e54deB100D4E180e6A643bc76f3";
const marketAddress = "0x703A1F27c2ae703044F2896435b9e340bEaa95dF";
const agentsAddress = "0x93f12014B6bE2121b451536B05bD5c8ae65D173E";
const fulfillerAddress = "0x58DAA5A71F900FFb727E9902A07Eb0835f4C03c1";
const accessControlsAddress = "0x852FcD7a7782d3609e61E0A5fDe9A3328D8c0303";
const nftAddress = "0x55ee89D84Ae1B469b419D9D29760B23d9d4CdA94";
const skyhuntersAcAddress = "0x0512d639c0b32E29a06d95221899288152295aE6";

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

  await agentsContract.setCollectionManager(
    "0xf29244D172dc0e54deB100D4E180e6A643bc76f3"
  );
  await marketContract.setCollectionManager(
    "0xf29244D172dc0e54deB100D4E180e6A643bc76f3"
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

  // try {
  //   const res = await nftContract.accessControls();
  //   const res2 = await acContract.isFulfiller(
  //     "0x3D1f8A6D6584a1672d2817368783B9a2a36ae361"
  //   );
  //   console.log({ res, res2 });
  //   const tx1 = await acContract.addFulfiller(
  //     "0x3D1f8A6D6584a1672d2817368783B9a2a36ae361"
  //   );

  //   await tx1.wait();
  // } catch (error) {
  //   console.log(error);
  // }

  // const tx1 = await skyhuntersAcContract.setAcceptedToken(
  //   "0x68d0b8fa9288f84fa6e48e0d8ee92b22d514de26"
  // );
  // await tx1.wait();

  const tx2 = await fmContract.setMarket(
    "0x703A1F27c2ae703044F2896435b9e340bEaa95dF"
  );

  // await tx2.wait();

  // const tx3 = await fmContract.createFulfillerProfile({
  //   metadata: "ipfs://QmNSKfpUbPJe3cu5aDsmdG4S8xGJaiMCvNbrGnd1avqKRm",
  //   wallet: "0x3D1f8A6D6584a1672d2817368783B9a2a36ae361",
  // });

  // await tx3.wait();

  // const tx4 = await acContract.setTokenDetails(
  //   "0x68d0b8fa9288f84fa6e48e0d8ee92b22d514de26",
  //   "1000000000000000000000",
  //   "1200000000000000000000",
  //   "2300000000000000000000",
  //   "1100000000000000000000",
  //   10,
  //   "20000000000000000000"
  // );

  // const tx5 = await acContract.setTokenDetails(
  //   "0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8",
  //   "1000000000000000000000",
  //   "1000000000000000000000",
  //   "1300000000000000000000",
  //   "1000000000000000000000",
  //   14,
  //   "40000000000000000000"
  // );

  // await tx5.wait();

  await cmContract.setMarket("0x703A1F27c2ae703044F2896435b9e340bEaa95dF");
  await agentsContract.setMarket("0x703A1F27c2ae703044F2896435b9e340bEaa95dF");
  await fmContract.setMarket("0x703A1F27c2ae703044F2896435b9e340bEaa95dF");
  await nftContract.setMarket("0x703A1F27c2ae703044F2896435b9e340bEaa95dF");

  await skyhuntersAcContract.setAgentsContract("0x77c64743E42A99FA0c916C12Ab17B85c8c8458c7");
})();
