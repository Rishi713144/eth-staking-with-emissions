// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IKonarToken {
    function mint(address to, uint256 amount) external;
}

contract StakingWithEmissions {
    mapping(address => uint) stakes;
    uint public totalStake;
    uint256 public constant REWARD_PER_SEC_PER_ETH = 1;
    
    IKonarToken public KonarToken;


    struct UserInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
        uint256 lastUpdate;
    }

    mapping(address => UserInfo) public userInfo;

    constructor(IKonarToken _token) {
        KonarToken = _token;
    }

    function _updateRewards(address _user) internal {
        UserInfo storage user = userInfo[_user];

        if (user.lastUpdate == 0) {
            user.lastUpdate = block.timestamp;
            return;
        }

        uint256 timeDiff = block.timestamp - user.lastUpdate;
        if (timeDiff == 0) {
            return;
        }

        uint256 additionalReward = (user.stakedAmount * timeDiff * REWARD_PER_SEC_PER_ETH);

        user.rewardDebt += additionalReward;
        user.lastUpdate = block.timestamp;
    }


    function stake(uint256 _amount) external payable {
        require(_amount > 0, "Cannot stake 0");
        require(msg.value == _amount, "ETH amount mismatch");

        _updateRewards(msg.sender);

        userInfo[msg.sender].stakedAmount += _amount;
        totalStake += _amount;
    }

    function unstake(uint _amount) public {
       require(_amount > 0, "Cannot unstake 0");
        UserInfo storage user = userInfo[msg.sender];
        require(user.stakedAmount >= _amount, "Not enough staked");

        _updateRewards(msg.sender);
        user.stakedAmount -= _amount;
        totalStake -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function claimEmissions() public {
        _updateRewards(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        KonarToken.mint(msg.sender, user.rewardDebt);
        user.rewardDebt = 0;
    }

    function getRewards() public view returns (uint) {
        uint256 timeDiff = block.timestamp - userInfo[msg.sender].lastUpdate;
        if (timeDiff == 0) {
            return userInfo[msg.sender].rewardDebt;
        }

        return (userInfo[msg.sender].stakedAmount * timeDiff * REWARD_PER_SEC_PER_ETH) + userInfo[msg.sender].rewardDebt;
    }

}