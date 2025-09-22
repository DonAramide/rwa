import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class PricePoint {
  final DateTime date;
  final double price;
  final double volume;

  PricePoint({
    required this.date,
    required this.price,
    required this.volume,
  });
}

enum ChartTimeframe { day, week, month, quarter, year }

class PriceChart extends StatefulWidget {
  final String assetId;
  final String assetTitle;
  final double currentPrice;
  final List<PricePoint> priceHistory;
  final ChartTimeframe selectedTimeframe;
  final Function(ChartTimeframe) onTimeframeChanged;

  const PriceChart({
    super.key,
    required this.assetId,
    required this.assetTitle,
    required this.currentPrice,
    required this.priceHistory,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTimeframeSelector(),
          const SizedBox(height: 20),
          _buildChart(),
          const SizedBox(height: 16),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final change = _calculatePriceChange();
    final changePercent = _calculatePercentChange();
    final isPositive = change >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.assetTitle} Price',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${widget.currentPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}\$${change.toStringAsFixed(2)}',
                      style: AppTextStyles.body1.copyWith(
                        color: isPositive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${isPositive ? '+' : ''}${changePercent.toStringAsFixed(1)}%)',
                      style: AppTextStyles.body2.copyWith(
                        color: isPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Live',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChartTimeframe.values.map((timeframe) {
          final isSelected = widget.selectedTimeframe == timeframe;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getTimeframeLabel(timeframe)),
              selected: isSelected,
              onSelected: (_) => widget.onTimeframeChanged(timeframe),
              selectedColor: AppColors.primary.withOpacity(0.2),
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    if (widget.priceHistory.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No price data available',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateGridInterval(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.outline.withOpacity(0.2),
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
                reservedSize: 40,
                interval: _calculateBottomInterval(),
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildBottomTitle(value),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _calculateGridInterval(),
                reservedSize: 80,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '\$${value.toStringAsFixed(0)}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: AppColors.outline.withOpacity(0.2),
              ),
              left: BorderSide(
                color: AppColors.outline.withOpacity(0.2),
              ),
            ),
          ),
          minX: 0,
          maxX: widget.priceHistory.length.toDouble() - 1,
          minY: _getMinPrice() * 0.95,
          maxY: _getMaxPrice() * 1.05,
          lineBarsData: [
            LineChartBarData(
              spots: _buildSpots(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.primary,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
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
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.surface,
              tooltipBorder: BorderSide(
                color: AppColors.outline.withOpacity(0.3),
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final pricePoint = widget.priceHistory[spot.x.toInt()];
                  return LineTooltipItem(
                    '\$${spot.y.toStringAsFixed(2)}\n${_formatDate(pricePoint.date)}',
                    AppTextStyles.body2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    final high = _getMaxPrice();
    final low = _getMinPrice();
    final volume = _getTotalVolume();

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard('24h High', '\$${high.toStringAsFixed(2)}'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('24h Low', '\$${low.toStringAsFixed(2)}'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('Volume', '${volume.toStringAsFixed(0)}'),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTitle(double value) {
    if (value.toInt() >= widget.priceHistory.length) return const Text('');

    final pricePoint = widget.priceHistory[value.toInt()];
    String formatted;

    switch (widget.selectedTimeframe) {
      case ChartTimeframe.day:
        formatted = '${pricePoint.date.hour}:${pricePoint.date.minute.toString().padLeft(2, '0')}';
        break;
      case ChartTimeframe.week:
        formatted = '${pricePoint.date.day}/${pricePoint.date.month}';
        break;
      case ChartTimeframe.month:
      case ChartTimeframe.quarter:
      case ChartTimeframe.year:
        formatted = '${pricePoint.date.month}/${pricePoint.date.day}';
        break;
    }

    return Text(
      formatted,
      style: AppTextStyles.body2.copyWith(
        color: AppColors.textSecondary,
        fontSize: 11,
      ),
      textAlign: TextAlign.center,
    );
  }

  List<FlSpot> _buildSpots() {
    return widget.priceHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.price);
    }).toList();
  }

  String _getTimeframeLabel(ChartTimeframe timeframe) {
    switch (timeframe) {
      case ChartTimeframe.day:
        return '1D';
      case ChartTimeframe.week:
        return '7D';
      case ChartTimeframe.month:
        return '30D';
      case ChartTimeframe.quarter:
        return '3M';
      case ChartTimeframe.year:
        return '1Y';
    }
  }

  double _calculatePriceChange() {
    if (widget.priceHistory.isEmpty) return 0;
    final firstPrice = widget.priceHistory.first.price;
    return widget.currentPrice - firstPrice;
  }

  double _calculatePercentChange() {
    if (widget.priceHistory.isEmpty) return 0;
    final firstPrice = widget.priceHistory.first.price;
    return ((widget.currentPrice - firstPrice) / firstPrice) * 100;
  }

  double _getMaxPrice() {
    if (widget.priceHistory.isEmpty) return widget.currentPrice;
    return widget.priceHistory.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  }

  double _getMinPrice() {
    if (widget.priceHistory.isEmpty) return widget.currentPrice;
    return widget.priceHistory.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  double _getTotalVolume() {
    return widget.priceHistory.fold(0, (sum, point) => sum + point.volume);
  }

  double _calculateGridInterval() {
    final range = _getMaxPrice() - _getMinPrice();
    return range / 5;
  }

  double _calculateBottomInterval() {
    final length = widget.priceHistory.length;
    if (length <= 6) return 1;
    return (length / 6).ceilToDouble();
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}