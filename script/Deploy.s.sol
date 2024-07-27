// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Staking, UUPSUpgradeable} from "../src/Staking.sol";
import {Script} from "../forge-std/Script.sol";
import {Test} from "../forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

contract Deploy is Script {
    Staking stakingImp;
    Staking stakingProxy;
    function run() public {
        vm.createSelectFork(
            vm.rpcUrl(
                "https://eth-sepolia.g.alchemy.com/v2/KdgQDmf9ZbfZ2KIwLN5XB6Lz_bSgblZp"
            )
        );
        uint256 deployPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployPrivateKey);
        deployStake();
        printStake();
        // deployUpgradeStake()
        vm.stopBroadcast();
    }

    function deployStake() internal {
        stakingImp = new Staking();
        bytes memory data = abi.encodeCall(stakingImp.initialize, ());
        address staking = address(new ERC1967Proxy(address(stakingImp), data));
        stakingProxy = Staking(staking);
    }

    function printStake() public {
        console.log("stakingImp address", address(stakingImp));
        console.log("stakingProxy address", address(stakingProxy));
    }

    function testScript() public {
        run();
    }

    // To change the implementation
    // function deployUpgradeStake() internal {
    //     stakingProxy = Staking(0x66Fa8fb7BE4C19434D8481294856b965cb804a67);
    //     stakingImp = new Staking();
    //     bytes memory data = abi.encodeCall(stakingImp.initializeV2, ());
    //     UUPSUpgradeable(address(stakingProxy)).upgradeToAndCall(
    //         address(stakingImp),
    //         data
    //     );
    // }
}
