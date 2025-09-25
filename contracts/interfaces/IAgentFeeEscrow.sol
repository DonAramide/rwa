// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAgentFeeEscrow {
    // --- Events ---
    event EscrowCreated(uint256 indexed jobId, address indexed payer, address indexed agent, uint256 amount);
    event Released(uint256 indexed jobId, address indexed agent, uint256 amount, uint256 platformFee);
    event Refunded(uint256 indexed jobId, address indexed payer, uint256 amount);

    // --- Admin Config ---
    function setPlatformFeeBps(uint16 bps) external;
    function setFeeRecipient(address recipient) external;

    // --- Escrow ---
    function createEscrow(uint256 jobId, address agent, uint256 amount) external payable;
    function release(uint256 jobId) external;
    function refund(uint256 jobId) external;

    // --- Views ---
    function escrowOf(uint256 jobId) external view returns (address payer, address agent, uint256 amount, bool released, bool refunded);
}





































