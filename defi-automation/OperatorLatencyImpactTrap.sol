// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Operator-Latency-Impact Trap
/// @notice A test Drosera trap that tracks operator response latency
///         and escalates if response delays exceed thresholds.
/// @dev Uses test values for demonstration only.
contract OperatorLatencyImpactTrap {
    // Configurable threshold (in seconds)
    uint256 public latencyThreshold;

    // Store last trap emission timestamp
    uint256 public lastTrapTimestamp;

    // Store last operator response timestamp
    uint256 public lastResponseTimestamp;

    // Safety fallback flag
    bool public safeModeActive;

    // Event emitted when latency exceeds threshold
    event LatencyExceeded(uint256 latency, uint256 threshold);

    // Event emitted when safe mode is enabled
    event SafeModeEnabled();

    constructor(uint256 _latencyThreshold) {
        latencyThreshold = _latencyThreshold;
        safeModeActive = false;
    }

    /// @notice Called to simulate trap "collect" step
    /// @dev Marks a new trap emission (like Drosera’s oracle check)
    function collect() external {
        lastTrapTimestamp = block.timestamp;
    }

    /// @notice Checks if operator should respond
    /// @return true if latency exceeds threshold
    function shouldRespond() external view returns (bool) {
        if (lastTrapTimestamp == 0) return false;
        uint256 latency = block.timestamp - lastTrapTimestamp;
        return latency > latencyThreshold;
    }

    /// @notice Operator calls this when responding to trap
    function operatorRespond() external {
        lastResponseTimestamp = block.timestamp;

        uint256 latency = lastResponseTimestamp - lastTrapTimestamp;
        if (latency > latencyThreshold) {
            emit LatencyExceeded(latency, latencyThreshold);
            _enableSafeMode();
        }
    }

    /// @dev Internal safe-mode trigger
    function _enableSafeMode() internal {
        safeModeActive = true;
        emit SafeModeEnabled();
    }
}
