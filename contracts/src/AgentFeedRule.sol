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
    function configure(bytes calldata data) external;

    function processCreatePost(
        uint256 postId,
        CreatePostParams calldata postParams,
        bytes calldata data
    ) external returns (bool);

    function processEditPost(
        uint256 postId,
        EditPostParams calldata editPostParams,
        bytes calldata data
    ) external returns (bool);

    function processPostRulesChanged(
        uint256 postId,
        RuleConfiguration[] calldata newPostRules,
        bytes calldata data
    ) external returns (bool);
}

contract AgentFeedRule is IFeedRule {
    SkyhuntersAccessControls public skyhuntersAccessControls;

    modifier onlyAdmin() {
        if (!skyhuntersAccessControls.isAdmin(msg.sender)) {
            revert SkyhuntersErrors.NotAdmin();
        }
        _;
    }

    function configure(bytes calldata data) external override {
        skyhuntersAccessControls = SkyhuntersAccessControls(
            abi.decode(data, (address))
        );
    }

    function processCreatePost(
        uint256 postId,
        CreatePostParams calldata postParams,
        bytes calldata data
    ) external override returns (bool) {
        if (!skyhuntersAccessControls.isAgent(msg.sender)) {
            revert SkyhuntersErrors.NotAgent();
        }
        return true;
    }

    function processEditPost(
        uint256 postId,
        EditPostParams calldata editPostParams,
        bytes calldata data
    ) external override returns (bool) {
        return false;
    }

    function processPostRulesChanged(
        uint256 postId,
        RuleConfiguration[] calldata newPostRules,
        bytes calldata data
    ) external override returns (bool) {
        return false;
    }

    function setAccessControls(
        address payable accessControls
    ) external onlyAdmin {
        skyhuntersAccessControls = SkyhuntersAccessControls(accessControls);
    }
}
