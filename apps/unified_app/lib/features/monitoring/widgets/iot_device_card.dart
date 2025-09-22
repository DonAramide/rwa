import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/iot_device.dart';
import '../providers/iot_provider.dart';

class IoTDeviceCard extends ConsumerWidget {
  final IoTDevice device;

  const IoTDeviceCard({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showDeviceDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildStatusInfo(context),
              const SizedBox(height: 12),
              _buildSensorData(context),
              if (device.hasAlerts) ...[
                const SizedBox(height: 12),
                _buildAlerts(context),
              ],
              const SizedBox(height: 12),
              _buildActionButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                device.typeDisplayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            device.statusDisplayName,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context) {
    final lastPingDuration = DateTime.now().difference(device.lastPing);
    final lastPingText = lastPingDuration.inMinutes < 60
        ? '${lastPingDuration.inMinutes}m ago'
        : lastPingDuration.inHours < 24
            ? '${lastPingDuration.inHours}h ago'
            : '${lastPingDuration.inDays}d ago';

    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            context,
            icon: Icons.battery_std,
            label: 'Battery',
            value: '${device.batteryLevel.toStringAsFixed(1)}%',
            color: _getBatteryColor(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoItem(
            context,
            icon: Icons.access_time,
            label: 'Last Ping',
            value: lastPingText,
            color: Colors.grey[600]!,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSensorData(BuildContext context) {
    if (device.sensorData.isEmpty) return const SizedBox.shrink();

    final entries = device.sensorData.entries.take(3).toList();

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
            'Sensor Data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: entries.map((entry) {
              return Text(
                '${_formatSensorKey(entry.key)}: ${_formatSensorValue(entry.value)}',
                style: Theme.of(context).textTheme.bodySmall,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts(BuildContext context) {
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
              Icon(Icons.warning, size: 16, color: Colors.red[700]),
              const SizedBox(width: 4),
              Text(
                'Alerts (${device.alerts.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...device.alerts.take(2).map((alert) => Text(
                '• $alert',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red[700],
                ),
              )),
          if (device.alerts.length > 2)
            Text(
              '• +${device.alerts.length - 2} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => ref.read(iotDevicesProvider.notifier).refreshDevice(device.id),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showControlPanel(context, ref),
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('Control'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (device.type) {
      case DeviceType.sensor:
        return Colors.blue;
      case DeviceType.camera:
        return Colors.purple;
      case DeviceType.tracker:
        return Colors.green;
      case DeviceType.meter:
        return Colors.orange;
      case DeviceType.gateway:
        return Colors.teal;
    }
  }

  IconData _getTypeIcon() {
    switch (device.type) {
      case DeviceType.sensor:
        return Icons.sensors;
      case DeviceType.camera:
        return Icons.videocam;
      case DeviceType.tracker:
        return Icons.gps_fixed;
      case DeviceType.meter:
        return Icons.speed;
      case DeviceType.gateway:
        return Icons.router;
    }
  }

  Color _getStatusColor() {
    switch (device.status) {
      case DeviceStatus.online:
        return Colors.green;
      case DeviceStatus.offline:
        return Colors.red;
      case DeviceStatus.maintenance:
        return Colors.orange;
      case DeviceStatus.error:
        return Colors.red[800]!;
    }
  }

  Color _getBatteryColor() {
    if (device.batteryLevel > 50) return Colors.green;
    if (device.batteryLevel > 20) return Colors.orange;
    return Colors.red;
  }

  String _formatSensorKey(String key) {
    return key.replaceAll('_', ' ').split(' ').map((word) {
      return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word;
    }).join(' ');
  }

  String _formatSensorValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    }
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }
    return value.toString();
  }

  void _showDeviceDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DeviceDetailsDialog(device: device),
    );
  }

  void _showControlPanel(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DeviceControlPanel(device: device, ref: ref),
    );
  }
}

class _DeviceDetailsDialog extends StatelessWidget {
  final IoTDevice device;

  const _DeviceDetailsDialog({required this.device});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(context, 'Device Information', {
                      'Type': device.typeDisplayName,
                      'Status': device.statusDisplayName,
                      'Asset ID': device.assetId,
                      'Firmware': device.firmware,
                      'Installed': _formatDate(device.installedAt),
                    }),
                    const SizedBox(height: 16),
                    _buildDetailSection(context, 'Power & Connectivity', {
                      'Battery Level': '${device.batteryLevel.toStringAsFixed(1)}%',
                      'Last Ping': _formatDate(device.lastPing),
                      'Status': device.statusDisplayName,
                    }),
                    const SizedBox(height: 16),
                    _buildDetailSection(context, 'Location', device.location),
                    const SizedBox(height: 16),
                    _buildDetailSection(context, 'Sensor Data', device.sensorData),
                    if (device.hasAlerts) ...[
                      const SizedBox(height: 16),
                      _buildAlertsSection(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Alerts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: device.alerts.map((alert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red[700]),
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
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _DeviceControlPanel extends StatelessWidget {
  final IoTDevice device;
  final WidgetRef ref;

  const _DeviceControlPanel({required this.device, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Control ${device.name}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(iotDevicesProvider.notifier).updateDeviceStatus(
                    device.id,
                    device.status == DeviceStatus.online
                        ? DeviceStatus.offline
                        : DeviceStatus.online,
                  );
                  Navigator.of(context).pop();
                },
                icon: Icon(device.status == DeviceStatus.online
                    ? Icons.stop
                    : Icons.play_arrow),
                label: Text(device.status == DeviceStatus.online
                    ? 'Stop Device'
                    : 'Start Device'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(iotDevicesProvider.notifier).updateDeviceStatus(
                    device.id,
                    DeviceStatus.maintenance,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.build),
                label: const Text('Maintenance'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(iotDevicesProvider.notifier).refreshDevice(device.id);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}