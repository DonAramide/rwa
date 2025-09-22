import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/asset.dart';
import '../../models/order.dart';
import '../../providers/trading_provider.dart';
import '../../widgets/trading/order_form.dart';
import '../../widgets/trading/order_book_widget.dart';
import '../../widgets/trading/order_history_widget.dart';
import '../../widgets/trading/price_chart_widget.dart';
import '../../widgets/trading/trading_error_widget.dart';

class TradingScreen extends ConsumerStatefulWidget {
  final Asset asset;

  const TradingScreen({super.key, required this.asset});

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _retryLastOperation(TradingError error) {
    switch (error.type) {
      case TradingErrorType.network:
      case TradingErrorType.timeout:
        // Retry loading order book data
        ref.read(tradingProvider.notifier).loadOrderBook(widget.asset.id.toString());
        ref.read(tradingProvider.notifier).loadMarketData(widget.asset.id.toString());
        ref.read(tradingProvider.notifier).loadUserOrders(widget.asset.id.toString());
        break;
      case TradingErrorType.serverError:
        // Retry loading market data
        ref.read(tradingProvider.notifier).loadMarketData(widget.asset.id.toString());
        break;
      default:
        // For other errors, just reload order book
        ref.read(tradingProvider.notifier).loadOrderBook(widget.asset.id.toString());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tradingState = ref.watch(tradingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trade ${widget.asset.title}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Trade'),
            Tab(icon: Icon(Icons.show_chart), text: 'Chart'),
            Tab(icon: Icon(Icons.history), text: 'Orders'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Trading Error Banner
          if (tradingState.error != null)
            TradingErrorBanner(
              error: tradingState.error!,
              onRetry: tradingState.error!.isRetryable
                  ? () {
                      ref.read(tradingProvider.notifier).clearError();
                      // Retry the last operation based on error type
                      _retryLastOperation(tradingState.error!);
                    }
                  : null,
              onDismiss: () {
                ref.read(tradingProvider.notifier).clearError();
              },
            ),

          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Trading Tab
                _buildTradingTab(),

                // Chart Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: PriceChartWidget(assetId: widget.asset.id.toString()),
                ),

                // Orders Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: OrderHistoryWidget(assetId: widget.asset.id.toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Asset Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.asset.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.asset.type} • ${widget.asset.status}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.asset.nav != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'NAV',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${widget.asset.nav!.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (widget.asset.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.asset.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Desktop Layout: Side by side
          if (MediaQuery.of(context).size.width > 900) ...[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column - Order Form and Order Book
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        OrderForm(
                          asset: widget.asset,
                          onOrderPlaced: () {
                            // Refresh data when order is placed
                          },
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: OrderBookWidget(
                            assetId: widget.asset.id.toString(),
                            onPriceSelected: (price) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Price \$${price.toStringAsFixed(2)} selected'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right Column - Chart and Recent Orders
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        PriceChartWidget(assetId: widget.asset.id.toString()),
                        const SizedBox(height: 16),
                        Expanded(
                          child: OrderHistoryWidget(assetId: widget.asset.id.toString()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Mobile Layout: Stacked
            OrderForm(
              asset: widget.asset,
              onOrderPlaced: () {
                // Refresh data when order is placed
              },
            ),
            const SizedBox(height: 16),

            // Quick Actions Row - More responsive
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 350;
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(1),
                        icon: const Icon(Icons.show_chart, size: 18),
                        label: Text(
                          isNarrow ? 'Chart' : 'View Chart',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: isNarrow ? 8 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(2),
                        icon: const Icon(Icons.history, size: 18),
                        label: Text(
                          isNarrow ? 'Orders' : 'My Orders',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: isNarrow ? 8 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            OrderBookWidget(
              assetId: widget.asset.id.toString(),
              onPriceSelected: (price) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Price \$${price.toStringAsFixed(2)} selected'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}