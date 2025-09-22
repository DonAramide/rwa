import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trading_provider.dart';

class PriceChartWidget extends ConsumerStatefulWidget {
  final String assetId;

  const PriceChartWidget({
    super.key,
    required this.assetId,
  });

  @override
  ConsumerState<PriceChartWidget> createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends ConsumerState<PriceChartWidget> {
  String _selectedTimeframe = '24H';
  final List<String> _timeframes = ['1H', '24H', '7D', '30D', '1Y'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tradingProvider.notifier).loadMarketData(widget.assetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tradingState = ref.watch(tradingProvider);
    final marketData = tradingState.marketData[widget.assetId];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Chart',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Timeframe selector
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: _timeframes.map((timeframe) {
                          final isSelected = timeframe == _selectedTimeframe;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTimeframe = timeframe;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).primaryColor : null,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                timeframe,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        ref.read(tradingProvider.notifier).loadMarketData(widget.assetId);
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Summary
            if (marketData != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${marketData.currentPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                              '${marketData.change >= 0 ? '+' : ''}\$${marketData.change.toStringAsFixed(2)} (${marketData.changePercentage >= 0 ? '+' : ''}${marketData.changePercentage.toStringAsFixed(2)}%)',
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
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Chart Area (simplified visualization)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: CustomPaint(
                  painter: SimpleChartPainter(
                    marketData: marketData,
                    color: marketData.isUp ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Market Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Open', '\$${marketData.openPrice.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('High', '\$${marketData.highPrice.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Low', '\$${marketData.lowPrice.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Volume', '${(marketData.volume / 1000).toStringAsFixed(1)}K'),
                  ),
                ],
              ),
            ] else ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading chart data...'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleChartPainter extends CustomPainter {
  final dynamic marketData;
  final Color color;

  SimpleChartPainter({
    required this.marketData,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Generate some sample data points for a simple chart
    final points = <Offset>[];
    final basePrice = marketData.openPrice;
    final priceRange = marketData.highPrice - marketData.lowPrice;

    for (int i = 0; i <= 50; i++) {
      final x = (i / 50) * size.width;

      // Generate some random-ish price movement
      final progress = i / 50;
      final randomFactor = (i * 17) % 100 / 100.0; // Pseudo-random
      final trend = (marketData.currentPrice - basePrice) * progress;
      final noise = (randomFactor - 0.5) * priceRange * 0.3;
      final price = basePrice + trend + noise;

      // Normalize to chart height
      final normalizedPrice = (price - marketData.lowPrice) / priceRange;
      final y = size.height - (normalizedPrice * size.height * 0.8) - (size.height * 0.1);

      points.add(Offset(x, y));
    }

    // Draw filled area under the line
    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(points.first.dx, size.height);
      for (final point in points) {
        path.lineTo(point.dx, point.dy);
      }
      path.lineTo(points.last.dx, size.height);
      path.close();
      canvas.drawPath(path, fillPaint);
    }

    // Draw the price line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical grid lines
    for (int i = 0; i <= 6; i++) {
      final x = (i / 6) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}