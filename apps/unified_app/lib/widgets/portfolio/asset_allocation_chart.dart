import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset.dart';
import '../../services/portfolio_data_service.dart';

/// Pie chart showing asset allocation by type
class AssetAllocationChart extends StatefulWidget {
  final List<Asset> assets;
  final double height;
  final bool showLegend;

  const AssetAllocationChart({
    super.key,
    required this.assets,
    this.height = 200,
    this.showLegend = true,
  });

  @override
  State<AssetAllocationChart> createState() => _AssetAllocationChartState();
}

class _AssetAllocationChartState extends State<AssetAllocationChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allocation = PortfolioDataService.generateAssetAllocation(widget.assets);

    if (allocation.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No allocation data available')),
      );
    }

    final colors = _generateColors(allocation.length);
    final sections = _buildPieChartSections(allocation, colors);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Allocation',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: widget.height,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: sections,
                      ),
                    ),
                  ),
                ),
                if (widget.showLegend) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLegend(allocation, colors, theme),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> allocation,
    List<Color> colors,
  ) {
    final entries = allocation.entries.toList();

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: mapEntry.value,
        title: '${mapEntry.value.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> allocation, List<Color> colors, ThemeData theme) {
    final entries = allocation.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final mapEntry = entry.value;
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mapEntry.key,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Text(
                '${mapEntry.value.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Color> _generateColors(int count) {
    final baseColors = [
      AppTheme.primaryColor,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.pink,
    ];

    if (count <= baseColors.length) {
      return baseColors.take(count).toList();
    }

    final colors = <Color>[];
    for (int i = 0; i < count; i++) {
      colors.add(baseColors[i % baseColors.length]);
    }
    return colors;
  }
}

/// Rebalancing suggestions widget
class RebalancingSuggestionsWidget extends StatelessWidget {
  final List<RebalancingSuggestion> suggestions;

  const RebalancingSuggestionsWidget({
    super.key,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (suggestions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Portfolio is well balanced',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No rebalancing needed at this time',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rebalancing Suggestions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) => _buildSuggestionItem(suggestion, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(RebalancingSuggestion suggestion, ThemeData theme) {
    final isIncrease = suggestion.action == RebalanceAction.buy;
    final color = isIncrease ? Colors.green : Colors.orange;
    final icon = isIncrease ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.assetType,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  suggestion.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncrease ? '+' : '-'}₦${_formatCurrency(suggestion.suggestedAmount)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${suggestion.currentPercent.toStringAsFixed(1)}% → ${suggestion.targetPercent.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}