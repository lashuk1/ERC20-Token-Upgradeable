// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Upgradeable ERC20 Token with Mint and Burn Roles
/// @author Lasha Chitidze
/// @notice This contract allows minting and burning by specific roles and supports upgrades
/// @dev Inherits from ERC20Upgradeable, AccessControlUpgradeable, and UUPSUpgradeable

contract MyToken is
    Initializable,
    ERC20Upgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    function initialize(
        string memory name,
        string memory symbol
    ) public initializer {
        __ERC20_init(name, symbol);
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }
    function _authorizeUpgrade(address) internal override {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
    }
}
