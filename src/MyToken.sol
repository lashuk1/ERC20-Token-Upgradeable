// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Upgradeable ERC20 Token with Mint, Burn, Freeze, and Withdraw Roles (EIP-7201 compatible)
contract MyToken is
    Initializable,
    ERC20PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    // --- Roles ---
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant BALANCE_LOCKER_ROLE =
        keccak256("BALANCE_LOCKER_ROLE");
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    // --- Storage struct for EIP-7201 compatibility ---
    struct MyTokenStorage {
        mapping(address => uint256) frozenBalances;
    }

    // Storage slot per EIP-7201 (precomputed keccak256("MyToken.storage") - 1)
    bytes32 private constant _STORAGE_SLOT =
        0x5c1c7e0c3b9f5b9f5b9f5b9f5b9f5b9f5b9f5b9f5b9f5b9f5b9f5b9f5b9f5b9f;

    function _getStorage() private pure returns (MyTokenStorage storage s) {
        assembly {
            s.slot := _STORAGE_SLOT
        }
    }

    // --- Initializer ---
    function initialize(
        string memory name,
        string memory symbol
    ) public initializer {
        __ERC20_init(name, symbol);
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // --- Minting ---
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // --- Burning ---
    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    // --- Balance Freezing ---
    function freeze(
        address user,
        uint256 amount
    ) external onlyRole(BALANCE_LOCKER_ROLE) {
        require(user != address(0), "Invalid address");
        require(amount <= balanceOf(user), "Cannot freeze more than balance");

        MyTokenStorage storage s = _getStorage();
        s.frozenBalances[user] = amount;
    }

    function unfreeze(address user) external onlyRole(BALANCE_LOCKER_ROLE) {
        MyTokenStorage storage s = _getStorage();
        s.frozenBalances[user] = 0;
    }

    function frozenBalanceOf(address user) public view returns (uint256) {
        return _getStorage().frozenBalances[user];
    }

    // --- Transfer Hook ---
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (from != address(0) && !hasRole(WITHDRAWER_ROLE, msg.sender)) {
            uint256 available = balanceOf(from) -
                _getStorage().frozenBalances[from];
            require(
                value <= available,
                "Transfer exceeds available (non-frozen) balance"
            );
        }
        return super._update(from, to, value);
    }

    // --- Withdraw frozen balance by authorized account ---
    function withdrawFrozenBalance(
        address from,
        address to,
        uint256 amount
    ) external onlyRole(WITHDRAWER_ROLE) {
        require(from != address(0) && to != address(0), "Invalid address");

        MyTokenStorage storage s = _getStorage();
        require(s.frozenBalances[from] >= amount, "Not enough frozen balance");

        s.frozenBalances[from] -= amount;
        _transfer(from, to, amount);
    }

    // --- Upgrade Authorization ---
    function _authorizeUpgrade(address newImplementation) internal override {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
    }
}
