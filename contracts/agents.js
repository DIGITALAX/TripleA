const { ethers, keccak256, toUtf8Bytes } = require("ethers");
const agentsAbi = require("../abis/AgentsAbi.json");
const accessAbi = require("../abis/AccessControlsAbi.json");
const treasuryAbi = require("../abis/DevTreasuryAbi.json");
const marketAbi = require("../abis/MarketAbi.json");
const collectionAbi = require("../abis/CollectionManagerAbi.json");
const accountsAbi = require("../abis/AccountsAbi.json");
require("dotenv").config();


const provider = new ethers.JsonRpcProvider(
  "https://rpc.testnet.lens.dev",
  37111
);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const agentsAddress = "0xcDE1629239f0050ba8501D2bCc552F17128e4388";
const accessAddress = "0x317ed314b5Acf661b40Fb4A568530D1DF3af00fd";
const marketAddress = "0x0Cd2c3144EaD91606A190DEc6c112871020DAE0c";
const treasuryAddress = "0xc343A3DD6f1A0220e3a90dd7C30ceB58a6c98DaB";
const grassAddress = "0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8";
const collectionAddress = "0xE112A7Eb684Ae26a01C301A3df4b049BECAEF7E1";

(async () => {
  const feeData = await provider.getFeeData();
  const agentsContract = new ethers.Contract(agentsAddress, agentsAbi, wallet);
  // const accessContract = new ethers.Contract(accessAddress, accessAbi, wallet);
  // const marketContract = new ethers.Contract(marketAddress, marketAbi, wallet);
  // const treasuryContract = new ethers.Contract(
  //   treasuryAddress,
  //   treasuryAbi,
  //   wallet
  // );
  const collectionContract = new ethers.Contract(
    collectionAddress,
    collectionAbi,
    wallet
  );

  const value1 = await collectionContract.getAgentCollectionCycleFrequency(2,7);
  const value2 = await collectionContract.getAgentCollectionCycleFrequency(3,7);
  const value3 = await collectionContract.getAgentCollectionCustomInstructions(2,7);
  const value4 = await collectionContract.getAgentCollectionCustomInstructions(3,7);
  console.log({value1, value2, value3, value4})


  const value5 = await collectionContract.getAgentCollectionCycleFrequency(2,8);
  const value6 = await collectionContract.getAgentCollectionCycleFrequency(3,8);
  const value7 = await collectionContract.getAgentCollectionCustomInstructions(2,8);
  const value8 = await collectionContract.getAgentCollectionCustomInstructions(3,8);
  console.log({value5, value6, value7, value8})


  const value9 = await agentsContract.getAgentActiveBalance(grassAddress, 7, 3);
  const value10 = await agentsContract.getAgentActiveBalance(grassAddress, 8, 3);

  console.log({value9, value10})
  // const errores = [
  //   "NotAdmin()",
  //   "AlreadyAdmin()",
  //   "CannotRemoveSelf()",
  //   "AgentDoesntExist()",
  //   "AdminDoesntExist()",
  //   "AdminAlreadyExists()",
  //   "AgentAlreadyExists()",
  //   "OnlyAgentContract()",
  //   "TokenAlreadyExists()",
  //   "TokenDoesntExist()",
  //   "DropInvalid()",
  //   "OnlyMarketContract()",
  //   "ZeroAddress()",
  //   "InvalidAmount()",
  //   "NotArtist()",
  //   "CantDeleteSoldCollection()",
  //   "NotAvailable()",
  //   "TokenNotAccepted()",
  //   "PaymentFailed()",
  //   "OnlyAgentsContract()",
  //   "NotAgent()",
  //   "InsufficientBalance()",
  // ];

  // for (let i = 0; i < errores.length; i++) {
  //   console.log(
  //     errores[i],
  //     " ",
  //     keccak256(toUtf8Bytes(errores[i])).slice(0, 10),
  //     "\n"
  //   );
  // }

  // console.log("Base Fee actual:", feeData);

  // const agents_access = await accessContract.agentsContract();
  // const agents_treasury = await treasuryContract.agents();
  // const agents_market = await marketContract.agents();
  // const balance1 = await agentsContract.getAgentActiveBalance(
  //   GR,
  //   1,
  //   1
  // );
  // const balance2 = await agentsContract.getAgentActiveBalance(
  //   grassAddress,
  //   2,
  //   1
  // );
  // const balance3 = await agentsContract.getAgentActiveBalance(
  //   grassAddress,
  //   3,
  //   1
  // );
  // const balance4 = await agentsContract.getAgentActiveBalance(
  //   grassAddress,
  //   4,
  //   1
  // );
  // const meta1 = await agentsContract.getAgentMetadata(1);
  // const meta2 = await agentsContract.getAgentMetadata(2);
  // const meta3 = await agentsContract.getAgentMetadata(3);
  // const meta4 = await agentsContract.getAgentMetadata(4);
  // const agents = await collectionContract.getCollectionAgentIds(1);
  // console.log({
  //   agents_access,
  //   agents_treasury,
  //   agents_market,
  //   balance1,
  //   balance2,
  //   balance3,
  //   balance4,
  //   agents,
  //   meta1,
  //   meta2,
  //   meta3,
  //   meta4,
  // });

  // const accountContract = new ethers.Contract("0xd7aB6216A46e6Ec8A311ee3bdEf78Fff4227AAb5", accountsAbi, wallet);

  // const tx = await accountContract.updateAccountManagerPermissions(wallet.address, {
  //   canExecuteTransactions: true,
  //   canSetMetadataURI: true,
  //   canTransferNative: true,
  //   canTransferTokens: true,
  // });
  // const data = await accountContract.getAccountManagerPermissions(wallet.address);
  // const data_before = await accountContract.getAccountManagerPermissions("0x6391a36492904dff87d6bFd47C96D5dD920AFA7a");
  // const acc1 = await accountContract.addAccountManager("0xeC7b764AA9e05D2Ec3F7793c8f70697D2e51c053", {
  //   canExecuteTransactions: true,
  //   canSetMetadataURI: true,
  //   canTransferNative: true,
  //   canTransferTokens: true,
  // });
  // const data = await accountContract.getAccountManagerPermissions("0xeC7b764AA9e05D2Ec3F7793c8f70697D2e51c053");
// console.log({data_before,})
// const owner = await accountContract.owner();





  // console.log({data, tx, owner, acc1})
  // const tx_set_1 = await accessContract.setAgentsContract(agentsAddress)
  // await tx_set_1.wait();

  // const tx_remove_1 = await agentsContract.deleteAgent(1)
  // await tx_remove_1.wait();
  // const tx_remove_2 = await accessContract.deleteAgent(1)
  // await tx_remove_2.wait();
  // const tx_remove_3 = await accessContract.deleteAgent(2)
  // await tx_remove_3.wait();
  // const tx_remove_4 = await accessContract.deleteAgent(3)
  // await tx_remove_4.wait();

  // const tx_agent_1 = await agentsContract.createAgent(
  //   "ipfs://QmaAcy5ULMG6fv2LTEFAuYyEXLCSdoR38RTVmnN2fbaG34",
  //   "0x87dD364f74f67f1e13126D6Fd9a31b7d78C2cC12",
  //   // {
  //   //   gasLimit: 1000000,
  //   //   maxFeePerGas: feeData?.gasPrice,
  //   //   maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  //   // }
  // );
  // await tx_agent_1.wait();

  // const tx_agent_2 = await agentsContract.createAgent(
  //   "ipfs://QmWXkGh6QARjkXCYdigY3GQk1segNk3pLYadFQeKZL5cxH",
  //   "0x9bBca90ea8F188403fAB15Cd5bad4F9a46f56257",
  //   {
  //     gasLimit: 1000000,
  //     maxFeePerGas: feeData?.gasPrice,
  //     maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  //   }
  // );
  // await tx_agent_2.wait();

  // const tx_agent_3 = await agentsContract.createAgent(
  //   "ipfs://QmdvyAbV8ZPbbsqgCZeX6JxCmurk9tFSvPrKgK4RsQy72T",
  //   "0xa8ac1e95a53c79Eae348491f678A1Cf0c2F2519e",
  //   {
  //     gasLimit: 1000000,
  //     maxFeePerGas: feeData?.gasPrice,
  //     maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  //   }
  // );
  // await tx_agent_3.wait();

  // const counter =  await agentsContract.getAgentCounter();
  // const id =  await agentsContract.getAgentWallet(1);
  // const isAgent =  await accessContract.isAgent("0x8241Ee5A9f23611Ef6535B6c7E71ae24913306EC");
  // console.log({counter, id,isAgent})

  // const tx_agent_4 = await agentsContract.createAgent(
  //   "ipfs://Qmc76wMVu8hy4wM7hkepLMP3WFk3yk7TWdeQnriUDqVN8q",
  //   "0x8241Ee5A9f23611Ef6535B6c7E71ae24913306EC",
  //   // {
  //   //   gasLimit: 1000000,
  //   //   maxFeePerGas: feeData?.gasPrice,
  //   //   maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  //   // }
  // );
  // await tx_agent_4.wait();
})();
