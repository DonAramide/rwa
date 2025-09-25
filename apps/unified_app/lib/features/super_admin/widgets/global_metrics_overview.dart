import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/super_admin_provider.dart';

class GlobalMetricsOverview extends ConsumerWidget {
  const GlobalMetricsOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(platformMetricsProvider);
    final alerts = ref.watch(unresolvedAlertsProvider);

    if (metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(superAdminProvider.notifier).refreshAllData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick stats cards
            _buildQuickStatsGrid(metrics),
            const SizedBox(height: 24),

            // Charts section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue by merchant chart
                Expanded(
                  child: _buildRevenueByMerchantChart(metrics),
                ),
                const SizedBox(width: 24),

                // Users by role chart
                Expanded(
                  child: _buildUsersByRoleChart(metrics),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Alerts section
            if (alerts.isNotEmpty) ...[
              _buildAlertsSection(ref, alerts),
              const SizedBox(height: 24),
            ],

            // Recent activity
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid(PlatformMetrics metrics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Users',
          _formatNumber(metrics.totalUsers),
          Icons.people,
          AppColors.primary,
          '+12.5%',
          true,
        ),
        _buildStatCard(
          'Active Merchants',
          metrics.totalMerchants.toString(),
          Icons.account_balance,
          AppColors.success,
          '+2',
          true,
        ),
        _buildStatCard(
          'Asset Value',
          '\$${_formatLargeNumber(metrics.totalAssetValue)}',
          Icons.trending_up,
          AppColors.info,
          '+${metrics.monthlyGrowthRate.toStringAsFixed(1)}%',
          true,
        ),
        _buildStatCard(
          'Revenue',
          '\$${_formatLargeNumber(metrics.totalRevenue)}',
          Icons.monetization_on,
          AppColors.warning,
          '+15.3%',
          true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
    bool isPositive,
  ) {
    return Card(
      color: AppColors.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: AppTextStyles.caption.copyWith(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueByMerchantChart(PlatformMetrics metrics) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue by Merchant',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(metrics.revenueByMerchant),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildChartLegend(metrics.revenueByMerchant),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersByRoleChart(PlatformMetrics metrics) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Users by Role',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: metrics.usersByRole.values.fold(0, (a, b) => a > b ? a : b).toDouble() * 1.2,
                  barGroups: _buildBarGroups(metrics.usersByRole),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatNumber(value.toInt()),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final roles = metrics.usersByRole.keys.toList();
                          final index = value.toInt();
                          if (index >= 0 && index < roles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                roles[index].split('-').first, // Show first part of role name
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(WidgetRef ref, List<SystemAlert> alerts) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Alerts (${alerts.length})',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to alerts tab
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts.take(5).map((alert) => _buildAlertItem(ref, alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(WidgetRef ref, SystemAlert alert) {
    Color alertColor;
    IconData alertIcon;

    switch (alert.type) {
      case 'error':
        alertColor = AppColors.error;
        alertIcon = Icons.error;
        break;
      case 'warning':
        alertColor = AppColors.warning;
        alertIcon = Icons.warning;
        break;
      default:
        alertColor = AppColors.info;
        alertIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: alertColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            alertIcon,
            color: alertColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatTimeAgo(alert.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => ref.read(superAdminProvider.notifier).resolveAlert(alert.id),
            tooltip: 'Resolve',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Platform Activity',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'New merchant registration',
              'Capital Partners Merchant submitted documents',
              DateTime.now().subtract(const Duration(hours: 2)),
              Icons.account_balance,
              AppColors.info,
            ),
            _buildActivityItem(
              'High-value transaction',
              'Premier Merchant processed \$2.5M asset purchase',
              DateTime.now().subtract(const Duration(hours: 4)),
              Icons.monetization_on,
              AppColors.success,
            ),
            _buildActivityItem(
              'System maintenance',
              'Database optimization completed',
              DateTime.now().subtract(const Duration(hours: 6)),
              Icons.build,
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    DateTime timestamp,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatTimeAgo(timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.error,
    ];

    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${(entry.value / data.values.fold(0.0, (a, b) => a + b) * 100).toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildChartLegend(Map<String, double> data) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.error,
    ];

    return Wrap(
      children: data.entries.map((entry) {
        final index = data.keys.toList().indexOf(entry.key);
        return Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.key}: \$${_formatLargeNumber(entry.value)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, int> data) {
    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: AppColors.primary,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatLargeNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toStringAsFixed(0);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

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
}