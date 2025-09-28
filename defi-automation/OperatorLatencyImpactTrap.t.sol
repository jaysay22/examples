// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./OperatorLatencyImpactTrap.sol";

contract OperatorLatencyImpactTrapTest is Test {
    OperatorLatencyImpactTrap trap;

    function setUp() public {
        trap = new OperatorLatencyImpactTrap();
    }

    function testCollectAndLatencyCheck() public {
        // Collect a trap emission
        trap.collect(1, "0x1234");

        // Should not respond immediately (latency = 0)
        bool resp1 = trap.shouldRespond(1);
        assertEq(resp1, false);

        // Move time forward to simulate operator delay
        vm.warp(block.timestamp + 100);

        // Now should respond (latency > threshold)
        bool resp2 = trap.shouldRespond(1);
        assertEq(resp2, true);
    }

    function testActivateAndDeactivateSafeMode() public {
        trap.collect(1, "0x1234");
        vm.warp(block.timestamp + 100);

        // Safe mode should activate
        trap.activateSafeMode(1);
        bool active = trap.isSafeMode(1);
        assertEq(active, true);

        // Safe mode should deactivate
        trap.deactivateSafeMode(1);
        bool inactive = trap.isSafeMode(1);
        assertEq(inactive, false);
    }
}
