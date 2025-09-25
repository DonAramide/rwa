// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMarketplace {
    struct Order {
        uint256 id;
        address owner;
        uint256 assetId;
        bool isBuy; // true=buy, false=sell
        uint256 qty;
        uint256 price; // price per token in smallest units
        uint256 filled;
        bool active;
    }

    // --- Events ---
    event OrderPosted(uint256 indexed id, address indexed owner, uint256 indexed assetId, bool isBuy, uint256 qty, uint256 price);
    event OrderCancelled(uint256 indexed id, address indexed owner);
    event OrderMatched(uint256 indexed buyId, uint256 indexed sellId, uint256 qty, uint256 price);

    // --- Orders ---
    function postOrder(uint256 assetId, bool isBuy, uint256 qty, uint256 price) external returns (uint256 orderId);
    function cancelOrder(uint256 orderId) external;
    function matchOrders(uint256 buyOrderId, uint256 sellOrderId, uint256 qty, uint256 price) external;

    // --- Views ---
    function getOrder(uint256 orderId) external view returns (Order memory);
}





































