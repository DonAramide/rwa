import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/super_admin_provider.dart';

class GlobalAnalyticsDashboard extends ConsumerStatefulWidget {
  const GlobalAnalyticsDashboard({super.key});

  @override
  ConsumerState<GlobalAnalyticsDashboard> createState() => _GlobalAnalyticsDashboardState();
}

class _GlobalAnalyticsDashboardState extends ConsumerState<GlobalAnalyticsDashboard> {
  String _selectedTimeRange = '30 days';
  final List<String> _timeRanges = ['7 days', '30 days', '90 days', '1 year'];

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(platformMetricsProvider);

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
            // Time range selector
            _buildTimeRangeSelector(),
            const SizedBox(height: 24),

            // Key metrics cards
            _buildKeyMetrics(metrics),
            const SizedBox(height: 24),

            // Charts row 1
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTransactionVolumeChart(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildUserGrowthChart(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Charts row 2
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildAssetTypeDistribution(metrics),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildGeographicDistribution(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Performance metrics table
            _buildPerformanceMetricsTable(metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      children: [
        Text(
          'Analytics Dashboard',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              items: _timeRanges.map((range) {
                return DropdownMenuItem(
                  value: range,
                  child: Text(
                    range,
                    style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimeRange = value!;
                });
              },
              icon: Icon(Icons.expand_more, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(PlatformMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalyticsCard(
            'Total Revenue',
            '\$${_formatLargeNumber(metrics.totalRevenue)}',
            Icons.monetization_on,
            AppColors.success,
            '+15.3%',
            true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'Active Users',
            _formatNumber(metrics.totalUsers),
            Icons.people,
            AppColors.info,
            '+8.7%',
            true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'Transactions',
            _formatNumber(metrics.totalTransactions),
            Icons.receipt_long,
            AppColors.primary,
            '+22.1%',
            true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            'Asset Value',
            '\$${_formatLargeNumber(metrics.totalAssetValue)}',
            Icons.trending_up,
            AppColors.warning,
            '+${metrics.monthlyGrowthRate.toStringAsFixed(1)}%',
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.error).withOpacity(0.1),
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
              value,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionVolumeChart() {
    final transactionData = _generateMockTransactionData();

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Volume ($_selectedTimeRange)',
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
                    horizontalInterval: 500,
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
                          _formatNumber(value.toInt()),
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
                          if (index >= 0 && index < transactionData.length) {
                            return Text(
                              '${index + 1}',
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
                      spots: transactionData.asMap().entries.map((entry) {
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

  Widget _buildUserGrowthChart() {
    final userData = _generateMockUserData();

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Growth',
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
                  maxY: userData.values.fold(0, (a, b) => a > b ? a : b).toDouble() * 1.2,
                  barGroups: userData.entries.map((entry) {
                    final index = userData.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          gradient: LinearGradient(
                            colors: [AppColors.info.withOpacity(0.8), AppColors.info],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          _formatNumber(value.toInt()),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final roles = userData.keys.toList();
                          final index = value.toInt();
                          if (index >= 0 && index < roles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                roles[index].split(' ')[0],
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
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Widget _buildAssetTypeDistribution(PlatformMetrics metrics) {
    final assetTypes = _generateMockAssetTypes();

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Distribution by Type',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(assetTypes),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAssetTypeLegend(assetTypes),
          ],
        ),
      ),
    );
  }

  Widget _buildGeographicDistribution() {
    final geoData = _generateMockGeographicData();

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geographic Distribution',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ...geoData.entries.map((entry) => _buildGeographicItem(
              entry.key,
              entry.value['users'] as int,
              entry.value['percentage'] as double,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGeographicItem(String country, int users, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              country,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            _formatNumber(users),
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.textSecondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsTable(PlatformMetrics metrics) {
    final performanceData = _generateMockPerformanceData();

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                  ),
                  children: [
                    _buildTableHeader('Bank Partner'),
                    _buildTableHeader('Users'),
                    _buildTableHeader('Revenue'),
                    _buildTableHeader('Growth'),
                  ],
                ),
                ...performanceData.map((data) => TableRow(
                  children: [
                    _buildTableCell(data['name'] as String),
                    _buildTableCell(_formatNumber(data['users'] as int)),
                    _buildTableCell('\$${_formatLargeNumber(data['revenue'] as double)}'),
                    _buildTableCell(
                      '${data['growth']}%',
                      color: (data['growth'] as double) >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: AppTextStyles.body2.copyWith(
          color: color ?? AppColors.textSecondary,
        ),
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
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildAssetTypeLegend(Map<String, double> data) {
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
                entry.key,
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

  // Mock data generators
  List<double> _generateMockTransactionData() {
    return [1200, 1450, 1100, 1650, 1800, 2100, 1900, 2250, 2400, 2600, 2300, 2750, 3000, 2800, 3200];
  }

  Map<String, int> _generateMockUserData() {
    return {
      'Investor Agents': 12450,
      'Professional Agents': 1820,
      'Verifiers': 967,
      'Bank Admins': 145,
    };
  }

  Map<String, double> _generateMockAssetTypes() {
    return {
      'Real Estate': 45.5,
      'Financial': 22.3,
      'Transportation': 15.7,
      'Precious Metals': 10.2,
      'Technology': 6.3,
    };
  }

  Map<String, Map<String, dynamic>> _generateMockGeographicData() {
    return {
      'United States': {'users': 8420, 'percentage': 53.1},
      'United Kingdom': {'users': 2890, 'percentage': 18.2},
      'Germany': {'users': 1950, 'percentage': 12.3},
      'Canada': {'users': 1420, 'percentage': 9.0},
      'Others': {'users': 1167, 'percentage': 7.4},
    };
  }

  List<Map<String, dynamic>> _generateMockPerformanceData() {
    return [
      {'name': 'Premier Investment Bank', 'users': 5420, 'revenue': 3250000.0, 'growth': 15.3},
      {'name': 'Global Investment Partners', 'users': 3890, 'revenue': 2890000.0, 'growth': 12.7},
      {'name': 'Capital Partners Bank', 'users': 2950, 'revenue': 2150000.0, 'growth': 8.9},
      {'name': 'Metropolitan Trust', 'users': 2100, 'revenue': 1850000.0, 'growth': 22.1},
      {'name': 'Future Finance Corp', 'users': 1487, 'revenue': 1400000.0, 'growth': -3.2},
    ];
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
}