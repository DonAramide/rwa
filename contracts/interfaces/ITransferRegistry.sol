// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITransferRegistry {
    // --- Events ---
    event Whitelisted(address indexed account, bool allowed);
    event JurisdictionSet(address indexed account, bytes32 code);
    event LockupSet(uint256 indexed assetId, address indexed account, uint256 untilTimestamp);

    // --- Admin ---
    function setWhitelist(address account, bool allowed) external;
    function setJurisdiction(address account, bytes32 code) external;
    function setLockup(uint256 assetId, address account, uint256 untilTimestamp) external;

    // --- Views ---
    function isWhitelisted(address account) external view returns (bool);
    function jurisdictionOf(address account) external view returns (bytes32);
    function lockupOf(uint256 assetId, address account) external view returns (uint256);
}





































