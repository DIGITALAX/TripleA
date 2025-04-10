const { ethers, parseEther } = require("ethers");
require("dotenv").config();
const skyhuntersAgentsAbi = require("../../server/abis/SkyhuntersAgentManager.json");

const provider = new ethers.JsonRpcProvider("https://rpc.lens.xyz", 232);

const skyhuntersAgentAddress = "0xDb073899eef2Dcf496Ee987F5238c5E9FE5d5933";
const owner = "0xAA3e5ee4fdC831e5274FE7836c95D670dC2502e6";
(async () => {
  const agents = [];
  const details = [
    // {
    //   metadata: "ipfs://QmYZMP1duxTibWFsNXC9Yn43NoERurW7zaxuz57xL8wJF2",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmRQ9mLypaRMLkdkgLTuJz7kyvv8JNCNZTZdqfrb168BPv",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmcVAobWZ3sV5UktbCckNbFRPQ57KY5VZbPkom8shUn9eo",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmRhc54Ph12irgwWPwWQbB2BdZ87rBMxCHLqrnaSgYkXeA",
    //   skyhunter: false,
    //   studio: true,
    // },

    // {
    //   metadata: "ipfs://QmVATpRbzdaQajhGXcJaj5eq3kKbc8fPiHPVJ6RfGwbaFf",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmXPXB3FquqpVsQ1aJQ1DqA1fnfbHvGNB4sgbzTmxGAnTo",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmQMR7YTh9zaYqEVhgs22pvr3NEUSX1q1dTeQmAj1duFJe",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmXEWnLN27kxB445DSmMsgxuyFttsrS53ekmF5Xz9rJoxd",
    //   skyhunter: false,
    //   studio: true,
    // },

    // {
    //   metadata: "ipfs://QmVSjhtjqecsaykstT65jyVi2oqXwzEEFbuHVawZ2r9rHT",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmbsbjRgTmVbvcgSabQLfbDS2iRdRadQsYV43Nk6ifwSqZ",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmbJpyBPwh7Gcj7Q7CpPuLtuE6JDk73rRD5Sk9s4i2JaQ4",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmRrkNnTK37eZhnNqLQ5bsM74Car8dNJw3ZZrr5NPd6sZH",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmcSAnVnE8EuXQ757bRm4WMmW3VpaJsXE6V2tKfZzF44NS",
    //   skyhunter: false,
    //   studio: true,
    // },

    // {
    //   metadata: "ipfs://QmXi7bjbdTQFDWsttLFsEWswnJtaa6eYEC9YJ8sgnHWdSx",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://Qmduo4e3fb2eBMtdq3AvUMxSbZ452QKymY6WPBZbkkNbum",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmcedxrfWqKXem4dJh5wq3YRknRd6rnWWGeDBb1SeZXkR6",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmbZ8URy2CzxZPDdpEmH9WKV3Pyy2R7QaJ1Mv2kqqUfsYY",
    //   skyhunter: false,
    //   studio: true,
    // },
    // {
    //   metadata: "ipfs://QmWcfNyCwqn3qtH8xT9fWCyDf2o5ZYWzfaqQYpKrgK9THX",
    //   skyhunter: false,
    //   studio: true,
    // },

    {
      metadata: "ipfs://QmSJebaK9JSCJeKwKQG9NLS7x6evZnm1Ls4GB72YGEHrLr",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmPMfryDWirmg3KULwKbbFgrj8Bvpu6wp7ZBcbHEW94HVZ",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmY9dGDekEChE1NmebJ5UN9K6dS42nHEVkBY6WB4Xf8nct",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmYUMAzMs2ZFtPJLZwjNrcTPXiz85PmJpJbTWovA6WWXse",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmYDAJSEGSq7fFqZu64HY7MAA7ELXcWnHS4DTz7kR75d29",
      skyhunter: false,
      studio: true,
    },

    {
      metadata: "ipfs://QmT8kSpnoBnwsuAnaCjcFyL1WKJxz4SynZ4gEAGWyREbtL",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmdunhHhcpCQ19Xf7N1z9EqVnE6MR4jC9rwe1PpsaeKf4s",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmaVEAvtNASmSzsRcasoQ6adbeR2jmULdzdQp8x5f3uBEP",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmYmVcy4tp9fiFZNqJrVDJKukMcMcsUCiQoaV8HhHFoXmQ",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmZzZNzH9oyLfqPzoaYtq7LgRnRNum3QT8hK8uSAdxHYFi",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmSWnKvNX91XoT1ULheQU71cbL3vtFgKDfJFEZDZnGBKxf",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmRDM87KNAmro9CtWMU4iB6uSy7KLVkkw6xLEsigNvb6mD",
      skyhunter: false,
      studio: true,
    },

    {
      metadata: "ipfs://QmZwhYT1hSSvLFGpMbs263KhMTyWN7Vdm2vw5jb3n3hog5",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmQut4wThBhjEah6JWmt3znkjfjog3vD2Tomsom4cDopWf",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmXPbWz8BSSffHzsxfvvUDfATQxc2QiraxqCB1aHQX9xy3",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmPGp8qwvYrf23gEE6gjRMBPBwc97TtpKDks7BELyGXUdt",
      skyhunter: false,
      studio: true,
    },
    {
      metadata: "ipfs://QmUJb7YB2wUfpywaDris6cFujcxLaBdUkCCwPvTffqwDtt",
      skyhunter: false,
      studio: true,
    },
  ];

  if (agents.length != details.length) {
    console.log("invalid data");
    return;
  }

  for (let i = 0; i < agents.length; i++) {
    const wallet = new ethers.Wallet(agents[i], provider);
    const mainWallet = new ethers.Wallet("", provider);

    if (i !== 0) {
      const tx = {
        to: wallet.address,
        value: parseEther("0.02"),
      };
      const transaction = await mainWallet.sendTransaction(tx);
      await transaction.wait();
    }

    const skyhuntersAgentContract = new ethers.Contract(
      skyhuntersAgentAddress,
      skyhuntersAgentsAbi,
      mainWallet
    );

    await skyhuntersAgentContract.createAgent(
      [wallet.address],
      [owner],
      details[i].metadata,
      details[i].skyhunter,
      details[i].studio
    );
  }
})();
