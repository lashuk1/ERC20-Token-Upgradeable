// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./MyToken.sol";

/// @title MyToken Version 2
/// @notice Adds version tracking to MyToken

contract MyTokenV2 is MyToken {
    function version() public pure returns (string memory) {
        return "v2";
    }
}
