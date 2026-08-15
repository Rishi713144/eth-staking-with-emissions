// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Contract.sol";

contract TestContract is Test {
    StakingContract c;

    receive() external payable {}

    fallback() external payable {}

    function setUp() public {
        c = new StakingContract();
    }

    function testStake() public {
        uint value = 10 ether;
        c.stake{value: value}(value);

        assert(c.totalStake() == value);
    }

    function test_RevertWhen_StakingWithoutEther() public {
        uint value = 10 ether;
        vm.expectRevert();
        c.stake(value);
    }

    function testUnstake() public {
        uint value = 10 ether;
        // vm.startPrank();
        // vm.deal(, value);
        console.log(address(this));
        console.log(address(c));
        c.stake{value: value}(value);
        c.unstake(value);

        assert(c.totalStake() == 0);
    }
}
