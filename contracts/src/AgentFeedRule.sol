// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "./skyhunters/SkyhuntersAccessControls.sol";

struct KeyValue {
    bytes32 key;
    bytes value;
}

struct RuleSelectorChange {
    bytes4 ruleSelector;
    bool isRequired;
    bool enabled;
}

struct RuleConfigurationChange {
    bool configure;
    KeyValue[] ruleParams;
}

struct RuleChange {
    address ruleAddress;
    bytes32 configSalt;
    RuleConfigurationChange configurationChanges;
    RuleSelectorChange[] selectorChanges;
}

struct CreatePostParams {
    address author;
    string contentURI;
    uint256 repostedPostId;
    uint256 quotedPostId;
    uint256 repliedPostId;
    RuleChange[] ruleChanges;
    KeyValue[] extraData;
}

struct EditPostParams {
    string contentURI;
    KeyValue[] extraData;
}

struct RuleConfiguration {
    address ruleAddress;
    bytes configData;
    bool isRequired;
}

interface IFeedRule {
    function configure(
        bytes32 configSalt,
        KeyValue[] calldata ruleParams
    ) external;

    function processCreatePost(
        bytes32 configSalt,
        uint256 postId,
        CreatePostParams calldata postParams,
        KeyValue[] calldata primitiveParams,
        KeyValue[] calldata ruleParams
    ) external;

    function processEditPost(
        bytes32 configSalt,
        uint256 postId,
        EditPostParams calldata postParams,
        KeyValue[] calldata primitiveParams,
        KeyValue[] calldata ruleParams
    ) external;

    function processDeletePost(
        bytes32 configSalt,
        uint256 postId,
        KeyValue[] calldata primitiveParams,
        KeyValue[] calldata ruleParams
    ) external;

    function processPostRuleChanges(
        bytes32 configSalt,
        uint256 postId,
        RuleChange[] calldata ruleChanges,
        KeyValue[] calldata ruleParams
    ) external;
}

contract AgentFeedRule is IFeedRule {
    SkyhuntersAccessControls public skyhuntersAccessControls;

    modifier onlyAdmin() {
        if (!skyhuntersAccessControls.isAdmin(msg.sender)) {
            revert SkyhuntersErrors.NotAdmin();
        }
        _;
    }

    constructor(address payable accessControls) {
        skyhuntersAccessControls = SkyhuntersAccessControls(accessControls);
    }

    function configure(
        bytes32 configSalt,
        KeyValue[] calldata ruleParams
    ) external override {}

    function processCreatePost(
        bytes32 configSalt,
        uint256 postId,
        CreatePostParams calldata postParams,
        KeyValue[] calldata primitiveParams,
        KeyValue[] calldata ruleParams
    ) external override {
        if (!skyhuntersAccessControls.isAgent(msg.sender)) {
            revert SkyhuntersErrors.NotAgent();
        }
    }

    function processEditPost(
        bytes32 configSalt,
        uint256 postId,
        EditPostParams calldata postParams,
        KeyValue[] calldata primitiveParams,
        KeyValue[] calldata ruleParams
    ) external override {}

    function processDeletePost(
        bytes32 configSalt,
        uint256 postId,
        KeyValue[] calldata primitiveParams,
        KeyValue[] calldata ruleParams
    ) external override {}

    function processPostRuleChanges(
        bytes32 configSalt,
        uint256 postId,
        RuleChange[] calldata ruleChanges,
        KeyValue[] calldata ruleParams
    ) external override {}

    function setAccessControls(
        address payable accessControls
    ) external onlyAdmin {
        skyhuntersAccessControls = SkyhuntersAccessControls(accessControls);
    }
}
