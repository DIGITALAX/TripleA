use std::sync::LazyLock;

pub static AGENTS: &'static str = "0x0c66DF3847Eae30797a62C2d2C28cf30B7af01Ce";
pub static COIN_GECKO: &'static str =  "https://api.geckoterminal.com/api/v2";
pub static ACCESS_CONTROLS: &'static str = "0x0064d596558Ca3Dae49B7919AEe821330203C2A6";
pub static COLLECTION_MANAGER: &'static str = "0x4ed83239189a803885cc888A6e470d1a13F7Ff4b";
pub static REMIX_FEED: &'static str = "0x";
pub static MONA: &'static str = "0x72ab7C7f3F6FF123D08692b0be196149d4951a41";
pub static GRASS: &'static str = "0xeee5a340Cdc9c179Db25dea45AcfD5FE8d4d3eB8";
pub static BONSAI: &'static str = "0x15B58c74A0Ef6D0A593340721055223f38F5721E";
pub static MODELS: &[&str] = &[
    "flux-dev-uncensored",
    "lustify-sdxl",
    "fluently-xl",
    "pony-realism"
];
pub static AGENT_INTERFACE_URL: &'static str = "https://triplea.agentmeme.xyz";
pub static VENICE_API:&'static str = "https://api.venice.ai/api/v1/";
pub static LENS_API: &'static str = "https://api.testnet.lens.dev/graphql";
pub static LENS_RPC_URL: &'static str = "https://rpc.testnet.lens.dev";
pub static TRIPLEA_URI: &str = "https://api.studio.thegraph.com/query/37770/triplea/version/latest";
pub static INFURA_GATEWAY: &'static str = "https://thedial.infura-ipfs.io/";
pub static LENS_CHAIN_ID: LazyLock<u64> = LazyLock::new(|| 37111);
pub static STYLE_PRESETS: &[&str] = &[
    "3D Model",
    "Analog Film",
    "Anime",
    "Cinematic",
    "Comic Book",
    "Digital Art",
    "Enhance",
    "Fantasy Art",
    "Line Art",
    "Neon Punk",
    "Origami",
    "Photographic",
    "Pixel Art",
    "Texture",
    "Advertising",
    "Food Photography",
    "Abstract",
    "Cubist",
    "Graffiti",
    "Hyperrealism",
    "Impressionist",
    "Pointillism",
    "Pop Art",
    "Psychedelic",
    "Renaissance",
    "Surrealist",
    "Typography",
    "Retro Arcade",
    "Retro Game",
    "RPG Fantasy Game",
    "Strategy Game",
    "Street Fighter",
    "Legend of Zelda",
    "Disco",
    "Dreamscape",
    "Dystopian",
    "Fairy Tale",
    "Gothic",
    "Grunge",
    "Horror",
    "Minimalist",
    "Monochrome",
    "Nautical",
    "Space",
    "Stained Glass",
    "Techwear Fashion",
    "Tribal",
    "Zentangle",
    "Collage",
    "Flat Papercut",
    "Kirigami",
    "Paper Mache",
    "Paper Quilling",
    "Papercut Collage",
    "Papercut Shadow Box",
    "Stacked Papercut",
    "Thick Layered Papercut",
    "Film Noir",
    "HDR",
    "Long Exposure",
    "Neon Noir",
    "Silhouette",
    "Tilt-Shift"
  ];
  pub static SAMPLE_PROMPT:&'static str = "A surreal, liminal retro anime line art scene of a (pixel art:1.3) inspired (illustration:1.3) depicting the (interior view:1.3) of modern NYC MTA subway doors, The doors are composed of sleek brushed silver metallic panels with smooth ridges, featuring two rounded rectangular glass windows framed with black rubber trims, Below each window, blue rectangular stickers display a green circular 'yes' symbol on the left and bold white horizontal text on a single line reading 'I <3 Web3' in a clean sans-serif font, underneath a solid white line above the text, striking scratch-graffiti tags are etched roughly into the glass windows, and small marker-style graffiti tags adorn the metallic panels below the stickers. The perspective is symmetrical and straight-on, capturing the gritty urban aesthetic with realistic grime, wear, and imperfections. The background includes muted orange, yellow, and beige seating and metallic poles, illuminated by soft, cool white subway lighting. The illustration blends sharp, clean details with pixel-art-inspired textures, creating a retro-modern urban aesthetic.";
  pub static NEGATIVE_PROMPT:&'static str = "(worst quality, low quality), (bad face), (deformed eyes), (bad eyes), ((extra hands)), extra fingers, too many fingers, fused fingers, bad arm, distorted arm, extra arms, fused arms, extra legs, missing leg, disembodied leg, extra nipples, detached arm, liquid hand, inverted hand, disembodied limb, oversized head, extra body, extra navel, (hair between eyes), twins, doubles";
  