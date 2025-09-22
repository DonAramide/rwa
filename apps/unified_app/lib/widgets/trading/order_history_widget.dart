import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order.dart';
import '../../providers/trading_provider.dart';

class OrderHistoryWidget extends ConsumerStatefulWidget {
  final String assetId;

  const OrderHistoryWidget({
    super.key,
    required this.assetId,
  });

  @override
  ConsumerState<OrderHistoryWidget> createState() => _OrderHistoryWidgetState();
}

class _OrderHistoryWidgetState extends ConsumerState<OrderHistoryWidget> {
  OrderStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tradingProvider.notifier).loadUserOrders(widget.assetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tradingState = ref.watch(tradingProvider);
    final allOrders = tradingState.userOrders[widget.assetId] ?? [];

    final filteredOrders = _filterStatus == null
        ? allOrders
        : allOrders.where((order) => order.status == _filterStatus).toList();

    return Card(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Status Filter
                    DropdownButton<OrderStatus?>(
                      value: _filterStatus,
                      hint: const Text('All'),
                      items: [
                        const DropdownMenuItem<OrderStatus?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...OrderStatus.values.map((status) {
                          return DropdownMenuItem<OrderStatus?>(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterStatus = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        ref.read(tradingProvider.notifier).loadUserOrders(widget.assetId);
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (filteredOrders.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _filterStatus == null
                          ? 'No orders yet'
                          : 'No ${_filterStatus!.displayName.toLowerCase()} orders',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Orders List
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderTile(order);
                  },
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTile(Order order) {
    final isBuy = order.side == OrderSide.buy;
    final sideColor = isBuy ? Colors.green : Colors.red;
    final statusColor = _getStatusColor(order.status);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: sideColor.withOpacity(0.1),
        child: Icon(
          isBuy ? Icons.trending_up : Icons.trending_down,
          color: sideColor,
        ),
      ),
      title: Row(
        children: [
          Text(
            '${order.side.displayName} ${order.quantity} shares',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              order.status.displayName,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Text('${order.type.displayName} • \$${order.price.toStringAsFixed(2)}'),
              if (order.isPartiallyFilled || order.isFullyFilled) ...[
                Text(' • Filled: ${order.filledQuantity!.toStringAsFixed(1)}'),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(order.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${order.totalValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (order.status == OrderStatus.pending) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: () => _cancelOrder(order),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else if (order.isPartiallyFilled || order.isFullyFilled) ...[
            const SizedBox(height: 4),
            Text(
              '${((order.filledQuantity! / order.quantity) * 100).toStringAsFixed(0)}% filled',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      onTap: () => _showOrderDetails(order),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.partiallyFilled:
        return Colors.blue;
      case OrderStatus.filled:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.grey;
      case OrderStatus.expired:
        return Colors.purple;
      case OrderStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _cancelOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel this ${order.side.displayName.toLowerCase()} order for ${order.quantity} shares at \$${order.price.toStringAsFixed(2)}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(tradingProvider.notifier).cancelOrder(order.id, widget.assetId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel order: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', '${order.type.displayName} ${order.side.displayName}'),
            _buildDetailRow('Quantity', '${order.quantity} shares'),
            _buildDetailRow('Price', '\$${order.price.toStringAsFixed(2)}'),
            _buildDetailRow('Total Value', '\$${order.totalValue.toStringAsFixed(2)}'),
            if (order.filledQuantity != null) ...[
              _buildDetailRow('Filled', '${order.filledQuantity!} shares'),
              _buildDetailRow('Filled Value', '\$${order.filledValue.toStringAsFixed(2)}'),
            ],
            _buildDetailRow('Status', order.status.displayName),
            _buildDetailRow('Created', order.createdAt.toString().substring(0, 19)),
            if (order.updatedAt != null)
              _buildDetailRow('Updated', order.updatedAt.toString().substring(0, 19)),
            if (order.expiresAt != null)
              _buildDetailRow('Expires', order.expiresAt.toString().substring(0, 19)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}