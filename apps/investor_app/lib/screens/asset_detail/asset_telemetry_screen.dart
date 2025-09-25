import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/asset_tracking_provider.dart';

class AssetTelemetryScreen extends ConsumerStatefulWidget {
  final String assetId;
  final String assetTitle;

  const AssetTelemetryScreen({
    super.key,
    required this.assetId,
    required this.assetTitle,
  });

  @override
  ConsumerState<AssetTelemetryScreen> createState() => _AssetTelemetryScreenState();
}

class _AssetTelemetryScreenState extends ConsumerState<AssetTelemetryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trackingNotifier = ref.read(assetTrackingProvider.notifier);
      trackingNotifier.startTracking();
      trackingNotifier.subscribeToAsset(widget.assetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final telemetryData = ref.watch(assetTelemetryProvider(widget.assetId));
    final priceUpdate = ref.watch(assetPriceUpdateProvider(widget.assetId));
    final isConnected = ref.watch(isTrackingConnectedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.assetTitle} - Live Data'),
        actions: [
          _ConnectionIndicator(isConnected: isConnected),
          IconButton(
            onPressed: () {
              ref.read(assetTrackingProvider.notifier).startTracking();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(telemetryData, priceUpdate),
    );
  }

  Widget _buildBody(List<AssetTelemetry> telemetryData, PriceUpdate? priceUpdate) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(assetTrackingProvider.notifier).subscribeToAsset(widget.assetId);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (priceUpdate != null) ...[
              _PriceUpdateCard(priceUpdate: priceUpdate),
              const SizedBox(height: 16),
            ],
            _buildTelemetrySection(telemetryData),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetrySection(List<AssetTelemetry> telemetryData) {
    if (telemetryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sensors,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Telemetry Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time sensor data will appear here when available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group telemetry data by metric type
    final groupedData = <String, List<AssetTelemetry>>{};
    for (final data in telemetryData) {
      groupedData.putIfAbsent(data.metric, () => []).add(data);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-time Sensors',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...groupedData.entries.map((entry) {
          return _TelemetryMetricCard(
            metric: entry.key,
            data: entry.value,
          );
        }),
      ],
    );
  }
}

class _ConnectionIndicator extends StatelessWidget {
  final bool isConnected;

  const _ConnectionIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Live' : 'Offline',
            style: TextStyle(
              color: isConnected ? Colors.green[700] : Colors.red[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceUpdateCard extends StatelessWidget {
  final PriceUpdate priceUpdate;

  const _PriceUpdateCard({required this.priceUpdate});

  @override
  Widget build(BuildContext context) {
    final isPositive = priceUpdate.changeAmount >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current NAV',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${priceUpdate.currentPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: isPositive ? Colors.green[700] : Colors.red[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}\$${priceUpdate.changeAmount.toStringAsFixed(2)} (${isPositive ? '+' : ''}${priceUpdate.changePercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: isPositive ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatTimestamp(priceUpdate.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _TelemetryMetricCard extends StatelessWidget {
  final String metric;
  final List<AssetTelemetry> data;

  const _TelemetryMetricCard({
    required this.metric,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final latestData = data.first;
    final previousData = data.length > 1 ? data[1] : null;

    final hasChange = previousData != null;
    final changeValue = hasChange ? latestData.value - previousData.value : 0.0;
    final isPositive = changeValue >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatMetricName(metric),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _MetricIcon(metric: metric),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${latestData.value.toStringAsFixed(1)} ${latestData.unit}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasChange) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${changeValue.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: isPositive ? Colors.green[700] : Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last reading: ${_formatTimestamp(latestData.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (data.length > 1) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: _MiniChart(data: data.take(20).toList()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatMetricName(String metric) {
    return metric
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _MetricIcon extends StatelessWidget {
  final String metric;

  const _MetricIcon({required this.metric});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (metric.toLowerCase()) {
      case 'temperature':
        iconData = Icons.thermostat;
        iconColor = Colors.orange;
        break;
      case 'humidity':
        iconData = Icons.water_drop;
        iconColor = Colors.blue;
        break;
      case 'occupancy':
        iconData = Icons.people;
        iconColor = Colors.green;
        break;
      case 'energy_usage':
        iconData = Icons.bolt;
        iconColor = Colors.yellow[700]!;
        break;
      case 'security_status':
        iconData = Icons.security;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.sensors;
        iconColor = Colors.grey;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List<AssetTelemetry> data;

  const _MiniChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _ChartPainter(data: data),
        size: const Size(double.infinity, 44),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<AssetTelemetry> data;

  _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    final values = data.map((d) => d.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = (data[i].value - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}