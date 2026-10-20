// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/StakingWithEmissions.sol";
import "src/ERC20.sol";

contract StakingWithEmissionsTest is Test {
    StakingWithEmissions stakingContract;
    KonarCoin KonarCoinToken;

    function setUp() public {
        KonarCoinToken = new KonarCoin(address(this)); 
        stakingContract = new StakingWithEmissions(IKonarToken(address(KonarCoinToken)));
        KonarCoinToken.updateContract(address(stakingContract));
    }

    function testStake() public {
        uint value = 10 ether;
        stakingContract.stake{value: value}(value);

        assert(stakingContract.totalStake() == value);
    }

    function test_RevertWhen_UnstakingMoreThanStaked() public {
        uint value = 10 ether;
        stakingContract.stake{value: value}(value);
        vm.expectRevert("Not enough staked");
        stakingContract.unstake(value + 1 ether);
    }

    function testGetRewards() public {
        uint value = 1 ether;
        stakingContract.stake{value: value}(value);
        vm.warp(block.timestamp + 1);
        uint rewards = stakingContract.getRewards();

        assert(rewards == 1 ether);
    }

    function testComplexGetRewards() public {
        uint value = 1 ether;
        stakingContract.stake{value: value}(value);
        vm.warp(block.timestamp + 1);
        console.log(block.timestamp);
        stakingContract.stake{value: value}(value);
        vm.warp(block.timestamp + 1);
        uint rewards = stakingContract.getRewards();

        assert(rewards == 3 ether);
    }

    function testRedeemRewards() public {
        uint value = 1 ether;
        stakingContract.stake{value: value}(value);
        vm.warp(block.timestamp + 1);
        stakingContract.claimEmissions();
        console.log("balance of");
        console.log(KonarCoinToken.balanceOf(address(this)));

        assert(KonarCoinToken.balanceOf(address(this)) == 1 ether);
    }

   
}