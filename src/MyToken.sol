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

    /// @notice Initializes the ERC20 token and sets up roles and upgrade support
    /// @param name The name of the token (e.g., "MyToken")
    /// @param symbol The symbol of the token (e.g., "MTK")

    function initialize(
        string memory name,
        string memory symbol
    ) public initializer {
        __ERC20_init(name, symbol);
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Mints tokens to a specific address
    /// @dev Only callable by accounts with the MINTER_ROLE
    /// @param to The address to receive the tokens
    /// @param amount The number of tokens to mint

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice Burns tokens from a specific address
    /// @dev Only callable by accounts with the BURNER_ROLE
    /// @param from The address whose tokens will be burned
    /// @param amount The number of tokens to burn

    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    /// @dev Authorizes contract upgrades
    /// @param newImplementation The address of the new contract implementation

    function _authorizeUpgrade(address newImplementation) internal override {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
    }
}
