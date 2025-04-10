use std::sync::LazyLock;

pub static AGENTS: &'static str = "0x424Fa11D84e5674809Fd0112eBa4f86d6C4ed2aD";
pub static ACCESS_CONTROLS: &'static str = "0x4F276081A4AC2d50eEE2aA6c78a3C4C06AAE9562";
pub static COLLECTION_MANAGER: &'static str = "0xBa53Fd19053fceFc91D091A02c71AbDcD79d856f";
pub static MARKET: &'static str = "0x6c7a9d566F6c2a9829B940b7571A220c70817c1a";
pub static REMIX_FEED: &'static str = "0x";
pub static ZERO_ADDRESS: &'static str = "0x0000000000000000000000000000000000000000";
pub static WGHO: &'static str = "0x6bDc36E20D267Ff0dd6097799f82e78907105e2F";
pub static BONSAI: &'static str = "0xB0588f9A9cADe7CD5f194a5fe77AcD6A58250f82";
pub static MODELS: &[&str] = &[
    "flux-dev-uncensored",
    "lustify-sdxl",
    "fluently-xl",
    "pony-realism",
];

pub static AGENT_INTERFACE_URL: &'static str = "https://triplea.agentmeme.xyz";
pub static VENICE_API: &'static str = "https://api.venice.ai/api/v1/";
pub static LENS_API: &'static str = "https://api.lens.xyz/graphql";
pub static LENS_RPC_URL: &'static str = "https://rpc.lens.xyz";
pub static TRIPLEA_URI: &str = "https://gateway-arbitrum.network.thegraph.com/api/";
pub static INFURA_GATEWAY: &'static str = "https://thedial.infura-ipfs.io/";
pub static LENS_CHAIN_ID: LazyLock<u64> = LazyLock::new(|| 232);
pub static ARTISTS: &[&str] = &[
    "0xae2d4A8191B55E9feA86934dc4FbC89eEE22efB6",
    "0x8860B76fEBC66092809B490A96E65BAD71c3Ac65",
    "0x1a13EE92680Cc847e27a6bF66303491d2b9AEcE7",
    "0xe3e76B32a1F66996d3Cb64D5599E5e6387D8C883",
    "0x03F034B0dF65887EAEEAe851fa668E72cC708581",
    "0xe5E949FBEdD829beD5e9283da4d50325D8F0F5a6",
    "0xCb30574340d013F8A8aeC29f828a12b7D53641bD",
    "0x9C9F99589111d181a7C58AfA6a53E469a187F663",
    "0x26E3F8d2065a9BFDDdfFBA7fddEA0d7eb0eCFF6f",
    "0x2dc0992cE7078b105eed1DFfce80db712eDA9792",
];
pub static STYLE_PRESETS: &[&str] = &[
    "Analog Film",
    "Line Art",
    "Neon Punk",
    "Pixel Art",
    "Texture",
    "Abstract",
    "Graffiti",
    "Pointillism",
    "Pop Art",
    "Psychedelic",
    "Renaissance",
    "Surrealist",
    "Retro Arcade",
    "Retro Game",
    "Street Fighter",
    "Legend of Zelda",
    "Gothic",
    "Grunge",
    "Horror",
    "Minimalist",
    "Monochrome",
    "Nautical",
    "Collage",
    "Kirigami",
    "Film Noir",
    "HDR",
    "Long Exposure",
    "Neon Noir",
    "Silhouette",
    "Tilt-Shift",
];
pub static SAMPLE_PROMPT:&'static str = "A surreal, liminal retro anime line art scene of a (pixel art:1.3) inspired (illustration:1.3) depicting the (interior view:1.3) of modern NYC MTA subway doors, The doors are composed of sleek brushed silver metallic panels with smooth ridges, featuring two rounded rectangular glass windows framed with black rubber trims, Below each window, blue rectangular stickers display a green circular 'yes' symbol on the left and bold white horizontal text on a single line reading 'I <3 Web3' in a clean sans-serif font, underneath a solid white line above the text, striking scratch-graffiti tags are etched roughly into the glass windows, and small marker-style graffiti tags adorn the metallic panels below the stickers. The perspective is symmetrical and straight-on, capturing the gritty urban aesthetic with realistic grime, wear, and imperfections. The background includes muted orange, yellow, and beige seating and metallic poles, illuminated by soft, cool white subway lighting. The illustration blends sharp, clean details with pixel-art-inspired textures, creating a retro-modern urban aesthetic.";
pub static NEGATIVE_PROMPT:&'static str = "(worst quality, low quality), (bad face), (deformed eyes), (bad eyes), ((extra hands)), extra fingers, too many fingers, fused fingers, bad arm, distorted arm, extra arms, fused arms, extra legs, missing leg, disembodied leg, extra nipples, detached arm, liquid hand, inverted hand, disembodied limb, oversized head, extra body, extra navel, (hair between eyes), twins, doubles";
pub static NEGATIVE_PROMPT_IMAGE:&'static str = "terrible quality, text, logo, signature,  amateur, b&w, duplicate, mutilated, extra fingers, mutated hands, deformed, cloned face, bad anatomy,  malformed limbs, missing arms, missing legs, extra arms, extra legs, mutated hands, fused fingers, too many fingers, tripod, tube, tiling, extra limbs, extra legs, cross-eye, out of frame";
pub static INPUT_IRL_FASHION: &[&str] = &[
    "QmUMwVnHKx73RcSMoVFcKQGb3aeErWvb67i9mA2sX2jehk",
    "QmZJwkav1ELzpiedvQqjex7VsBH1Y4ops5UEadeQXnHXAB",
    "QmSpbXasjgYGjWTkSxAZmyqj4Ht8x43jdsv9H6AHNJZ9Vy",
    "QmXu3fbBesEGjDqp9qaQ3Z31amkzyky51vXwtrzi4NPTUu",
    "QmaEVf4G1DosANrgMk2TV9uWKuW4fxfYhoFQpGDcCMU8TY",
    "QmWiG1U7GnLQxet2v75e6W4MucRU2F2g3ZBdVY2NZnSAUk",
    "QmTqngJsrp4X1npb6q1FTyvPAeG3Hskym69EsirAVDPiao",
    "QmVZDZMF173c7CmoxHT2AWk5fWpSJv8JCPGV58TP3Av66d",
    "QmVtR7TuoXVYfNFfLhGwkkV6G7bLmu3Wyg9k2PF7n8a8Td",
    "QmZKcmScm6y7CNgh2y1KGdyR4JsME9vqd4eGetHR8QunRD",
    "QmTa17X6X8T5AjM3NJW6DeAD6z3FK5nqfWste3uVMJvWGr",
    "QmcTMfyieV3eJrCqMHyxVwmugQ8nC8Vjb4xwdTRH13zzMy",
    "QmTsZkzYvyMpPXc2kqtUwdaPHZfsjrcW6yUGrNMDHs87B9",
    "QmY3r6wxmXaJCYTCqguiWZftJfSb8hp2V19B3LAyodVKZ9",
    "QmQaPMCwu7fXojLLL7iDmtCmhCKJqPTp946g8ZQN47s939",
    "QmPrXRvb3nZDHt3c8AF8LSuFQktbXYGGcjpFX7kGfaJ77a",
];
