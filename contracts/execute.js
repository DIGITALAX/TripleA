const { ethers } = require("ethers");
const accessAbi = require("../abis/AccessControlsAbi.json");
const nftAbi = require("../abis/NFTAbi.json");
const marketAbi = require("../abis/MarketAbi.json");
const agentsAbi = require("../abis/AgentsAbi.json");
const devsAbi = require("../abis/DevTreasuryAbi.json");
const collectionAbi = require("../abis/CollectionManagerAbi.json");
require("dotenv").config();

const provider = new ethers.JsonRpcProvider(
  "https://rpc.testnet.lens.dev",
  37111
);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

const accessAddress = "0x317ed314b5Acf661b40Fb4A568530D1DF3af00fd";
const marketAddress = "0x0Cd2c3144EaD91606A190DEc6c112871020DAE0c";
const agentsAddress = "0xcDE1629239f0050ba8501D2bCc552F17128e4388";
const nftAddress = "0x5307A5a7D10ceCf5f181495Dd6f7EBC1D17fB2E5";
const devAddress = "0xc343A3DD6f1A0220e3a90dd7C30ceB58a6c98DaB";
const collectionAddress = "0xE112A7Eb684Ae26a01C301A3df4b049BECAEF7E1";

(async () => {
  // Access Controls

  // const agentsContract = new ethers.Contract(agentsAddress, agentsAbi, wallet);
  // const tx_1 = await agentsContract.setAccessControls(accessAddress);
  // await tx_1.wait();
  // const marketContract = new ethers.Contract(marketAddress, marketAbi, wallet);
  // const tx_2 = await marketContract.setAccessControls(accessAddress);
  // await tx_2.wait();
  // const nftContract = new ethers.Contract(nftAddress, nftAbi, wallet);
  // const tx_3 = await nftContract.setAccessControls(accessAddress);
  // await tx_3.wait();
  // const devContract = new ethers.Contract(devAddress, devsAbi, wallet);
  // const tx_4 = await devContract.setAccessControls(accessAddress);
  // await tx_4.wait();
  // const collectionContract = new ethers.Contract(
  //   collectionAddress,
  //   collectionAbi,
  //   wallet
  // );
  // const tx_5 = await collectionContract.setAccessControls(accessAddress);
  // await tx_5.wait();
  
  // const accessContract = new ethers.Contract(accessAddress, accessAbi, wallet);
  // const feeData = await provider.getFeeData();

  // console.log("Base Fee actual:", feeData);

  //   const tx_1 = await accessContract.setAgentsContract(agentsAddress,  {
  //     gasLimit: 1000000,
  //     maxFeePerGas: feeData?.gasPrice,
  //     maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  //   });
  //   await tx_1.wait();

  //   const tx_2 = await accessContract.setAcceptedToken(
  //     "0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8", {
  //         gasLimit: 1000000,
  //         maxFeePerGas: feeData?.gasPrice,
  //         maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  //       }
  //   );
  //   await tx_2.wait();

  //   const tx_3 = await accessContract.setTokenThresholdAndRent(
  //     "0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8",
  //     "3000000000000000", "1000000000000000",  {
  //         gasLimit: 1000000,
  //         maxFeePerGas: feeData?.gasPrice,
  //         maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  //       }
  //   );

  //   // const tx_3 = await accessContract.setTokenThresholdAndRent(
  //   //   "0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8",
  //   //   "THRESHOLD MUST BE 3 X RENT", "RENT",  {
  //   //       gasLimit: 1000000,
  //   //       maxFeePerGas: feeData?.gasPrice,
  //   //       maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  //   //     }
  //   // );
  //   await tx_3.wait();

  // // // Collection Manager
  // const collectionContract = new ethers.Contract(
  //   collectionAddress,
  //   collectionAbi,
  //   wallet
  // );

  // const tx_coll_1 = await collectionContract.setMarket(marketAddress, {
  //   gasLimit: 1000000,
  //   maxFeePerGas: feeData?.gasPrice,
  //   maxPriorityFeePerGas: feeData?.maxPriorityFeePerGas,
  // });
  // await tx_coll_1.wait();

  // // // NFT
  // const nftContract = new ethers.Contract(nftAddress, nftAbi, wallet);

  // const tx_nft_1 = await nftContract.setMarket(marketAddress);
  // await tx_nft_1.wait();

  // // // Market
  // const marketContract = new ethers.Contract(marketAddress, marketAbi, wallet);
  // // // const collection = await marketContract.collectionManager();
  // // // const devTreasury = await marketContract.devTreasury();
  // // // const agents = await marketContract.agents();
  // // // console.log({ collection, devTreasury, agents });

  // const tx_market_1 = await marketContract.setDevTreasury(devAddress);
  // await tx_market_1.wait();

  // const tx_market_2 = await marketContract.setCollectionManager(collectionAddress);
  // await tx_market_2.wait();

  // const tx_market_3 = await marketContract.setAgents(agentsAddress);
  // await tx_market_3.wait();

  // // // Agents
  // const agentsContract = new ethers.Contract(agentsAddress, agentsAbi, wallet);

  // const tx_agent_1 = await agentsContract.setMarket(marketAddress);
  // await tx_agent_1.wait();

  // // // const agentIds = await collectionContract.getCollectionAgentIds(5);
  // // // const amountSold = await collectionContract.getCollectionAmountSold(5);
  // // // const prices = await collectionContract.getCollectionPrices(5);
  // // // const threshold = await accessContract.getTokenThreshold(GRASS_CONTRACT);

  // // // console.log({ agentIds, amountSold, prices, threshold });
  // // // let balances = [];
  // // // let wallets = [];
  // // // for (let i = 0; i < agentIds?.length; i++) {
  // // //   const balance = await agentsContract.getAgentActiveBalance(
  // // //     GRASS_CONTRACT,
  // // //     agentIds[i],
  // // //     5
  // // //   );

  // // //   const wallet = await agentsContract.getAgentWallet(agentIds[i]);

  // // //   balances.push(balance);
  // // //   wallets.push(wallet);
  // // // }

  // // // console.log({ balances, wallets });

  // // // const wgrassContract = new ethers.Contract(GRASS_CONTRACT, wgrassAbi, wallet);

  // // // const balance = await wgrassContract.balanceOf("0xd2dA1a02403125c0DE8BC23417DeA9e6f09eD89a");
  // // // const allowance = await wgrassContract.allowance("0xd2dA1a02403125c0DE8BC23417DeA9e6f09eD89a", marketAddress);

  // // // const counter = await agentsContract.getAgentCounter();
  // // // console.log({ balance, allowance, counter });

  // // //   // Dev
  // const devContract = new ethers.Contract(devAddress, devsAbi, wallet);
  // // // const market = await devContract.market();
  // // // const agents = await devContract.agents();
  // // // console.log({ market, agents });

  // const tx_dev_1 = await devContract.setMarket(marketAddress);
  // await tx_dev_1.wait();

  // const tx_dev_2 = await devContract.setAgents(agentsAddress);
  // await tx_dev_2.wait();
})();
