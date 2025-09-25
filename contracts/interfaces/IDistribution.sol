// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDistribution {
    // --- Events ---
    event RevenueDeposited(uint256 indexed assetId, uint256 amount, address indexed depositor);
    event PayoutQueued(uint256 indexed assetId, bytes32 indexed periodId, uint256 netAmount);
    event PayoutClaimed(uint256 indexed assetId, address indexed holder, uint256 amount);

    // --- Admin ---
    function setFees(uint256 managementFeeBps, uint256 carryBps) external;

    // --- Revenue & Payouts ---
    function depositRevenue(uint256 assetId, uint256 amount) external payable;
    function queueBatch(uint256 assetId, bytes32 periodId) external;
    function claim(uint256 assetId, address holder) external returns (uint256);
    function claimFor(uint256 assetId, address[] calldata holders) external returns (uint256 total);

    // --- Views ---
    function pendingFor(uint256 assetId, address holder) external view returns (uint256);
}





































