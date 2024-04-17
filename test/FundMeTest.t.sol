// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // From forge-std, Creates a user address
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // Cheatcode
        vm.deal(USER, STARTING_BALANCE);
    }

    function testOwnerIsMsgSender() public view {
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionAccuracy() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testMinDollarIsFive() public view {
        assertEq(fundMe.MIN_USD(), 5e18);
    }

    function testNotEnoughEth() public {
        // Cheatcode
        vm.expectRevert(); // Next TX/non-vm cheatcode is expected to revert/fail
        fundMe.fund(); // 0 ETH is sent
    }

    function testFundedDataStructureUpdates() public {
        // Cheatcode
        vm.startPrank(USER); // Next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        // Each test resets, so funder is always at 0
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Tells you how much gas is left in the TX call, built in to solidity
        // uint256 gasStart = gasleft();
        // Simulate with gas price
        // vm.txGasPrice(GAS_PRICE); // Sets the gas price for the rest of the TX
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //Built in to solidity
        // console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testCheaperWithdrawWithMultipleFunders() public funded {
        // uint160 when using numbers to generate addresses
        uint160 numberOfFunders = 10;
        // Start with index 1 because 0 may revert
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // forge-std, vm.prank and vm.deal together
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        // uint160 when using numbers to generate addresses
        uint160 numberOfFunders = 10;
        // Start with index 1 because 0 may revert
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // forge-std, vm.prank and vm.deal together
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundMe.getOwner().balance
        );
    }
}
