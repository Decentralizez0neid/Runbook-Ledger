// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/IncidentRegistry.sol";
import "../src/SafeguardVault.sol";

contract DeploySepolia is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        // NOTE: trustedForwarder sementara isi address deployer dulu.
        // Nanti setelah tahu forwarder address dari CRE, kamu bisa set via setTrustedForwarder().
        vm.startBroadcast(pk);

        IncidentRegistry registry = new IncidentRegistry();

        SafeguardVault vault = new SafeguardVault(
            address(registry),
            msg.sender // trustedForwarder sementara = deployer (untuk testing manual)
        );

        registry.setSafeguardVault(address(vault));

        vm.stopBroadcast();

        console2.log("IncidentRegistry:", address(registry));
        console2.log("SafeguardVault:", address(vault));
    }
}
