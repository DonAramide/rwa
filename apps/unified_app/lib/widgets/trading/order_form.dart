import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order.dart';
import '../../models/asset.dart';
import '../../providers/trading_provider.dart';
import 'trading_error_widget.dart';

class OrderForm extends ConsumerStatefulWidget {
  final Asset asset;
  final OrderSide initialSide;
  final VoidCallback? onOrderPlaced;

  const OrderForm({
    super.key,
    required this.asset,
    this.initialSide = OrderSide.buy,
    this.onOrderPlaced,
  });

  @override
  ConsumerState<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends ConsumerState<OrderForm> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _stopPriceController = TextEditingController();

  OrderType _selectedType = OrderType.limit;
  OrderSide _selectedSide = OrderSide.buy;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedSide = widget.initialSide;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _selectedSide == OrderSide.buy ? 0 : 1,
    );

    _tabController.addListener(() {
      setState(() {
        _selectedSide = _tabController.index == 0 ? OrderSide.buy : OrderSide.sell;
        _error = null;
      });
    });

    // Load market data for price reference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tradingProvider.notifier).loadMarketData(widget.asset.id.toString());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _stopPriceController.dispose();
    super.dispose();
  }

  double get _quantity => double.tryParse(_quantityController.text) ?? 0.0;
  double get _price => double.tryParse(_priceController.text) ?? 0.0;
  double get _total => _quantity * _price;

  Future<void> _placeOrder() async {
    // Check if trading operation is already loading
    final tradingState = ref.read(tradingProvider);
    if (tradingState.isLoadingOperation('placeOrder')) return;

    // For market orders, we don't need to validate price
    if (_selectedType != OrderType.market && !_formKey.currentState!.validate()) {
      return;
    }

    // Basic UI validation for quantity
    if (_quantity <= 0) {
      setState(() {
        _error = 'Please enter a valid quantity greater than 0';
      });
      return;
    }

    // For limit orders, validate price is reasonable
    if ((_selectedType == OrderType.limit || _selectedType == OrderType.stopLimit) && _price <= 0) {
      setState(() {
        _error = 'Please enter a valid price greater than 0';
      });
      return;
    }

    // Show confirmation dialog first
    final confirmed = await _showOrderConfirmation();
    if (!confirmed) return;

    setState(() {
      _error = null; // Clear local error
    });

    try {
      await ref.read(tradingProvider.notifier).placeOrder(
        assetId: widget.asset.id.toString(),
        type: _selectedType,
        side: _selectedSide,
        quantity: _quantity,
        price: _price,
      );

      if (mounted) {
        // Add haptic feedback for successful order
        HapticFeedback.heavyImpact();
        await _showOrderSuccessDialog();
        _clearForm();
        widget.onOrderPlaced?.call();
      }
    } catch (e) {
      if (mounted) {
        // Add haptic feedback for error - TradingProvider handles the error display
        HapticFeedback.notificationFeedback(NotificationFeedbackType.error);
      }
    }
  }

  String _formatErrorMessage(String error) {
    // Format common error messages to be more user-friendly
    if (error.contains('insufficient')) {
      return 'Insufficient funds to complete this order';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Please check your connection and try again';
    } else if (error.contains('timeout')) {
      return 'Request timed out. Please try again';
    } else if (error.contains('invalid')) {
      return 'Invalid order parameters. Please check your inputs';
    } else if (error.contains('market closed')) {
      return 'Market is currently closed. Please try again during trading hours';
    } else {
      return 'Failed to place order. Please try again';
    }
  }

  Future<bool> _showOrderConfirmation() async {
    print('Showing order confirmation dialog');
    print('Asset: ${widget.asset.title}, Side: $_selectedSide, Quantity: $_quantity, Price: $_price');

    final estimatedTotal = _selectedType == OrderType.market ? 'Market Price' : '\$${_total.toStringAsFixed(2)}';

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _selectedSide == OrderSide.buy ? Icons.trending_up : Icons.trending_down,
              color: _selectedSide == OrderSide.buy ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text('Confirm ${_selectedSide.displayName} Order'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please confirm your order details:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildConfirmationRow('Asset', widget.asset.title),
            _buildConfirmationRow('Action', '${_selectedSide.displayName} ${_quantity.toStringAsFixed(2)} shares'),
            _buildConfirmationRow('Order Type', _selectedType.displayName),
            if (_selectedType != OrderType.market)
              _buildConfirmationRow('Price per Share', '\$${_price.toStringAsFixed(2)}'),
            _buildConfirmationRow('Estimated Total', estimatedTotal),
            if (_selectedType == OrderType.market) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Market orders execute immediately at current market price',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedSide == OrderSide.buy ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Place ${_selectedSide.displayName} Order'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showOrderSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Order Placed Successfully'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ${_selectedSide.displayName.toLowerCase()} order has been placed successfully!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('• ${_selectedSide.displayName} ${_quantity.toStringAsFixed(2)} shares'),
                  Text('• ${_selectedType.displayName} order'),
                  if (_selectedType != OrderType.market)
                    Text('• Price: \$${_price.toStringAsFixed(2)} per share'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Next steps:'),
            const SizedBox(height: 8),
            const Text('• Track your order in the Orders tab'),
            const Text('• You will be notified when your order is filled'),
            const Text('• Check your portfolio for updated holdings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View Orders'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Trading'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _quantityController.clear();
    _priceController.clear();
    _stopPriceController.clear();
    setState(() {
      _error = null;
    });
  }

  void _fillMarketPrice() {
    final marketData = ref.read(tradingProvider).marketData[widget.asset.id.toString()];
    if (marketData != null) {
      _priceController.text = marketData.currentPrice.toStringAsFixed(2);
    }
  }

  bool _isFormValid() {
    // Check if quantity is valid
    if (_quantity <= 0) return false;

    // For limit and stop limit orders, price is required
    if ((_selectedType == OrderType.limit || _selectedType == OrderType.stopLimit) && _price <= 0) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final tradingState = ref.watch(tradingProvider);
    final marketData = tradingState.marketData[widget.asset.id.toString()];
    final isPlaceOrderLoading = tradingState.isLoadingOperation('placeOrder');

    return Card(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9, // Responsive height
          maxWidth: MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            Text(
              'Place Order',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Market Data Summary
            if (marketData != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Price',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '\$${marketData.currentPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '24h Change',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Row(
                          children: [
                            Icon(
                              marketData.isUp ? Icons.arrow_upward :
                              marketData.isDown ? Icons.arrow_downward : Icons.remove,
                              size: 16,
                              color: marketData.isUp ? Colors.green :
                                     marketData.isDown ? Colors.red : Colors.grey,
                            ),
                            Text(
                              '${marketData.changePercentage >= 0 ? '+' : ''}${marketData.changePercentage.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: marketData.isUp ? Colors.green :
                                       marketData.isDown ? Colors.red : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Buy/Sell Tabs
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _selectedSide == OrderSide.buy ? Colors.green : Colors.red,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'BUY'),
                  Tab(text: 'SELL'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Order Type Selection
                  DropdownButtonFormField<OrderType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Order Type',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true, // This prevents overflow issues
                    items: OrderType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280), // Add width constraint
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                type.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                type.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quantity Input
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      suffixText: 'shares',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final quantity = double.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Please enter a valid quantity';
                      }
                      if (quantity > 10000) {
                        return 'Maximum quantity is 10,000';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Price Input (for limit orders)
                  if (_selectedType == OrderType.limit || _selectedType == OrderType.stopLimit) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price per Share',
                              prefixText: '\$',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_selectedType == OrderType.limit || _selectedType == OrderType.stopLimit) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Please enter a valid price';
                                }
                                if (price > 1000000) {
                                  return 'Price too high';
                                }
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _fillMarketPrice,
                          icon: const Icon(Icons.trending_up),
                          tooltip: 'Use Market Price',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stop Price Input (for stop orders)
                  if (_selectedType == OrderType.stopLoss || _selectedType == OrderType.stopLimit) ...[
                    TextFormField(
                      controller: _stopPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stop Price',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                        helperText: 'Order will trigger when price reaches this level',
                      ),
                      validator: (value) {
                        if (_selectedType == OrderType.stopLoss || _selectedType == OrderType.stopLimit) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stop price';
                          }
                          final stopPrice = double.tryParse(value);
                          if (stopPrice == null || stopPrice <= 0) {
                            return 'Please enter a valid stop price';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Order Summary
                  if (_quantity > 0 && (_selectedType == OrderType.market || (_selectedType != OrderType.market && _price > 0))) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedSide == OrderSide.buy
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedSide == OrderSide.buy
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quantity:'),
                              Text('${_quantity.toStringAsFixed(2)} shares'),
                            ],
                          ),
                          if (_selectedType != OrderType.market) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Price:'),
                                Text('\$${_price.toStringAsFixed(2)}'),
                              ],
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _selectedType == OrderType.market
                                    ? 'Market Price'
                                    : '\$${_total.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Error Message
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56, // Fixed height for consistency
                    child: ElevatedButton(
                      onPressed: (isPlaceOrderLoading || !_isFormValid()) ? null : () {
                        // Add haptic feedback for better UX
                        HapticFeedback.lightImpact();
                        _placeOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSide == OrderSide.buy
                            ? Colors.green
                            : Colors.red,
                        foregroundColor: Colors.white,
                        elevation: isPlaceOrderLoading ? 0 : 2,
                        shadowColor: (_selectedSide == OrderSide.buy
                            ? Colors.green
                            : Colors.red).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isPlaceOrderLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Placing ${_selectedSide.displayName} Order...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedSide == OrderSide.buy
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${_selectedSide.displayName} ${widget.asset.title}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}