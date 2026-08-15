// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Test.sol";

contract KonarCoin is ERC20 {
    address stakingContract;

    constructor(address _stakingContract) ERC20("KonarCoin", "KNRC") {
        stakingContract = _stakingContract;
    }

    modifier onlyContract() {
        require(msg.sender == stakingContract);
        _;
    }

    function mint(address to, uint256 amount) public onlyContract {
        _mint(to, amount);
    }

    function updateContract(address newContract) public onlyContract {
        stakingContract = newContract;
    }
}
