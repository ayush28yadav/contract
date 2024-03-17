// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "..contract/src/Ntoken.sol";

contract NtokenDeploy is Script {
    function run() external returns (Ntoken) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Ntoken token = new Ntoken();

        vm.stopBroadcast();
        return token;
    }
}

//create your .env file to pass the private key