import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/super_admin_provider.dart';

class SystemHealthMonitor extends ConsumerWidget {
  const SystemHealthMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemHealth = ref.watch(systemHealthProvider);

    if (systemHealth == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(superAdminProvider.notifier).refreshAllData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System overview metrics
            _buildSystemOverview(systemHealth),
            const SizedBox(height: 24),

            // Performance charts
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPerformanceChart(systemHealth),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildResourceUsageChart(systemHealth),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Services status
            _buildServicesStatus(systemHealth),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverview(SystemHealth health) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'CPU Usage',
            '${health.cpuUsage.toStringAsFixed(1)}%',
            Icons.memory,
            _getHealthColor(health.cpuUsage, 80, 60),
            'Current CPU utilization',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Memory Usage',
            '${health.memoryUsage.toStringAsFixed(1)}%',
            Icons.storage,
            _getHealthColor(health.memoryUsage, 85, 70),
            'RAM utilization',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Disk Usage',
            '${health.diskUsage.toStringAsFixed(1)}%',
            Icons.storage,
            _getHealthColor(health.diskUsage, 90, 75),
            'Storage utilization',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Active Connections',
            _formatNumber(health.activeConnections),
            Icons.wifi,
            AppColors.info,
            'Current active connections',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Response Time',
            '${health.responseTime.toStringAsFixed(0)}ms',
            Icons.speed,
            _getHealthColor(health.responseTime, 200, 100),
            'Average API response time',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Uptime',
            '${health.uptime.toStringAsFixed(2)}%',
            Icons.timeline,
            health.uptime >= 99.9 ? AppColors.success :
            health.uptime >= 99.5 ? AppColors.warning : AppColors.error,
            'System availability',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      color: AppColors.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(SystemHealth health) {
    final responseTimeMetric = health.performanceMetrics
        .firstWhere((metric) => metric.name == 'Response Time');

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics (Last 6 Hours)',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}ms',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        reservedSize: 50,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < responseTimeMetric.timestamps.length) {
                            final time = responseTimeMetric.timestamps[index];
                            return Text(
                              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: responseTimeMetric.values.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
                      ),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceUsageChart(SystemHealth health) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resource Usage',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCircularProgressIndicator('CPU', health.cpuUsage, AppColors.primary),
                  _buildCircularProgressIndicator('Memory', health.memoryUsage, AppColors.info),
                  _buildCircularProgressIndicator('Disk', health.diskUsage, AppColors.success),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgressIndicator(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 8,
                backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesStatus(SystemHealth health) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services Status',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...health.services.map((service) => _buildServiceItem(service)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(ServiceStatus service) {
    Color statusColor;
    IconData statusIcon;

    switch (service.status.toLowerCase()) {
      case 'healthy':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = AppColors.warning;
        statusIcon = Icons.warning;
        break;
      case 'error':
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (service.version != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'v${service.version}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Status: ${service.status.toUpperCase()}',
                      style: AppTextStyles.body2.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (service.responseTime != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        'Response: ${service.responseTime!.toStringAsFixed(1)}ms',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (service.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Last Check',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatTimeAgo(service.lastCheck),
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(double value, double errorThreshold, double warningThreshold) {
    if (value >= errorThreshold) {
      return AppColors.error;
    } else if (value >= warningThreshold) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}