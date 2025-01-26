use std::sync::LazyLock;

pub static AGENTS: &'static str = "0xcDE1629239f0050ba8501D2bCc552F17128e4388";
pub static ACCESS_CONTROLS: &'static str = "0x317ed314b5Acf661b40Fb4A568530D1DF3af00fd";
pub static COLLECTION_MANAGER: &'static str = "";
pub static REMIX_FEED: &'static str = "0x";
pub static MONA: &'static str = "";
pub static GRASS: &'static str = "";
pub static BONSAI: &'static str = "";
pub static MODELS: &[&str] = &[
    "Model1",
    "Model2",
    "Model3",
];
pub static AGENT_INTERFACE_URL: &'static str = "https://triplea.agentmeme.xyz";
pub static COMFY_INTERFACE_URL: &'static str = "";
pub static LENS_API: &'static str = "https://api.testnet.lens.dev/graphql";
pub static LENS_RPC_URL: &'static str = "https://rpc.testnet.lens.dev";
pub static TRIPLEA_URI: &str = "https://api.studio.thegraph.com/query/37770/triplea/version/latest";
pub static INFURA_GATEWAY: &'static str = "https://thedial.infura-ipfs.io/";
pub static LENS_CHAIN_ID: LazyLock<u64> = LazyLock::new(|| 37111);
