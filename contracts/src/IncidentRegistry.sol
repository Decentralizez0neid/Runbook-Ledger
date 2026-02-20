// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract IncidentRegistry {
    struct Incident {
        bytes32 policyId;
        bytes32 evidenceHash;
        uint64 observedAt;
        uint8 severity;
        uint8 actionMask;
        address recorder;
    }

    event IncidentRecorded(
        bytes32 indexed incidentId,
        bytes32 indexed policyId,
        bytes32 evidenceHash,
        uint64 observedAt,
        uint8 severity,
        uint8 actionMask,
        address indexed recorder
    );

    error AlreadyRecorded(bytes32 incidentId);
    error Unauthorized(address caller);
    error VaultAlreadySet();

    address public safeguardVault; // set once

    mapping(bytes32 => Incident) public incidents;

    function setSafeguardVault(address _vault) external {
        if (safeguardVault != address(0)) revert VaultAlreadySet();
        safeguardVault = _vault;
    }

    function recordIncident(
        bytes32 incidentId,
        bytes32 policyId,
        bytes32 evidenceHash,
        uint64 observedAt,
        uint8 severity,
        uint8 actionMask
    ) external {
        if (msg.sender != safeguardVault) revert Unauthorized(msg.sender);
        if (incidents[incidentId].recorder != address(0)) revert AlreadyRecorded(incidentId);

        incidents[incidentId] = Incident({
            policyId: policyId,
            evidenceHash: evidenceHash,
            observedAt: observedAt,
            severity: severity,
            actionMask: actionMask,
            recorder: msg.sender
        });

        emit IncidentRecorded(
            incidentId,
            policyId,
            evidenceHash,
            observedAt,
            severity,
            actionMask,
            msg.sender
        );
    }
}
