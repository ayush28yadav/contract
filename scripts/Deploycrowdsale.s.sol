// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "..contract/src/Ntoken.sol";
import "..contract/src/Crowdsale.sol";

contract CrowdsaleDeploy is Script {
    function run() external returns (Crowdsale) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the Ntoken contract
        Ntoken token = new Ntoken();

        // Get the constructor parameters from the environment variables
        uint256 rate = vm.envUint("TOKEN_RATE");
        uint256 startTime = block.timestamp + vm.envUint("START_DELAY_SECONDS");
        uint256 endTime = startTime + vm.envUint("SALE_DURATION_SECONDS");
        uint256 cliffDuration = vm.envUint("CLIFF_DURATION_SECONDS");
        uint256 vestingDuration = vm.envUint("VESTING_DURATION_SECONDS");

        // Deploy the Crowdsale contract
        Crowdsale crowdsale = new Crowdsale(
            token,
            payable(vm.envAddress("WALLET_ADDRESS")),
            rate,
            startTime,
            endTime,
            cliffDuration,
            vestingDuration
        );

        vm.stopBroadcast();
        return crowdsale;
    }
}


//create you env file for private key, startTIme, endTIme and other variables to be passed in the constructor