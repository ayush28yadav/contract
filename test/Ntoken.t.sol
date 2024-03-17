// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "../src/Ntoken.sol";


contract NtokenTest {
    Ntoken public token;
    address public owner;
    address public recipient;
    address public spender;

    function beforeEach() public {
        token = new Ntoken();
        owner = address(this);
        recipient = address(0x1);
        spender = address(0x2);
    }

    function testInitialSupply() public {
        uint256 expectedSupply = 1000000 * 10 ** 18;
        Assert.equal(token.totalSupply(), expectedSupply, "Initial supply should be 1,000,000 tokens");
        Assert.equal(token.balanceOf(owner), expectedSupply, "Owner should have the total supply");
    }

    function testTransfer() public {
        uint256 transferAmount = 100;
        uint256 senderBalanceBefore = token.balanceOf(owner);
        uint256 recipientBalanceBefore = token.balanceOf(recipient);

        bool success = token.transfer(recipient, transferAmount);

        Assert.isTrue(success, "Transfer should succeed");
        Assert.equal(token.balanceOf(owner), senderBalanceBefore - transferAmount, "Sender balance should be reduced");
        Assert.equal(token.balanceOf(recipient), recipientBalanceBefore + transferAmount, "Recipient balance should be increased");
    }

    function testTransferFail() public {
        uint256 transferAmount = token.totalSupply() + 1;
        bool success = token.transfer(recipient, transferAmount);

        Assert.isFalse(success, "Transfer should fail for insufficient balance");
    }

    function testApproveAndTransferFrom() public {
        uint256 approveAmount = 100;
        uint256 transferAmount = 50;

        bool success = token.approve(spender, approveAmount);
        Assert.isTrue(success, "Approval should succeed");

        success = token.transferFrom(owner, recipient, transferAmount);
        Assert.isTrue(success, "TransferFrom should succeed");

        Assert.equal(token.balanceOf(owner), token.totalSupply() - transferAmount, "Sender balance should be reduced");
        Assert.equal(token.balanceOf(recipient), transferAmount, "Recipient balance should be increased");
        Assert.equal(token.allowance(owner, spender), approveAmount - transferAmount, "Allowance should be decreased");
    }

    function testTransferFromFail() public {
        uint256 transferAmount = 100;

        bool success = token.transferFrom(owner, recipient, transferAmount);

        Assert.isFalse(success, "TransferFrom should fail for insufficient allowance");
    }
}