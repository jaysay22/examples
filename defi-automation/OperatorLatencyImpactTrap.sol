// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Operator-Latency-Impact Trap (Drosera-compatible)
/// @notice Detects excessive operator response latency and emits severity payload.
/// @dev Uses mock test values and encodes results as bytes for Drosera runner.
contract OperatorLatencyImpactTrap {
    uint256 constant LATENCY_THRESHOLD = 60; // 60 seconds test value

    /// @notice Called each run to gather data
    /// @dev Should be 'view' and return ABI-encoded bytes.
    function collect() external view returns (bytes memory) {
        // Encode simulated latency reading
        uint256 mockLatency = block.timestamp % 120; // fake test data
        return abi.encode(mockLatency);
    }

    /// @notice Decides whether to respond
    /// @dev Must be pure and take array of encoded collect() results.
    /// @param history Array of collected samples (latest last)
    /// @return triggered True if latency exceeds threshold
    /// @return payload Encoded bytes (reason + severity)
    function shouldRespond(bytes[] calldata history)
        external
        pure
        returns (bool triggered, bytes memory payload)
    {
        if (history.length == 0) return (false, "");

        // Decode the latest latency reading
        uint256 latestLatency = abi.decode(history[history.length - 1], (uint256));

        // Trigger if latency exceeds threshold
        if (latestLatency > LATENCY_THRESHOLD) {
            // Severity = 1 (latency breach)
            payload = abi.encode(
                "LATENCY_THRESHOLD_EXCEEDED",
                latestLatency,
                LATENCY_THRESHOLD,
                uint8(1)
            );
            return (true, payload);
        }

        return (false, "");
    }
}