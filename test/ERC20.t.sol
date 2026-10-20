// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/ERC20.sol";

contract ERC20ContractTest is Test {
    KonarCoin c;

    function setUp() public {
        c = new KonarCoin(address(this));
    }

    function testMint() public {
        uint value = 10;
        c.mint(address(this), value);

        assert(c.balanceOf(address(this)) == value);
    }

    function test_RevertWhen_UnauthorizedMint() public {
        uint value = 10;
        vm.startPrank(address(0x1));
        vm.expectRevert();
        c.mint(address(this), value);
        vm.stopPrank();
    }
}
