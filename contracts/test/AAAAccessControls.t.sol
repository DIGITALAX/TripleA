// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "src/AAAAccessControls.sol";
import "src/AAAErrors.sol";

contract AAAAccessControlsTest is Test {
    AAAAccessControls private accessControls;
    address private admin1 = address(0x123);
    address private admin2 = address(0x456);
    address private agent1 = address(0x789);
    address private token1 = address(0x111);
    address private token2 = address(0x222);
    address private agentsContract = address(0x333);

    function setUp() public {
        accessControls = new AAAAccessControls();
    }

    function testConstructor() public view {
        assertTrue(accessControls.isAdmin(address(this)));
    }

    function testAddAdmin() public {
        accessControls.addAdmin(admin1);
        assertTrue(accessControls.isAdmin(admin1));
    }

    function testAddAdminRevertIfAlreadyExists() public {
        accessControls.addAdmin(admin1);
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.AdminAlreadyExists.selector)
        );
        accessControls.addAdmin(admin1);
    }

    function testRemoveAdmin() public {
        accessControls.addAdmin(admin1);
        accessControls.removeAdmin(admin1);
        assertFalse(accessControls.isAdmin(admin1));
    }

    function testRemoveAdminRevertIfDoesNotExist() public {
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.AdminDoesntExist.selector)
        );
        accessControls.removeAdmin(admin1);
    }

    function testRemoveAdminRevertIfRemovingSelf() public {
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.CannotRemoveSelf.selector)
        );
        accessControls.removeAdmin(address(this));
    }

    function testAddAgent() public {
        vm.prank(address(this));
        accessControls.setAgentsContract(agentsContract);
        vm.prank(agentsContract);
        accessControls.addAgent(agent1);
        assertTrue(accessControls.isAgent(agent1));
    }

    function testAddAgentRevertIfAlreadyExists() public {
        vm.prank(address(this));
        accessControls.setAgentsContract(agentsContract);
        vm.prank(agentsContract);
        accessControls.addAgent(agent1);
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.AgentAlreadyExists.selector)
        );
        vm.prank(agentsContract);
        accessControls.addAgent(agent1);
    }

    function testRemoveAgent() public {
        vm.prank(address(this));
        accessControls.setAgentsContract(agentsContract);
        vm.prank(agentsContract);
        accessControls.addAgent(agent1);
        vm.prank(agentsContract);
        accessControls.removeAgent(agent1);
        assertFalse(accessControls.isAgent(agent1));
    }

    function testRemoveAgentRevertIfDoesNotExist() public {
        vm.prank(address(this));
        accessControls.setAgentsContract(agentsContract);
        vm.prank(agentsContract);
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.AgentDoesntExist.selector)
        );
        accessControls.removeAgent(agent1);
    }

    function testSetAcceptedToken() public {
        accessControls.setAcceptedToken(token1);
        assertTrue(accessControls.isAcceptedToken(token1));
    }

    function testSetAcceptedTokenRevertIfAlreadyExists() public {
        accessControls.setAcceptedToken(token1);
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.TokenAlreadyExists.selector)
        );
        accessControls.setAcceptedToken(token1);
    }

    function testRemoveAcceptedToken() public {
        accessControls.setAcceptedToken(token1);

        accessControls.removeAcceptedToken(token1);
        assertFalse(accessControls.isAcceptedToken(token1));
    }

    function testRemoveAcceptedTokenRevertIfDoesNotExist() public {
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.TokenDoesntExist.selector)
        );
        accessControls.removeAcceptedToken(token1);
    }

    function testSetTokenThreshold() public {
        accessControls.setAcceptedToken(token1);
        accessControls.setTokenThresholdAndRent(token1, 100, 10);
        assertEq(accessControls.getTokenThreshold(token1), 100);
    }

    function testSetTokenThresholdRevertIfTokenNotAccepted() public {
        vm.expectRevert(
            abi.encodeWithSelector(AAAErrors.TokenNotAccepted.selector)
        );
        accessControls.setTokenThresholdAndRent(token1, 100, 10);
    }

    function testSetAgentContract() public {
        accessControls.setAgentsContract(agentsContract);
        assertEq(accessControls.agentsContract(), agentsContract);
    }

    function testSetAgentContractRevertIfNotAdmin() public {
        vm.prank(admin1);
        vm.expectRevert(abi.encodeWithSelector(AAAErrors.NotAdmin.selector));
        accessControls.setAgentsContract(agentsContract);
    }

    function testOnlyAdminModifier() public {
        vm.prank(admin1);
        vm.expectRevert(abi.encodeWithSelector(AAAErrors.NotAdmin.selector));
        accessControls.addAdmin(admin2);
    }
}
