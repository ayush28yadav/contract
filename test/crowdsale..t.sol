// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "../src/Crowdsale.sol";
import "../src/Ntoken.sol";

contract CrowdsaleTest {
    Ntoken public token;
    Crowdsale public crowdsale;
    address payable public wallet;
    address public owner;
    address public investor;

    function beforeEach() public {
        token = new Ntoken();
        wallet = payable(address(0x1));  //example address
        owner = address(this);
        investor = address(0x2);   //example address
        crowdsale = new Crowdsale(
            token,
            wallet,
            1000, // 1000 tokens per Ether
            block.timestamp + 1 days, // Start time
            block.timestamp + 30 days, // End time
            5 days, // Cliff duration
            20 days // Vesting duration
        );
    }

    function testBuyTokens() public {
        uint256 investmentAmount = 1 ether;
        uint256 expectedTokens = investmentAmount * crowdsale.rate();

        crowdsale.startSale();
        crowdsale.buyTokens{value: investmentAmount}();

        Assert.equal(token.balanceOf(investor), expectedTokens, "Tokens should be transferred to the buyer");
        Assert.equal(wallet.balance, investmentAmount, "Ether should be transferred to the wallet");
        Assert.equal(crowdsale.investedAmount(investor), investmentAmount, "Invested amount should be recorded");
        Assert.equal(crowdsale.PurchasedTokens(investor), expectedTokens, "Purchased tokens should be recorded");
    }

    function testBuyTokensFail() public {
        uint256 investmentAmount = 1 ether;

        vm.warp(crowdsale.endTime() + 1 days);
        crowdsale.startSale();
        (bool success, ) = address(crowdsale).call{value: investmentAmount}(abi.encodeWithSignature("buyTokens()"));

        Assert.isFalse(success, "Buying tokens should fail after the end time");
    }

    function testClaimTokens() public {
        uint256 investmentAmount = 1 ether;
        crowdsale.startSale();
        crowdsale.buyTokens{value: investmentAmount}();

        vm.warp(block.timestamp + 10 days); // Advance time to after cliff duration

        uint256 expectedVestedTokens = investmentAmount * crowdsale.rate() / 4; // 25% vested after 10 days

        crowdsale.claimTokens(expectedVestedTokens);

        Assert.equal(token.balanceOf(investor), expectedVestedTokens, "Vested tokens should be claimed");
        Assert.equal(crowdsale.claimedTokens(investor), expectedVestedTokens, "Claimed tokens should be recorded");
    }

    function testClaimTokensFail() public {
        uint256 investmentAmount = 1 ether;
        crowdsale.startSale();
        crowdsale.buyTokens{value: investmentAmount}();

        vm.warp(block.timestamp + 2 days); // Before cliff duration

        (bool success, ) = address(crowdsale).call(abi.encodeWithSignature("claimTokens(uint256)", crowdsale.PurchasedTokens(investor)));

        Assert.isFalse(success, "Claiming tokens should fail before cliff duration");
    }

    function testClaimTokensExceedVestedAmount() public {
        uint256 investmentAmount = 1 ether;
        crowdsale.startSale();
        crowdsale.buyTokens{value: investmentAmount}();

        vm.warp(block.timestamp + 10 days); // Advance time to after cliff duration

        uint256 vestedTokens = investmentAmount * crowdsale.rate() / 4; // 25% vested after 10 days
        uint256 excessTokens = vestedTokens + 1;

        (bool success, ) = address(crowdsale).call(abi.encodeWithSignature("claimTokens(uint256)", excessTokens));

        Assert.isFalse(success, "Claiming more than vested tokens should fail");
    }

    function testHaltAndResumeSale() public {
        crowdsale.startSale();
        crowdsale.haltSale();

        Assert.isFalse(crowdsale.saleActive(), "Sale should be halted");

        crowdsale.resumeSale();

        Assert.isTrue(crowdsale.saleActive(), "Sale should be resumed");
    }

    function testWithdrawEther() public {
        uint256 investmentAmount = 1 ether;
        crowdsale.startSale();
        crowdsale.buyTokens{value: investmentAmount}();

        uint256 walletBalanceBefore = wallet.balance;
        crowdsale.withdrawEther();
        uint256 walletBalanceAfter = wallet.balance;

        Assert.equal(walletBalanceAfter, walletBalanceBefore + investmentAmount, "Wallet should receive the collected Ether");
    }

    function testWithdrawEtherFail() public {
        (bool success, ) = address(crowdsale).call(abi.encodeWithSignature("withdrawEther()"));

        Assert.isFalse(success, "Non-wallet address should not be able to withdraw Ether");
    }

    function testTokensClaimed() public {
        uint256 investmentAmount = 1 ether;
        crowdsale.startSale();
        crowdsale.buyTokens{value: investmentAmount}();

        vm.warp(block.timestamp + 10 days); // Advance time to after cliff duration

        uint256 vestedTokens = investmentAmount * crowdsale.rate() / 4; // 25% vested after 10 days
        crowdsale.claimTokens(vestedTokens);

        Assert.isFalse(crowdsale.tokensClaimed(investor), "Tokens should not be fully claimed");

        vm.warp(block.timestamp + crowdsale.vestingDuration()); // Advance time to after vesting duration
        crowdsale.claimTokens(crowdsale.PurchasedTokens(investor) - vestedTokens);

        Assert.isTrue(crowdsale.tokensClaimed(investor), "All tokens should be claimed");
    }
}