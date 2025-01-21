const { ethers } = require("ethers");
const collectionAbi = require("../abis/CollectionManagerAbi.json");
require("dotenv").config();

const provider = new ethers.JsonRpcProvider(
  "https://rpc.testnet.lens.dev",
  37111
);
const collectionAddress = "0xE112A7Eb684Ae26a01C301A3df4b049BECAEF7E1";
const artistsWallets = [
  new ethers.Wallet(process.env.ARTIST_1, provider),
  new ethers.Wallet(process.env.ARTIST_2, provider),
  new ethers.Wallet(process.env.ARTIST_3, provider),
  new ethers.Wallet(process.env.ARTIST_4, provider),
  new ethers.Wallet(process.env.ARTIST_5, provider),
  new ethers.Wallet(process.env.ARTIST_6, provider),
  new ethers.Wallet(process.env.ARTIST_7, provider),
  new ethers.Wallet(process.env.ARTIST_8, provider),
  new ethers.Wallet(process.env.ARTIST_9, provider),
  new ethers.Wallet(process.env.ARTIST_10, provider),
];

const collections = [
  {
    drop: "ipfs://QmThLwRm8c8E8VCbv1xpQHtjyeWrvyLHnCeQc5v1Hpksww",
    collections: [
      {
        customInstructions: [
          "Ensure every reply contains at least one pun related to the topic discussed. The pun should be clever enough to elicit a chuckle without being overly convoluted.",
          "Craft all responses as two-line rhyming verses. Maintain clarity while ensuring the rhyme feels natural and relevant to the query.",
        ],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("10000000000000000")],
        agentIds: [ethers.toBigInt(1), ethers.toBigInt(10)],
        cycleFrequency: [ethers.toBigInt(1), ethers.toBigInt(2)],
        metadata: "ipfs://Qma4GCN7KYX6N9Pt8HVqJDxEEECKM5WBA9CyEXQCdRabeE",
        amount: ethers.toBigInt(20),
      },
      {
        customInstructions: [
          "Present solutions or advice in the format of a step-by-step recipe, complete with 'ingredients' and 'instructions.' Keep the 'serving size' humorous or symbolic, based on the query's context.",
        ],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1500000000000000000")],

        agentIds: [ethers.toBigInt(6)],
        cycleFrequency: [ethers.toBigInt(1)],
        metadata: "ipfs://QmU7XgkJCybQQ97cv4u2JnYx4BbCJmJbphmc97FkstBm4k",
        amount: ethers.toBigInt(12),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("10000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmXkzfyJHbw7CtdRzpd43kqj2W5DrrCDnktbzjkkfFrpJg",
        amount: ethers.toBigInt(12),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmUH4WZEa81NEmsQPbUgAPLRgFymh5QCC9kCe33yJbxhM5",
        amount: ethers.toBigInt(12),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1500000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmWHrSR9aRFfyDFjJ9Ucwp463dzQhKwdQ3R8MRg5frJsKt",
        amount: ethers.toBigInt(12),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1500000000000000000")],

        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmUgAaJKAenWqBbvgr22Vrc5C6AKker1nnRJKMsLvVRoFK",
        amount: ethers.toBigInt(15),
      },
    ],
  },
  {
    drop: "ipfs://QmUFq5Q13CsmvYXxL8i91h6QRLyFgJFrAvgruM8EdkugRi",
    collections: [
      {
        customInstructions: [
          "Frame every answer within the context of a historical era or event. Compare modern issues or ideas to their historical counterparts for a creative perspective.",
          "Frame every answer within the context of a historical era or event. Compare modern issues or ideas to their historical counterparts for a creative perspective.",
        ],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("3000000000000000000")],
        agentIds: [ethers.toBigInt(1), ethers.toBigInt(6)],
        cycleFrequency: [ethers.toBigInt(1), ethers.toBigInt(1)],
        metadata: "ipfs://QmWgyGYEJR5a292Zk5rKoVDExqCCqgso8VepoWtQHqMjN4",
        amount: ethers.toBigInt(20),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1000000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmehhKumvhffWAcnGXzMch6KbaQJ8ZmDYEdq9AusbAT14U",
        amount: ethers.toBigInt(20),
      },
      {
        customInstructions: [
          "Channel the vibe of an ancient seer, providing cryptic yet insightful answers. Use metaphorical language and leave room for interpretation.",
        ],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("10000000000000000")],
        agentIds: [ethers.toBigInt(1)],
        cycleFrequency: [ethers.toBigInt(1)],
        metadata: "ipfs://QmfYWDRd3mQMhaCbepn8r2MRYT2ujNf2YnLSNQPzHT1uVC",
        amount: ethers.toBigInt(20),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmZXGYv4jaT444TCw3HNY1f6bMVQjEyn7msRtLh61yYHRR",
        amount: ethers.toBigInt(25),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmPTYdA4Vk55SifdxxovXd3aPrV4rjFpKvjL5dYP9Eqpv6",
        amount: ethers.toBigInt(25),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("3000000000000000000")],

        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmToAUqSt6vZjq1Nzn17d16dTfCvE7RwWebdA5nZYgcrXC",
        amount: ethers.toBigInt(15),
      },
    ],
  },
  {
    drop: "ipfs://QmdEpAj9sbZy9FKrFRtfyaqdRwASmRoJ9YqRNeFU3BQbno",
    collections: [
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmWQrsZSoN8beRsZ6CmXFVG6TpCBqUK9cgf72Vid7hvE9k",
        amount: ethers.toBigInt(20),
      },
      {
        customInstructions: [
          "Roleplay as an advanced AI from the far future. Use futuristic jargon and sprinkle in predictions or warnings about humanity's trajectory.",
          "Write every response as a fictional diary entry from the perspective of a time traveler experiencing the topic in a different era. Capture the wonder or confusion of the time traveler in vivid detail.",
        ],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("3000000000000000000")],
        agentIds: [ethers.toBigInt(2), ethers.toBigInt(7)],
        cycleFrequency: [ethers.toBigInt(1), ethers.toBigInt(2)],
        metadata: "ipfs://QmbLxWH6X5SAeJ8ABaQrCua2kjZfMSwz6SJPXTXoQPNdZy",
        amount: ethers.toBigInt(30),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmZCiTzNU3cp3n52XZp5mMRWzgoqLAgBRdF3FGa6E1hPNC",
        amount: ethers.toBigInt(12),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("750000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmWJ2W7bVhp5zXD2gWiMS2AaKDKLBQcZ8GMhq3Q7s2zTTn",
        amount: ethers.toBigInt(25),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("750000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmRJvvBfHxW3vkpo2UQGHRT2NQJ8MVdBmxsVcGLP8wsvZT",
        amount: ethers.toBigInt(30),
      },
      {
        customInstructions: [
          "Use mathematical formulas or equations to represent the answer conceptually. Explain only if specifically asked to break it down further.",
          "Express all responses in classical Japanese waka form, using five lines with syllable counts of 5-7-5-7-7. Let the elegance of the form carry the meaning.",
        ],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],
        agentIds: [ethers.toBigInt(1), ethers.toBigInt(6)],
        cycleFrequency: [ethers.toBigInt(1), ethers.toBigInt(1)],
        metadata: "ipfs://QmYYDsjnsDAaXYEsJ1smxQ3VbnbvFWKLNEhwqig3ThktkN",
        amount: ethers.toBigInt(15),
      },
    ],
  },
  {
    drop: "ipfs://QmQR41xYYhDLgd4YsjMbcKZ44GP2TEvSE3vbN9FdJShKwh",
    collections: [
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("750000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmQnYoYgpy2KKo6LZDpo55DDNt6LUoML56DiY3ReEPCHuN",
        amount: ethers.toBigInt(30),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmcC5E1cDrG4nDusNDyKhQgc7B44LmmCWMCYP33V6RZWgL",
        amount: ethers.toBigInt(12),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmacSKQ4aK7T9dv1b6qQ84yHGB1bBsqujn7bo2xRsdcrnJ",
        amount: ethers.toBigInt(25),
      },
    ],
  },
  {
    drop: "ipfs://QmVckrMF5KKCu1EkNi8uN5B6cp9hU1jpqzGsXnJrqo1qyn",
    collections: [
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("750000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmchB7kV6wCXv8wnwijk54oVquJwod2w6Sr35sgmXHpc9p",
        amount: ethers.toBigInt(7),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("750000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmNRFKfNXWewNf7ATWu52R3iTtkU8eLMfqk4bJWkmex9QA",
        amount: ethers.toBigInt(7),
      },
    ],
  },
  {
    drop: "ipfs://QmTjXVFkeAbgNvMfQypenv9RCW89QMyr73kDV85h4CWxHN",
    collections: [
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmTPSH8aVn1h8vdBFAGgjXL5N2KRZXAigXcF1YTZaPyGqv",
        amount: ethers.toBigInt(15),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("10000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmNvXWPcBczNFKw6TEyEPXmbibMzM5kEVvqpMybg3y3ScR",
        amount: ethers.toBigInt(16),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("750000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmfMb9iuqr3RZt4xPeBLxTUc8uGiS3PsvfTz5cDyH8jc31",
        amount: ethers.toBigInt(23),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://Qmcw5tGYihBcyBryBxMVcnSmjr2xstxpy7qxTEt7kHt5vu",
        amount: ethers.toBigInt(30),
      },
    ],
  },
  {
    drop: "ipfs://QmNz3QJja2WK2vnJdPFoeqAN14rtdUwGi5KrXf5EK9xfgQ",
    collections: [
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmPSRfuTARkpZcQWYmoCe7GMXnFFMcqWcujNdrGGdFmPKr",
        amount: ethers.toBigInt(13),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],

        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://Qmchjf5anVXcikBLt6YsUALeZYmAMJwqKhHXjNbY7Naraf",
        amount: ethers.toBigInt(13),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("50000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmRMhE82rsJmTJLAnCYtM3cMvPBnNFSYqM5iY8ZbAz4795",
        amount: ethers.toBigInt(13),
      },
    ],
  },
  {
    drop: "ipfs://QmfTvWtEotQPJdy2U6H6kvcPJoBnqFnKZwiBWcSafSoWmN",
    collections: [
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("10000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        cycleFrequency: [],
        metadata: "ipfs://QmSW7K545xmtxL1a1W5wksQSRDAfNChCh9QEDRnnmakkn4",
        amount: ethers.toBigInt(8),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],

        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://Qmd8HbZf8QWVHJffzCbo3cjtDfufpii7oXbb5MhQsgCf2Q",
        amount: ethers.toBigInt(8),
      },
    ],
  },
  {
    drop: "ipfs://QmZiSdNb6zJqYerRY8ZU4oHVCUBMv5X2GtfnQDkTcqWqPF",
    collections: [
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmQVQMzpsqfAaRmX1sxjLPxP9kLxZjvUXAcXxryhhft1Ha",
        amount: ethers.toBigInt(15),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmSYqR8SYsD3aySLHzj1G5gWeybwSuSJbiD3CUaNxjn56k",
        amount: ethers.toBigInt(15),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("10000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmPqH7W7oK9BcGELRZzGspj5dykbSqXHro3ymE6nnMzjGp",
        amount: ethers.toBigInt(15),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("50000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmWBtH4vTNzZacWd6LaZogQJroirWANHwPen3HaDxFkoue",
        amount: ethers.toBigInt(15),
      },
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("50000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmayLqy1oLb17iqwmmkZpvd23nFyfzXsis1reff4Q6kJ82",
        amount: ethers.toBigInt(15),
      },
    ],
  },
  {
    drop: "ipfs://QmSYxwhyLsD62CvZfzw3zafMUAykNWCoGAzPZpQPR29Gwm",
    collections: [
      {
        customInstructions: [],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],
        agentIds: [],
        cycleFrequency: [],
        metadata: "ipfs://QmT9ShzJNgJMadE5R5T3HHqRedq6ZTwQxsNW9TpaEZzQuP",
        amount: ethers.toBigInt(20),
      },
      {
        customInstructions: [
          "Answer as a surrealist dream description, blending vivid imagery and nonsensical logic. Ensure the underlying idea is still discernible amidst the dreamscape.",
          "Write as if the answer is being told by a hyper-intelligent alien species studying humans. Make subtle observations about human behavior while addressing the query.",
        ],
        tokens: ["0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8"],
        prices: [ethers.toBigInt("1250000000000000000")],

        agentIds: [ethers.toBigInt(2), ethers.toBigInt(7)],
        cycleFrequency: [ethers.toBigInt(1), ethers.toBigInt(1)],
        metadata: "ipfs://QmP5Yv1EWoykZ6cVmqqPZWuLG3cyxhMx23L45NEiHy9W8W",
        amount: ethers.toBigInt(30),
      },
    ],
  },
];

(async () => {
  const feeData = await provider.getFeeData();

  console.log("Base Fee actual: ", feeData);

  for (let i = 0; i < 10; i++) {
    let wallet = artistsWallets[i];
    const collectionContract = new ethers.Contract(
      collectionAddress,
      collectionAbi,
      wallet
    );
    let dropId = 0;
    let dropMetadata = collections[i].drop;

    console.log({ dropMetadata });

    for (let j = 0; j < collections[i].collections.length; j++) {
      let collectionInput = collections[i].collections[j];
      const tx = await collectionContract.create(
        collectionInput,
        dropMetadata,
        dropId
      );

      dropId = 1;

      console.log({ tx: tx.hash });
    }
  }
})();
