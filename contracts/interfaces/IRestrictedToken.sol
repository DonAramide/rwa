// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRestrictedToken {
    // --- Events ---
    event TokenMinted(address indexed to, uint256 amount);
    event TokenBurned(address indexed from, uint256 amount);
    event TransferRestricted(address indexed from, address indexed to, uint256 amount, bytes32 reason);

    // --- Views ---
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    // --- Core ERC20 ---
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    // --- Restricted Logic ---
    function restrictedTransfer(address from, address to, uint256 amount) external returns (bool);
    function canTransfer(address from, address to, uint256 amount) external view returns (bool, bytes32);

    // --- Admin ---
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function pause() external;
    function unpause() external;
}






































