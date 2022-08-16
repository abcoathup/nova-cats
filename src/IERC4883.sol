// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC4883 {
    function renderTokenById(uint256 id) external view returns (string memory);
}
