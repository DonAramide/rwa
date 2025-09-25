import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/asset.dart';
import '../../providers/portfolio_provider.dart';
import '../../services/portfolio_rebalancing_service.dart';

class PortfolioAnalysisWidget extends StatelessWidget {
  final List<Holding> holdings;
  final VoidCallback? onRefresh;

  const PortfolioAnalysisWidget({
    super.key,
    required this.holdings,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = PortfolioRebalancingService.analyzePortfolio(holdings);

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Portfolio Analysis',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    onPressed: onRefresh,
                    icon: Icon(
                      Icons.refresh,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Risk and Diversification Scores
            _buildScoreSection(analysis),
            const SizedBox(height: 24),

            // Asset Allocation
            if (analysis.assetAllocation.isNotEmpty) ...[
              _buildAssetAllocationSection(analysis.assetAllocation),
              const SizedBox(height: 24),
            ],

            // Rebalancing Suggestions
            _buildSuggestionsSection(context, analysis.suggestions),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(PortfolioAnalysis analysis) {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            'Risk Score',
            analysis.riskScore,
            10,
            _getRiskColor(analysis.riskScore),
            analysis.riskProfile.displayName,
            analysis.riskProfile.description,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildScoreCard(
            'Diversification',
            analysis.diversificationScore,
            100,
            _getDiversificationColor(analysis.diversificationScore),
            _getDiversificationLevel(analysis.diversificationScore),
            'Spread across asset types',
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    String title,
    double score,
    double maxScore,
    Color color,
    String level,
    String description,
  ) {
    final percentage = score / maxScore;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                score.toStringAsFixed(1),
                style: AppTextStyles.heading3.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          Text(
            level,
            style: AppTextStyles.body2.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            description,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetAllocationSection(Map<String, double> allocation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Allocation',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...allocation.entries.map((entry) => _buildAllocationItem(
          entry.key,
          entry.value,
        )),
      ],
    );
  }

  Widget _buildAllocationItem(String assetType, double percentage) {
    final color = _getAssetTypeColor(assetType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              assetType,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context, List<RebalancingSuggestion> suggestions) {
    if (suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Well Balanced Portfolio',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Your portfolio is well diversified and balanced.',
                    style: AppTextStyles.body2.copyWith(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Rebalancing Suggestions',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${suggestions.length}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...suggestions.take(3).map((suggestion) => _buildSuggestionCard(context, suggestion)),
        if (suggestions.length > 3) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _showAllSuggestions(context, suggestions),
            child: Text('View All ${suggestions.length} Suggestions'),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestionCard(BuildContext context, RebalancingSuggestion suggestion) {
    final color = _getPriorityColor(suggestion.priority);
    final icon = _getSuggestionIcon(suggestion.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      suggestion.description,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  suggestion.priority.name.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                suggestion.estimatedImpact,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _handleSuggestionAction(context, suggestion),
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(suggestion.actionText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllSuggestions(BuildContext context, List<RebalancingSuggestion> suggestions) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Rebalancing Suggestions',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) => _buildSuggestionCard(context, suggestions[index]),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSuggestionAction(BuildContext context, RebalancingSuggestion suggestion) {
    switch (suggestion.type) {
      case SuggestionType.diversification:
      case SuggestionType.growth:
      case SuggestionType.income:
        context.push('/marketplace');
        break;
      case SuggestionType.riskReduction:
      case SuggestionType.performance:
        // Could navigate to portfolio details or holdings management
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review your holdings and consider rebalancing'),
            backgroundColor: AppColors.info,
          ),
        );
        break;
    }
  }

  Color _getRiskColor(double riskScore) {
    if (riskScore < 3) return AppColors.success;
    if (riskScore < 6) return AppColors.warning;
    if (riskScore < 8) return Colors.orange;
    return AppColors.error;
  }

  Color _getDiversificationColor(double diversificationScore) {
    if (diversificationScore > 70) return AppColors.success;
    if (diversificationScore > 40) return AppColors.warning;
    return AppColors.error;
  }

  String _getDiversificationLevel(double score) {
    if (score > 80) return 'Excellent';
    if (score > 60) return 'Good';
    if (score > 40) return 'Fair';
    if (score > 20) return 'Poor';
    return 'Very Poor';
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.error;
      case Priority.medium:
        return AppColors.warning;
      case Priority.low:
        return AppColors.info;
    }
  }

  IconData _getSuggestionIcon(SuggestionType type) {
    switch (type) {
      case SuggestionType.diversification:
        return Icons.pie_chart;
      case SuggestionType.riskReduction:
        return Icons.security;
      case SuggestionType.performance:
        return Icons.trending_up;
      case SuggestionType.growth:
        return Icons.trending_up;
      case SuggestionType.income:
        return Icons.payments;
    }
  }

  Color _getAssetTypeColor(String assetType) {
    switch (assetType) {
      case 'Residential Real Estate':
        return Colors.blue;
      case 'Commercial Real Estate':
        return Colors.indigo;
      case 'Hospitality':
        return Colors.purple;
      case 'Transportation':
        return Colors.orange;
      case 'Agriculture':
        return Colors.green;
      case 'Industrial':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}