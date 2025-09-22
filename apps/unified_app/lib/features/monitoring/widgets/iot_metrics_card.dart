import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/iot_device.dart';
import '../providers/iot_provider.dart';

class IoTMetricsCard extends ConsumerWidget {
  const IoTMetricsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iotState = ref.watch(iotDevicesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'IoT Device Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.read(iotDevicesProvider.notifier).loadDevices(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (iotState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (iotState.error != null)
              _buildErrorWidget(context, iotState.error!)
            else if (iotState.metrics != null)
              _buildMetricsContent(context, iotState.metrics!)
            else
              const Center(
                child: Text('No metrics available'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Error loading metrics: $error',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsContent(BuildContext context, IoTMetrics metrics) {
    return Column(
      children: [
        _buildOverviewRow(context, metrics),
        const SizedBox(height: 16),
        _buildStatusBreakdown(context, metrics),
        const SizedBox(height: 16),
        _buildDeviceTypeChart(context, metrics),
        if (metrics.recentAlerts.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecentAlerts(context, metrics),
        ],
      ],
    );
  }

  Widget _buildOverviewRow(BuildContext context, IoTMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            context,
            icon: Icons.devices,
            label: 'Total Devices',
            value: metrics.totalDevices.toString(),
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            context,
            icon: Icons.wifi,
            label: 'Online',
            value: '${metrics.onlinePercentage.toStringAsFixed(0)}%',
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            context,
            icon: Icons.battery_std,
            label: 'Avg Battery',
            value: '${metrics.averageBattery.toStringAsFixed(0)}%',
            color: _getBatteryColor(metrics.averageBattery),
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            context,
            icon: Icons.warning,
            label: 'Alerts',
            value: metrics.alertCount.toString(),
            color: metrics.alertCount > 0 ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(BuildContext context, IoTMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Status Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  context,
                  'Online',
                  metrics.onlineDevices,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  context,
                  'Offline',
                  metrics.offlineDevices,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  context,
                  'Maintenance',
                  metrics.totalDevices - metrics.onlineDevices - metrics.offlineDevices,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDeviceTypeChart(BuildContext context, IoTMetrics metrics) {
    if (metrics.devicesByType.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Types',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: metrics.devicesByType.entries.map((entry) {
              final color = _getTypeColor(entry.key);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getTypeIcon(entry.key), size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTypeName(entry.key)} (${entry.value})',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts(BuildContext context, IoTMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent Alerts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...metrics.recentAlerts.take(3).map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.fiber_manual_record,
                         size: 8,
                         color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (metrics.recentAlerts.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${metrics.recentAlerts.length - 3} more alerts',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBatteryColor(double battery) {
    if (battery > 50) return Colors.green;
    if (battery > 20) return Colors.orange;
    return Colors.red;
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'sensor':
        return Colors.blue;
      case 'camera':
        return Colors.purple;
      case 'tracker':
        return Colors.green;
      case 'meter':
        return Colors.orange;
      case 'gateway':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sensor':
        return Icons.sensors;
      case 'camera':
        return Icons.videocam;
      case 'tracker':
        return Icons.gps_fixed;
      case 'meter':
        return Icons.speed;
      case 'gateway':
        return Icons.router;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'sensor':
        return 'Sensors';
      case 'camera':
        return 'Cameras';
      case 'tracker':
        return 'Trackers';
      case 'meter':
        return 'Meters';
      case 'gateway':
        return 'Gateways';
      default:
        return type;
    }
  }
}