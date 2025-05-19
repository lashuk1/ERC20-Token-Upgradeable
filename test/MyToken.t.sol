// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/MyTokenV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

interface IUpgradeable {
    function upgradeToAndCall(
        address newImplementation,
        bytes calldata data
    ) external;
}

contract MyTokenTest is Test {
    MyToken public token;
    address public proxyAddr;

    address public admin;
    address public minter;
    address public burner;
    address public user;

    function setUp() public {
        admin = address(this);
        minter = address(0x1);
        burner = address(0x2);
        user = address(0x3);

        MyToken implementation = new MyToken();

        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");

        proxyAddr = address(proxy);
        token = MyToken(proxyAddr);

        token.initialize("MyToken", "MTK");

        token.grantRole(token.DEFAULT_ADMIN_ROLE(), admin);
        token.grantRole(token.MINTER_ROLE(), minter);
        token.grantRole(token.BURNER_ROLE(), burner);

        assertTrue(
            token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin),
            "Admin does not have DEFAULT_ADMIN_ROLE"
        );
    }

    function testMintByMinter() public {
        vm.prank(minter);
        token.mint(user, 100);
        assertEq(token.balanceOf(user), 100);
        assertEq(token.totalSupply(), 100);
    }

    function testMintByUnauthorizedFails() public {
        vm.prank(user);
        vm.expectRevert();
        token.mint(user, 100);
    }

    function testBurnByBurner() public {
        vm.prank(minter);
        token.mint(user, 200);
        vm.prank(burner);
        token.burn(user, 50);
        assertEq(token.balanceOf(user), 150);
        assertEq(token.totalSupply(), 150);
    }

    function testBurnByUnauthorizedFails() public {
        vm.prank(minter);
        token.mint(user, 100);
        vm.prank(user);
        vm.expectRevert();
        token.burn(user, 10);
    }

    function testGrantAndRevokeRole() public {
        assertTrue(token.hasRole(token.MINTER_ROLE(), minter));
        token.revokeRole(token.MINTER_ROLE(), minter);
        assertFalse(token.hasRole(token.MINTER_ROLE(), minter));
    }

    function testUpgradeByAdmin() public {
        MyTokenV2 newImpl = new MyTokenV2();
        vm.prank(admin);
        IUpgradeable(proxyAddr).upgradeToAndCall(address(newImpl), bytes(""));

        MyTokenV2 upgraded = MyTokenV2(proxyAddr);
        assertEq(upgraded.version(), "v2");
    }

    function testUpgradeByUnauthorizedFails() public {
        MyTokenV2 newImpl = new MyTokenV2();
        vm.prank(user);
        vm.expectRevert();
        IUpgradeable(proxyAddr).upgradeToAndCall(address(newImpl), bytes(""));
    }
}
