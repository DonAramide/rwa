import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/portfolio_analytics_provider.dart';
import '../../services/portfolio_data_service.dart';

class PortfolioPerformanceChart extends ConsumerStatefulWidget {
  final String title;
  final double height;
  final bool showBenchmark;

  const PortfolioPerformanceChart({
    super.key,
    this.title = 'Portfolio Performance',
    this.height = 300,
    this.showBenchmark = true,
  });

  @override
  ConsumerState<PortfolioPerformanceChart> createState() => _PortfolioPerformanceChartState();
}

class _PortfolioPerformanceChartState extends ConsumerState<PortfolioPerformanceChart> {
  final periods = ['1M', '3M', '6M', '1Y', 'ALL'];

  @override
  void initState() {
    super.initState();
    // Load initial analytics data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioAnalyticsProvider.notifier).loadAllAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(portfolioAnalyticsProvider);
    final performanceData = analyticsState.performanceData;
    final metrics = performanceData?.metrics;

    if (analyticsState.isLoading) {
      return Card(
        color: AppColors.surface,
        child: Container(
          height: widget.height + 100,
          padding: const EdgeInsets.all(20),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (analyticsState.error != null) {
      return Card(
        color: AppColors.surface,
        child: Container(
          height: widget.height + 100,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load performance data',
                  style: AppTextStyles.body1.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.read(portfolioAnalyticsProvider.notifier).loadAllAnalytics(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chartData = performanceData?.dataPoints ?? [];
    final labels = _generateLabels(chartData);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: periods.map((period) =>
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildPeriodButton(period, analyticsState.selectedPeriod),
                    ),
                  ).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Performance metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Return',
                    metrics != null
                        ? '+${metrics.totalReturn.toStringAsFixed(1)}%'
                        : '--',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Best Performer',
                    metrics != null
                        ? '${metrics.bestPerformer.split(' ').first} +${metrics.bestPerformerReturn.toStringAsFixed(1)}%'
                        : '--',
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Monthly Income',
                    performanceData != null
                        ? '\$${performanceData.monthlyIncome.toStringAsFixed(0)}'
                        : '--',
                    Icons.attach_money,
                    AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Chart
            SizedBox(
              height: widget.height,
              child: chartData.isNotEmpty ? LineChart(
                LineChartData(
                  backgroundColor: Colors.transparent,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getHorizontalInterval(chartData),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _getBottomInterval(chartData),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[index],
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
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: _getHorizontalInterval(chartData),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${_formatValue(value)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: _buildLineBarsData(chartData, performanceData?.benchmark),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => AppColors.surface,
                      tooltipBorder: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final label = index < labels.length ? labels[index] : '';
                          final isBenchmark = spot.barIndex == 1;
                          return LineTooltipItem(
                            '${isBenchmark ? 'Benchmark' : 'Portfolio'}\n$label\n\$${spot.y.toStringAsFixed(2)}',
                            AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                ),
              ) : const Center(child: Text('No chart data available')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period, String selectedPeriod) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        ref.read(portfolioAnalyticsProvider.notifier).updatePeriod(period);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          period,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateLabels(List<PerformanceDataPoint> dataPoints) {
    return dataPoints.map((point) {
      final month = point.date.month;
      final year = point.date.year.toString().substring(2);
      return '$month/$year';
    }).toList();
  }

  List<LineChartBarData> _buildLineBarsData(
    List<PerformanceDataPoint> portfolioData,
    BenchmarkData? benchmarkData,
  ) {
    final List<LineChartBarData> lineBars = [];

    // Portfolio line
    if (portfolioData.isNotEmpty) {
      lineBars.add(
        LineChartBarData(
          spots: portfolioData.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.value);
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: AppColors.primary,
              strokeWidth: 2,
              strokeColor: AppColors.surface,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
          ),
        ),
      );
    }

    // Benchmark line (if available and enabled)
    if (widget.showBenchmark && benchmarkData != null) {
      lineBars.add(
        LineChartBarData(
          spots: benchmarkData.dataPoints.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.value);
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.textSecondary,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          dashArray: [5, 5], // Dashed line for benchmark
        ),
      );
    }

    return lineBars;
  }

  double _getHorizontalInterval(List<PerformanceDataPoint> dataPoints) {
    if (dataPoints.isEmpty) return 1000;
    final values = dataPoints.map((point) => point.value).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    return range / 4; // 4 horizontal lines
  }

  double _getBottomInterval(List<PerformanceDataPoint> dataPoints) {
    if (dataPoints.isEmpty) return 1;
    return (dataPoints.length / 6).ceilToDouble(); // Show ~6 labels
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}