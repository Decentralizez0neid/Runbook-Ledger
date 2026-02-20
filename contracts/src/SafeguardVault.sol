// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Pausable} from "openzeppelin-contracts/contracts/utils/Pausable.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

interface IIncidentRegistry {
    function recordIncident(
        bytes32 incidentId,
        bytes32 policyId,
        bytes32 evidenceHash,
        uint64 observedAt,
        uint8 severity,
        uint8 actionMask
    ) external;
}

contract SafeguardVault is Pausable, Ownable {
    // actionMask bit flags
    uint8 internal constant ACTION_PAUSE = 1;              // 0b00000001
    uint8 internal constant ACTION_UNPAUSE = 2;            // 0b00000010
    uint8 internal constant ACTION_SET_MAX_WITHDRAW_BPS = 4; // 0b00000100

    struct GuardrailCommand {
        bytes32 incidentId;
        bytes32 policyId;
        uint64 observedAt;
        uint8 severity;
        uint8 actionMask;
        uint16 maxWithdrawBps;
        bytes32 evidenceHash;
    }

    event GuardrailExecuted(
        bytes32 indexed incidentId,
        bytes32 indexed policyId,
        uint8 severity,
        uint8 actionMask,
        uint16 maxWithdrawBps,
        bytes32 evidenceHash
    );

    event TrustedForwarderUpdated(address indexed oldForwarder, address indexed newForwarder);

    error NotTrustedForwarder(address caller);

    uint16 public maxWithdrawBps = 10_000; // 100% default
    bytes32 public lastIncidentId;

    address public trustedForwarder; // for CRE forwarder (can be updated for sim/prod)
    IIncidentRegistry public immutable registry;

    constructor(address _registry, address _trustedForwarder) {
        registry = IIncidentRegistry(_registry);
        trustedForwarder = _trustedForwarder;
    }

    // --- Admin override (optional but useful) ---
    function setTrustedForwarder(address newForwarder) external onlyOwner {
        emit TrustedForwarderUpdated(trustedForwarder, newForwarder);
        trustedForwarder = newForwarder;
    }

    function manualPause() external onlyOwner {
        _pause();
    }

    function manualUnpause() external onlyOwner {
        _unpause();
    }

    function setMaxWithdrawBps(uint16 newBps) external onlyOwner {
        require(newBps <= 10_000, "bps>100%");
        maxWithdrawBps = newBps;
    }

    // --- CRE entrypoint ---
    // Forwarder calls this method. We gate by trustedForwarder for safety.
    function onReport(bytes calldata /*metadata*/, bytes calldata report) external {
        if (msg.sender != trustedForwarder) revert NotTrustedForwarder(msg.sender);

        // report is EVM-encoded payload from CRE
        // In your workflow we encoded a dummy function call "guardrailCommand(...)".
        // We need to decode the arguments out of that calldata.
        GuardrailCommand memory cmd = _decodeCommand(report);

        // Idempotency (optional, but nice)
        lastIncidentId = cmd.incidentId;

        // Execute actions
        if ((cmd.actionMask & ACTION_PAUSE) != 0) {
            _pause();
        }
        if ((cmd.actionMask & ACTION_UNPAUSE) != 0) {
            _unpause();
        }
        if ((cmd.actionMask & ACTION_SET_MAX_WITHDRAW_BPS) != 0) {
            require(cmd.maxWithdrawBps <= 10_000, "bps>100%");
            maxWithdrawBps = cmd.maxWithdrawBps;
        }

        // Record to ledger
        registry.recordIncident(
            cmd.incidentId,
            cmd.policyId,
            cmd.evidenceHash,
            cmd.observedAt,
            cmd.severity,
            cmd.actionMask
        );

        emit GuardrailExecuted(
            cmd.incidentId,
            cmd.policyId,
            cmd.severity,
            cmd.actionMask,
            cmd.maxWithdrawBps,
            cmd.evidenceHash
        );
    }

    // Decode the report payload.
    // Your workflow encodes: encodeFunctionData({ name: "guardrailCommand", args: [...] })
    // That means report starts with 4-byte selector, followed by ABI-encoded args.
    function _decodeCommand(bytes calldata report) internal pure returns (GuardrailCommand memory cmd) {
        // skip 4 bytes selector
        bytes calldata data = report[4:];

        (
            bytes32 incidentId,
            bytes32 policyId,
            uint64 observedAt,
            uint8 severity,
            uint8 actionMask,
            uint16 maxWithdrawBps,
            bytes32 evidenceHash
        ) = abi.decode(data, (bytes32, bytes32, uint64, uint8, uint8, uint16, bytes32));

        cmd = GuardrailCommand({
            incidentId: incidentId,
            policyId: policyId,
            observedAt: observedAt,
            severity: severity,
            actionMask: actionMask,
            maxWithdrawBps: maxWithdrawBps,
            evidenceHash: evidenceHash
        });
    }
}
