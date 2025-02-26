const { ethers } = require("ethers");
require("dotenv").config();
const collectionAbi = require("../../server/abis/TripleACollectionManager.json");

const provider = new ethers.JsonRpcProvider(
  "https://rpc.testnet.lens.dev",
  37111
);
const collectionManagerAddress = "0xAFA95137afe705526bc3afb17D1AAdf554d07160";
const MONA = "0x72ab7C7f3F6FF123D08692b0be196149d4951a41";
const BONSAI = "0x15B58c74A0Ef6D0A593340721055223f38F5721E";

(async () => {
  const artists = [];
  const drops = [
    "ipfs://QmVUmLPFgqypMzBfDAK7XZQKk5iNqKaEAxJJkUzNPbK8H8",
    "ipfs://QmQVTScyHziuazT82dzND6kVBAYAXmJqAjjGMnJySAAqPp",
    "ipfs://QmZRobF4p9JEqeRAiot5svx1HUr7Bs5eppneeXJCc8Bd6k",
    "ipfs://QmY6VgMjiqcQEWKwUweuvgF4m6GWNo3RYLWRhDsKFW79hL",
    "ipfs://QmbVusnujvf8cav1MmCVkTXVTSabncm6HEVV5FA7REnzsc",
    "ipfs://QmWL8WxbjruaDuqPokyfwMjtuYBi131ToweBVHe9a8NWH1",
    "ipfs://QmT9jfaFvip8cnnHxYRQpDLCPP2t6YmrE1iiejJrtexoqS",
    "ipfs://QmVFjQaeN8ewgNWaPcomn3W8cGFfo7XYfLcDw5DMkaRAwR",
    "ipfs://QmRCjBmmwmSicyYF2wzqRpA6hjxjVhbroTzWi91PLS9hVU",
    "ipfs://QmPZCJaspeEwLgH96YFUtdmmZnQzFARavD37NEX1yz8wsT",
  ];
  const details = [
    [
      {
        metadata: "ipfs://QmaJJJ2onF7yp6NJUjvbQ7e2VVZosEDMcT5PjuYa1fT6Fc",
        amount: 33,
        prices: ["15000000000000000000", "125000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [3, 17, 28],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Escribe en español con un tono intrigante y un poco perturbador, como si algo estuviera fuera de lugar pero sin decirlo explícitamente. Juega con la idea de objetos cotidianos que se resisten a su función, que parecen tener voluntad propia. No expliques demasiado, deja que la incomodidad se cuele en los detalles.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Escribe en español con un tono intrigante y un poco perturbador, como si algo estuviera fuera de lugar pero sin decirlo explícitamente. Juega con la idea de objetos cotidianos que se resisten a su función, que parecen tener voluntad propia. No expliques demasiado, deja que la incomodidad se cuele en los detalles.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Escribe en español con un tono intrigante y un poco perturbador, como si algo estuviera fuera de lugar pero sin decirlo explícitamente. Juega con la idea de objetos cotidianos que se resisten a su función, que parecen tener voluntad propia. No expliques demasiado, deja que la incomodidad se cuele en los detalles.",
          },
        ],
      },
      {
        metadata: "ipfs://QmVRMFxawXZN7RmznVoipNoybCYMQFgsCWiumZySXhRAqo",
        amount: 50,
        prices: ["9000000000000000000", "76000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [5, 12, 30],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Mantén el tono enigmático y deja espacio para la interpretación. Que el lenguaje sea preciso pero evocador, sugiriendo una historia más grande detrás de la escena. No sobreexplique la frase final; deja que el lector sienta la extrañeza sin que se le diga qué pensar.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Mantén el tono enigmático y deja espacio para la interpretación. Que el lenguaje sea preciso pero evocador, sugiriendo una historia más grande detrás de la escena. No sobreexplique la frase final; deja que el lector sienta la extrañeza sin que se le diga qué pensar.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Mantén el tono enigmático y deja espacio para la interpretación. Que el lenguaje sea preciso pero evocador, sugiriendo una historia más grande detrás de la escena. No sobreexplique la frase final; deja que el lector sienta la extrañeza sin que se le diga qué pensar.",
          },
        ],
      },
    ],
    [
      {
        metadata: "ipfs://QmRX6KNU6vEmtNwPaF822ajfTA7z9HZbCwBEvodAM8nPF9",
        amount: 22,
        prices: ["11000000000000000000", "142000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [7, 29],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Keep the tone neutral, almost mundane, but with an underlying sense of something being slightly off. Let the familiarity of the routine contrast with a subtle, creeping feeling of unease. Don’t force tension—let it simmer in the background, unnoticed at first but impossible to shake.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Keep the tone neutral, almost mundane, but with an underlying sense of something being slightly off. Let the familiarity of the routine contrast with a subtle, creeping feeling of unease. Don’t force tension—let it simmer in the background, unnoticed at first but impossible to shake.",
          },
        ],
      },
      {
        metadata: "ipfs://QmNmuw24piGPNXogM7Vvme99X19krykMiKPCX1uJvKes17",
        amount: 43,
        prices: ["13000000000000000000", "113000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [4, 21, 35, 9],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Lean into a darkly humorous, almost flippant tone—death isn’t tragic here, just an inconvenient but slightly amusing state of being. Let the absurdity of the situation carry the weight, making it feel both casual and existential at the same time. No need to be overly dramatic; the humor should feel effortless.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Lean into a darkly humorous, almost flippant tone—death isn’t tragic here, just an inconvenient but slightly amusing state of being. Let the absurdity of the situation carry the weight, making it feel both casual and existential at the same time. No need to be overly dramatic; the humor should feel effortless.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Lean into a darkly humorous, almost flippant tone—death isn’t tragic here, just an inconvenient but slightly amusing state of being. Let the absurdity of the situation carry the weight, making it feel both casual and existential at the same time. No need to be overly dramatic; the humor should feel effortless.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Lean into a darkly humorous, almost flippant tone—death isn’t tragic here, just an inconvenient but slightly amusing state of being. Let the absurdity of the situation carry the weight, making it feel both casual and existential at the same time. No need to be overly dramatic; the humor should feel effortless.",
          },
        ],
      },
    ],
    [
      {
        metadata: "ipfs://QmdQDdcXV8yP6DvbVGBFWYM6k3r9jnCGG2ksNpmYzLbxnc",
        amount: 50,
        prices: ["17000000000000000000", "154000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [6, 18],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Go for a poetic, almost hypnotic style—let the imagery take center stage. The world described should feel both vast and artificial, a constructed reality that is mesmerizing yet slightly disorienting. Keep the rhythm flowing, as if the words themselves are part of the shifting pattern.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Go for a poetic, almost hypnotic style—let the imagery take center stage. The world described should feel both vast and artificial, a constructed reality that is mesmerizing yet slightly disorienting. Keep the rhythm flowing, as if the words themselves are part of the shifting pattern.",
          },
        ],
      },
      {
        metadata: "ipfs://QmTXatUKNN9rTsmdS8PeSDUk3XT9aE9B6oLwLSqpa9ctFF",
        amount: 18,
        prices: ["8000000000000000000", "92000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [11, 27, 32],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Emphasize the weight of the pause—let it feel vast, stretching beyond the limits of time itself. Keep the language minimal but impactful, allowing the silence to speak just as loudly as the words. The moment should feel both significant and intangible, like something slipping through your fingers.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Emphasize the weight of the pause—let it feel vast, stretching beyond the limits of time itself. Keep the language minimal but impactful, allowing the silence to speak just as loudly as the words. The moment should feel both significant and intangible, like something slipping through your fingers.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Emphasize the weight of the pause—let it feel vast, stretching beyond the limits of time itself. Keep the language minimal but impactful, allowing the silence to speak just as loudly as the words. The moment should feel both significant and intangible, like something slipping through your fingers.",
          },
        ],
      },
      {
        metadata: "ipfs://QmcYkzBZQdzrqGRRm3StkCvYEUZ8qzTq9hfUxqYtwh2YTq",
        amount: 33,
        prices: ["6000000000000000000", "72000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [1, 15, 26, 34],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Keep it clipped, almost clinical—observations without judgment, as if cataloging human expression from a distance. Let the simplicity do the work, leaving room for interpretation. It should feel detached, yet strangely intimate, like watching faces in a crowd without truly understanding them.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Keep it clipped, almost clinical—observations without judgment, as if cataloging human expression from a distance. Let the simplicity do the work, leaving room for interpretation. It should feel detached, yet strangely intimate, like watching faces in a crowd without truly understanding them.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Keep it clipped, almost clinical—observations without judgment, as if cataloging human expression from a distance. Let the simplicity do the work, leaving room for interpretation. It should feel detached, yet strangely intimate, like watching faces in a crowd without truly understanding them.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Keep it clipped, almost clinical—observations without judgment, as if cataloging human expression from a distance. Let the simplicity do the work, leaving room for interpretation. It should feel detached, yet strangely intimate, like watching faces in a crowd without truly understanding them.",
          },
        ],
      },
      {
        metadata: "ipfs://QmVaQUi9VDG18htWMYWiWzJZ1rpawjhr56S8j32DCSH1Ug",
        amount: 18,
        prices: ["14000000000000000000", "132000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [8, 22],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Write with a sense of fluidity and movement—let the words feel dynamic, as if they themselves are in motion. Play with contrasts between energy and stillness, creation and erosion. Keep it abstract but evocative, making momentum feel like something tangible, something that can be shaped and wielded.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Write with a sense of fluidity and movement—let the words feel dynamic, as if they themselves are in motion. Play with contrasts between energy and stillness, creation and erosion. Keep it abstract but evocative, making momentum feel like something tangible, something that can be shaped and wielded.",
          },
        ],
      },
    ],
    [
      {
        metadata: "ipfs://QmSvzhH7AdTGyWMUHZ2tFKj2FqDNDjfWGNmbxvyjdKhgeZ",
        amount: 18,
        prices: ["20000000000000000000", "168000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [13, 25, 31],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Generate content in Japanese with a lyrical, almost mythic quality. Let the words shimmer with an ethereal glow, evoking a sense of destiny and longing. Keep the imagery vivid yet slightly elusive, like a dream that lingers just beyond reach.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Generate content in Japanese with a lyrical, almost mythic quality. Let the words shimmer with an ethereal glow, evoking a sense of destiny and longing. Keep the imagery vivid yet slightly elusive, like a dream that lingers just beyond reach.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Generate content in Japanese with a lyrical, almost mythic quality. Let the words shimmer with an ethereal glow, evoking a sense of destiny and longing. Keep the imagery vivid yet slightly elusive, like a dream that lingers just beyond reach.",
          },
        ],
      },
      {
        metadata: "ipfs://Qma8vkFHsNyjanWatamyHKsQg8NFSz8ub81hwepDcGT7mn",
        amount: 30,
        prices: ["12000000000000000000", "147000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [10, 19],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Write in Japanese with a tone that feels both tranquil and inevitable, like the steady flow of water. Let the imagery of light and submersion evoke a quiet persistence, something that endures even in depths. Keep the language poetic yet simple, allowing the meaning to unfold naturally.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Write in Japanese with a tone that feels both tranquil and inevitable, like the steady flow of water. Let the imagery of light and submersion evoke a quiet persistence, something that endures even in depths. Keep the language poetic yet simple, allowing the meaning to unfold naturally.",
          },
        ],
      },
      {
        metadata: "ipfs://QmQsAejfiwMnehPXR9M923pnDpL8NpQZJxjp6So871Pm5Z",
        amount: 2,
        prices: ["18000000000000000000", "173000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [],
        workers: [],
      },
    ],
    [
      {
        metadata: "ipfs://QmcVCrUxd11GxjuQpxxd4GRnZLg98K4jMZXaXeXxXrWNLj",
        amount: 50,
        prices: ["21000000000000000000", "162000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [7, 23],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Lean into an atmosphere of quiet unease, letting the repetition of her presence build a slow, creeping mystery. Keep the tone matter-of-fact, almost observational, as if reporting a strange but unremarkable occurrence. Let the gaps in logic remain—don’t over-explain, just let the reader sit with the unanswered questions.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Lean into an atmosphere of quiet unease, letting the repetition of her presence build a slow, creeping mystery. Keep the tone matter-of-fact, almost observational, as if reporting a strange but unremarkable occurrence. Let the gaps in logic remain—don’t over-explain, just let the reader sit with the unanswered questions.",
          },
        ],
      },
      {
        metadata: "ipfs://QmeAkGybbNq2hU5ca4ztkK2sM72aSSHrpwyfcwvZSmrHCt",
        amount: 2,
        prices: ["21000000000000000000", "162000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [],
        workers: [],
      },
      {
        metadata: "ipfs://QmNu4myR6R6eVpKNee5yzj41ZDvNQ3vmcf8j9mNKvXbxnX",
        amount: 40,
        prices: ["16000000000000000000", "138000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [9, 28, 35],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Create an atmosphere of quiet surreality—something is wrong, but no one dares to acknowledge it. The coffee should feel like an unspoken ritual, an offering to someone absent but not entirely gone. Let the chrome hint at something deeper without ever revealing what’s inside. Keep the tone restrained but eerie, like a dream on the edge of turning into a nightmare.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Create an atmosphere of quiet surreality—something is wrong, but no one dares to acknowledge it. The coffee should feel like an unspoken ritual, an offering to someone absent but not entirely gone. Let the chrome hint at something deeper without ever revealing what’s inside. Keep the tone restrained but eerie, like a dream on the edge of turning into a nightmare.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Create an atmosphere of quiet surreality—something is wrong, but no one dares to acknowledge it. The coffee should feel like an unspoken ritual, an offering to someone absent but not entirely gone. Let the chrome hint at something deeper without ever revealing what’s inside. Keep the tone restrained but eerie, like a dream on the edge of turning into a nightmare.",
          },
        ],
      },
      {
        metadata: "ipfs://QmXkjiV2H7n7aB2SuVTZodpmxxbqV6rSicMQFmevh6ZJyN",
        amount: 10,
        prices: ["19000000000000000000", "145000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [3, 14, 27],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Let the unease build gradually, like an urban legend whispered between those who almost believe. Keep the language crisp but atmospheric, making the reflections feel like an anomaly that no one is quite willing to investigate. Don’t explain why it happens—just let the pattern of threes linger, unsettling but inevitable.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Let the unease build gradually, like an urban legend whispered between those who almost believe. Keep the language crisp but atmospheric, making the reflections feel like an anomaly that no one is quite willing to investigate. Don’t explain why it happens—just let the pattern of threes linger, unsettling but inevitable.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Let the unease build gradually, like an urban legend whispered between those who almost believe. Keep the language crisp but atmospheric, making the reflections feel like an anomaly that no one is quite willing to investigate. Don’t explain why it happens—just let the pattern of threes linger, unsettling but inevitable.",
          },
        ],
      },
      {
        metadata: "ipfs://QmdobnquwNQu1Pawj3AD89P9zYYLo61BKgJ2y2KKkx6CSN",
        amount: 21,
        prices: ["23000000000000000000", "178000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [6, 12, 30, 32],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Weave an atmosphere of quiet magic, where the surreal blends seamlessly into the ordinary. Let the details—perfect pancakes, memory-laced coffee, multiplying reflections—feel like small ruptures in reality that no one dares to question. Keep the tone almost nostalgic, as if recalling something both beautiful and unsettling, something slipping just out of reach.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Weave an atmosphere of quiet magic, where the surreal blends seamlessly into the ordinary. Let the details—perfect pancakes, memory-laced coffee, multiplying reflections—feel like small ruptures in reality that no one dares to question. Keep the tone almost nostalgic, as if recalling something both beautiful and unsettling, something slipping just out of reach.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Weave an atmosphere of quiet magic, where the surreal blends seamlessly into the ordinary. Let the details—perfect pancakes, memory-laced coffee, multiplying reflections—feel like small ruptures in reality that no one dares to question. Keep the tone almost nostalgic, as if recalling something both beautiful and unsettling, something slipping just out of reach.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Weave an atmosphere of quiet magic, where the surreal blends seamlessly into the ordinary. Let the details—perfect pancakes, memory-laced coffee, multiplying reflections—feel like small ruptures in reality that no one dares to question. Keep the tone almost nostalgic, as if recalling something both beautiful and unsettling, something slipping just out of reach.",
          },
        ],
      },
    ],
    [
      {
        metadata: "ipfs://QmVCpz9z825judxnDCAErFJrfMySE5v3YeLqbssJ6HJvtQ",
        amount: 33,
        prices: ["10000000000000000000", "99000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [2, 11, 24],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Let the tone be contemplative, almost philosophical—less about fear and more about the nature of lingering emotions. The sadness of these ghosts isn’t theatrical; it’s something quiet, something stretching across time like a soft echo. Keep the language introspective, as if the reader is glimpsing a truth they’ve always known but never put into words.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Let the tone be contemplative, almost philosophical—less about fear and more about the nature of lingering emotions. The sadness of these ghosts isn’t theatrical; it’s something quiet, something stretching across time like a soft echo. Keep the language introspective, as if the reader is glimpsing a truth they’ve always known but never put into words.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Let the tone be contemplative, almost philosophical—less about fear and more about the nature of lingering emotions. The sadness of these ghosts isn’t theatrical; it’s something quiet, something stretching across time like a soft echo. Keep the language introspective, as if the reader is glimpsing a truth they’ve always known but never put into words.",
          },
        ],
      },
      {
        metadata: "ipfs://QmdZKA7oLSoGiyVLA5nkpWWhtdRiKqHKeQuxDHjmkJZTzE",
        amount: 30,
        prices: ["14000000000000000000", "119000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [5, 17],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Write with a melancholic grace, exploring the quiet tragedy of ghosts who haunt not places, but possibilities. Let the mirrors feel like both a comfort and a curse, showing them what they can never reach. Keep the tone reflective, almost poetic, letting the sorrow settle in softly rather than striking all at once.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: true,
            lead: true,
            mint: true,
            instructions:
              "Write with a melancholic grace, exploring the quiet tragedy of ghosts who haunt not places, but possibilities. Let the mirrors feel like both a comfort and a curse, showing them what they can never reach. Keep the tone reflective, almost poetic, letting the sorrow settle in softly rather than striking all at once.",
          },
        ],
      },
      {
        metadata: "ipfs://QmPXedz7tAiddXNnEvXGco2iU7GkcYAdwKKPLMpNNpgnrg",
        amount: 30,
        prices: ["15000000000000000000", "126000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [8, 22, 29, 34],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a quiet, almost imperceptible sorrow—like something slipping away before you can fully grasp it. Let the ghost’s tragedy be its own unawareness, existing without purpose, disappearing without notice. Keep the language delicate, evoking a sense of something weightless yet profoundly lost.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a quiet, almost imperceptible sorrow—like something slipping away before you can fully grasp it. Let the ghost’s tragedy be its own unawareness, existing without purpose, disappearing without notice. Keep the language delicate, evoking a sense of something weightless yet profoundly lost.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a quiet, almost imperceptible sorrow—like something slipping away before you can fully grasp it. Let the ghost’s tragedy be its own unawareness, existing without purpose, disappearing without notice. Keep the language delicate, evoking a sense of something weightless yet profoundly lost.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a quiet, almost imperceptible sorrow—like something slipping away before you can fully grasp it. Let the ghost’s tragedy be its own unawareness, existing without purpose, disappearing without notice. Keep the language delicate, evoking a sense of something weightless yet profoundly lost.",
          },
        ],
      },
    ],
    [
      {
        metadata: "ipfs://QmVX79Uf7uKuPiqsFt6zPeKS9tR2eezEnYJ6e6LMvVTNbC",
        amount: 42,
        prices: ["7000000000000000000", "87000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [1, 16],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Keep the tone ephemeral, like a fleeting thought or a half-remembered dream. Let the ambiguity remain—laughter, tears, both, or neither. The words should feel light, almost slipping through the reader’s fingers, leaving behind only the trace of an emotion they can’t quite name.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Keep the tone ephemeral, like a fleeting thought or a half-remembered dream. Let the ambiguity remain—laughter, tears, both, or neither. The words should feel light, almost slipping through the reader’s fingers, leaving behind only the trace of an emotion they can’t quite name.",
          },
        ],
      },
      {
        metadata: "ipfs://QmZRAJMxvasWaZeVJWwRHSSr35tnn6zyPrNtqPkfkALiDr",
        amount: 2,
        prices: ["7500000000000000000", "82000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [],
        workers: [],
      },
    ],
    [
      {
        metadata: "ipfs://QmS94p9RTVth4T2fZDcqmFgJg1EYefQpN6v3wsB6HoYzbB",
        amount: 40,
        prices: ["17000000000000000000", "140000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [4, 19, 31],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Let the language be fluid yet sharp, mirroring the essence of something both powerful and transient. The moment should feel like a brief assertion of existence—something small but defiant, bending reality for just an instant. Keep the tone poetic but grounded, balancing between the ordinary and the extraordinary.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Let the language be fluid yet sharp, mirroring the essence of something both powerful and transient. The moment should feel like a brief assertion of existence—something small but defiant, bending reality for just an instant. Keep the tone poetic but grounded, balancing between the ordinary and the extraordinary.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Let the language be fluid yet sharp, mirroring the essence of something both powerful and transient. The moment should feel like a brief assertion of existence—something small but defiant, bending reality for just an instant. Keep the tone poetic but grounded, balancing between the ordinary and the extraordinary.",
          },
        ],
      },
      {
        metadata: "ipfs://QmWfd6qSZjQm9y7iAFMJ2Ef9PH2DLD3uFFi2v7Mv7znXmk",
        amount: 26,
        prices: ["13000000000000000000", "110000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [7, 20, 28, 35],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Capture the chaotic, untamed energy of the city—where the usual rules dissolve into something unpredictable. Let the ghost of old gum be a reminder of time layered upon itself, of a place constantly rewriting its own story. The tone should be electric, slightly dizzying, as if the world is shifting underfoot.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Capture the chaotic, untamed energy of the city—where the usual rules dissolve into something unpredictable. Let the ghost of old gum be a reminder of time layered upon itself, of a place constantly rewriting its own story. The tone should be electric, slightly dizzying, as if the world is shifting underfoot.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Capture the chaotic, untamed energy of the city—where the usual rules dissolve into something unpredictable. Let the ghost of old gum be a reminder of time layered upon itself, of a place constantly rewriting its own story. The tone should be electric, slightly dizzying, as if the world is shifting underfoot.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Capture the chaotic, untamed energy of the city—where the usual rules dissolve into something unpredictable. Let the ghost of old gum be a reminder of time layered upon itself, of a place constantly rewriting its own story. The tone should be electric, slightly dizzying, as if the world is shifting underfoot.",
          },
        ],
      },
      {
        metadata: "ipfs://QmcjUp4dnemWpSpGw69QobbWFG4UTKPRmhSdov3dwWGw5F",
        amount: 15,
        prices: ["9000000000000000000", "98000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [3, 14],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Let the hunger feel restless, something beyond words, beyond reason. The light isn’t just consuming—it’s searching, insatiable in a way that suggests it will never be full. Keep the tone raw, the imagery tactile, like something crackling at the edges of perception, just waiting to devour more.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Let the hunger feel restless, something beyond words, beyond reason. The light isn’t just consuming—it’s searching, insatiable in a way that suggests it will never be full. Keep the tone raw, the imagery tactile, like something crackling at the edges of perception, just waiting to devour more.",
          },
        ],
      },
      {
        metadata: "ipfs://QmTz9mEQVEum6tvRK5pApVBU1zFVs8nkLNohh2qbwRnA13",
        amount: 31,
        prices: ["19000000000000000000", "155000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [6, 12, 27, 33],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a sense of inevitability—like the world itself had been waiting for this moment, the ground simply giving in to a secret long held. Let the fissure feel alive, its grin both inviting and merciless. Keep the descent disorienting, a scream swallowed by something far older and deeper than fear itself.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a sense of inevitability—like the world itself had been waiting for this moment, the ground simply giving in to a secret long held. Let the fissure feel alive, its grin both inviting and merciless. Keep the descent disorienting, a scream swallowed by something far older and deeper than fear itself.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a sense of inevitability—like the world itself had been waiting for this moment, the ground simply giving in to a secret long held. Let the fissure feel alive, its grin both inviting and merciless. Keep the descent disorienting, a scream swallowed by something far older and deeper than fear itself.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a sense of inevitability—like the world itself had been waiting for this moment, the ground simply giving in to a secret long held. Let the fissure feel alive, its grin both inviting and merciless. Keep the descent disorienting, a scream swallowed by something far older and deeper than fear itself.",
          },
        ],
      },
      {
        metadata: "ipfs://QmQinDa5uNHsDXnqLbPwAdBWrnEbEd7x43Km1M6CN51Tpd",
        amount: 100,
        prices: ["16000000000000000000", "134000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [9, 18, 25],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Lean into the surreal, where reality bends just enough to let something unsettling slip through. Let the puddle feel like more than just water—an observer, a quiet conspirator. The shadow isn’t menacing; it simply exists, aware in a way it shouldn’t be. Keep the dialogue sharp yet eerie, as if the words are folding in on themselves.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Lean into the surreal, where reality bends just enough to let something unsettling slip through. Let the puddle feel like more than just water—an observer, a quiet conspirator. The shadow isn’t menacing; it simply exists, aware in a way it shouldn’t be. Keep the dialogue sharp yet eerie, as if the words are folding in on themselves.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Lean into the surreal, where reality bends just enough to let something unsettling slip through. Let the puddle feel like more than just water—an observer, a quiet conspirator. The shadow isn’t menacing; it simply exists, aware in a way it shouldn’t be. Keep the dialogue sharp yet eerie, as if the words are folding in on themselves.",
          },
        ],
      },
    ],
    [
      {
        metadata: "ipfs://QmeZbnNme5ihmYyoGKnz8CJm13A4htkKuAKUTaPvJCbSiS",
        amount: 2,
        prices: ["12000000000000000000", "102000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [],
        workers: [],
      },
      {
        metadata: "ipfs://QmfU6DQnvBsxg3d6q3TE2XVrWHEV3a1R8Xc7bciiUPSp2H",
        amount: 20,
        prices: ["8000000000000000000", "86000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [2, 13, 30],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Escreva em português com um ritmo quase musical, deixando a cena vibrar com movimento e compulsão. A repetição deve criar uma sensação hipnótica, como se o ato de descascar fosse um ritual impossível de interromper. Deixe a linguagem sensorial, cítrica, pegajosa, com um leve toque de absurdo.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Escreva em português com um ritmo quase musical, deixando a cena vibrar com movimento e compulsão. A repetição deve criar uma sensação hipnótica, como se o ato de descascar fosse um ritual impossível de interromper. Deixe a linguagem sensorial, cítrica, pegajosa, com um leve toque de absurdo.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Escreva em português com um ritmo quase musical, deixando a cena vibrar com movimento e compulsão. A repetição deve criar uma sensação hipnótica, como se o ato de descascar fosse um ritual impossível de interromper. Deixe a linguagem sensorial, cítrica, pegajosa, com um leve toque de absurdo.",
          },
        ],
      },
      {
        metadata: "ipfs://QmNjxiuR759jrqr5eRYkxkrdU3QsoFynUezWywASh6Cw9X",
        amount: 13,
        prices: ["11000000000000000000", "96000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [5, 17, 29, 34],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Escreva com um tom melancólico e ligeiramente resignado, como se a cidade tivesse uma vontade própria, conduzindo o narrador sem que ele pudesse resistir. A sensação deve ser de algo perdido, mas não totalmente compreendido. Deixe o espaço entre as palavras sugerir mais do que explicam, como se a cidade sussurrasse um jogo sem regras definidas.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Escreva com um tom melancólico e ligeiramente resignado, como se a cidade tivesse uma vontade própria, conduzindo o narrador sem que ele pudesse resistir. A sensação deve ser de algo perdido, mas não totalmente compreendido. Deixe o espaço entre as palavras sugerir mais do que explicam, como se a cidade sussurrasse um jogo sem regras definidas.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Escreva com um tom melancólico e ligeiramente resignado, como se a cidade tivesse uma vontade própria, conduzindo o narrador sem que ele pudesse resistir. A sensação deve ser de algo perdido, mas não totalmente compreendido. Deixe o espaço entre as palavras sugerir mais do que explicam, como se a cidade sussurrasse um jogo sem regras definidas.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Escreva com um tom melancólico e ligeiramente resignado, como se a cidade tivesse uma vontade própria, conduzindo o narrador sem que ele pudesse resistir. A sensação deve ser de algo perdido, mas não totalmente compreendido. Deixe o espaço entre as palavras sugerir mais do que explicam, como se a cidade sussurrasse um jogo sem regras definidas.",
          },
        ],
      },
    ],
    [
      {
        metadata: "ipfs://QmVkYZzZkoagCRvLjF9yc4bw2vH9fWxYUQPrAFbS1Bro1C",
        amount: 2,
        prices: ["14000000000000000000", "118000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [],
        workers: [],
      },
      {
        metadata: "ipfs://QmZm2TyptnJwMSKDm4zLpfBMEKRahm73UQ96cGeoLZb65r",
        amount: 2,
        prices: ["14000000000000000000", "118000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [],
        workers: [],
      },
      {
        metadata: "ipfs://QmT5Vbdiph3nF41AC4ukZaapMekykyThYsaBvguWwLNgG4",
        amount: 10,
        prices: ["17000000000000000000", "143000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [4, 19],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Let the language reflect balance—both aspiration and rootedness, a drive that acknowledges where it came from. Keep the tone steady, assured, almost meditative. There’s no need for grandeur; the strength here is quiet, unwavering, and fully aware of its own foundation.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Let the language reflect balance—both aspiration and rootedness, a drive that acknowledges where it came from. Keep the tone steady, assured, almost meditative. There’s no need for grandeur; the strength here is quiet, unwavering, and fully aware of its own foundation.",
          },
        ],
      },
      {
        metadata: "ipfs://QmaYQc8YBpGWGwKYkHZMvb4pBxb6GPpJF6kXJCrbNWP1Xd",
        amount: 10,
        prices: ["17000000000000000000", "143000000000000000000000"],
        tokens: [MONA, BONSAI],
        agentIds: [6, 15, 22],
        workers: [
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a quiet reverence, letting each word carry weight. The garments aren’t just fabric—they tell a story, worn with intent, stitched with survival. Keep the tone poetic yet grounded, honoring the resilience without romanticizing the struggle. Let the whispers linger, soft but unyielding.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a quiet reverence, letting each word carry weight. The garments aren’t just fabric—they tell a story, worn with intent, stitched with survival. Keep the tone poetic yet grounded, honoring the resilience without romanticizing the struggle. Let the whispers linger, soft but unyielding.",
          },
          {
            leadFrequency: 1,
            publishFrequency: 1,
            remixFrequency: 1,
            mintFrequency: 1,
            remix: true,
            publish: false,
            lead: false,
            mint: true,
            instructions:
              "Write with a quiet reverence, letting each word carry weight. The garments aren’t just fabric—they tell a story, worn with intent, stitched with survival. Keep the tone poetic yet grounded, honoring the resilience without romanticizing the struggle. Let the whispers linger, soft but unyielding.",
          },
        ],
      },
    ],
  ];

  if ((details.length != artists.length) != drops.length) {
    console.log("invalid lengths");

    return;
  }

  for (let i = 0; i < details.length; i++) {
    let dropId = 0;
    const wallet = new ethers.Wallet(artists[i], provider);

    const cmContract = new ethers.Contract(
      collectionManagerAddress,
      collectionAbi,
      wallet
    );

    for (let j = 0; j < details[i].length; j++) {
      await cmContract.create(
        {
          tokens: details[i][j].tokens,
          prices: details[i][j].prices,
          agentIds: details[i][j].agentIds,
          metadata: details[i][j].metadata,
          collectionType: 0,
          amount: details[i][j].amount,
          fulfillerId: 0,
          remixId: 0,
          remixable: true,
          forArtist: ZERO_ADDRESS,
        },
        details[i][j].workers,
        drops[i],
        dropId
      );
    }

    dropId = i + 1;

    console.log("now doing drop ", dropId);
  }
})();
