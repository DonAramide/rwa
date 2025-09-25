import 'dart:math';
import '../models/asset.dart';
import '../providers/portfolio_provider.dart';

class PortfolioRebalancingService {
  /// Analyze portfolio and provide rebalancing suggestions
  static PortfolioAnalysis analyzePortfolio(List<Holding> holdings) {
    if (holdings.isEmpty) {
      return PortfolioAnalysis(
        totalValue: 0,
        assetAllocation: {},
        riskProfile: RiskProfile.conservative,
        suggestions: [
          RebalancingSuggestion(
            type: SuggestionType.diversification,
            priority: Priority.high,
            title: 'Start Building Your Portfolio',
            description: 'You don\'t have any holdings yet. Consider diversifying across different asset types.',
            actionText: 'Explore Marketplace',
            estimatedImpact: 'Build wealth foundation',
          ),
        ],
        riskScore: 0,
        diversificationScore: 0,
      );
    }

    final totalValue = holdings.fold<double>(0, (sum, h) => sum + h.value);
    final assetAllocation = _calculateAssetAllocation(holdings, totalValue);
    final riskScore = _calculateRiskScore(holdings, assetAllocation);
    final diversificationScore = _calculateDiversificationScore(assetAllocation);
    final riskProfile = _determineRiskProfile(riskScore, diversificationScore);

    final suggestions = _generateSuggestions(
      holdings,
      assetAllocation,
      riskScore,
      diversificationScore,
      totalValue,
    );

    return PortfolioAnalysis(
      totalValue: totalValue,
      assetAllocation: assetAllocation,
      riskProfile: riskProfile,
      suggestions: suggestions,
      riskScore: riskScore,
      diversificationScore: diversificationScore,
    );
  }

  static Map<String, double> _calculateAssetAllocation(
    List<Holding> holdings,
    double totalValue,
  ) {
    final Map<String, double> allocation = {};

    for (final holding in holdings) {
      final assetType = _normalizeAssetType(holding.assetType);
      allocation[assetType] = (allocation[assetType] ?? 0) + holding.value;
    }

    // Convert to percentages
    allocation.forEach((key, value) {
      allocation[key] = (value / totalValue) * 100;
    });

    return allocation;
  }

  static String _normalizeAssetType(String type) {
    switch (type.toLowerCase()) {
      case 'house':
      case 'residential':
        return 'Residential Real Estate';
      case 'hotel':
      case 'hospitality':
        return 'Hospitality';
      case 'truck':
      case 'vehicle':
      case 'transport':
        return 'Transportation';
      case 'land':
      case 'agriculture':
        return 'Agriculture';
      case 'office':
      case 'commercial':
        return 'Commercial Real Estate';
      case 'warehouse':
      case 'industrial':
        return 'Industrial';
      default:
        return 'Other Assets';
    }
  }

  static double _calculateRiskScore(
    List<Holding> holdings,
    Map<String, double> allocation,
  ) {
    double riskScore = 0;

    // Base risk by asset type (0-10 scale)
    final Map<String, double> assetTypeRisk = {
      'Residential Real Estate': 3.5,
      'Commercial Real Estate': 4.0,
      'Hospitality': 6.0,
      'Transportation': 5.5,
      'Agriculture': 4.5,
      'Industrial': 4.0,
      'Other Assets': 5.0,
    };

    // Weighted average based on allocation
    allocation.forEach((assetType, percentage) {
      final typeRisk = assetTypeRisk[assetType] ?? 5.0;
      riskScore += (typeRisk * percentage / 100);
    });

    // Adjust for concentration risk (higher concentration = higher risk)
    final maxAllocation = allocation.values.fold<double>(0, max);
    if (maxAllocation > 70) {
      riskScore += 1.5; // High concentration penalty
    } else if (maxAllocation > 50) {
      riskScore += 0.5; // Medium concentration penalty
    }

    // Adjust for performance volatility
    final returns = holdings.map((h) => h.returnPercent).toList();
    if (returns.isNotEmpty) {
      final avgReturn = returns.fold<double>(0, (sum, r) => sum + r) / returns.length;
      final variance = returns.fold<double>(0, (sum, r) => sum + pow(r - avgReturn, 2)) / returns.length;
      final volatility = sqrt(variance);

      riskScore += volatility * 0.1; // Volatility adjustment
    }

    return min(10.0, max(0.0, riskScore));
  }

  static double _calculateDiversificationScore(Map<String, double> allocation) {
    if (allocation.isEmpty) return 0;

    // Shannon diversity index adapted for portfolio
    double diversityIndex = 0;
    final int numAssetTypes = allocation.length;

    allocation.values.forEach((percentage) {
      if (percentage > 0) {
        final proportion = percentage / 100;
        diversityIndex -= proportion * log(proportion) / ln2;
      }
    });

    // Normalize to 0-100 scale
    final maxDiversity = log(numAssetTypes) / ln2;
    final normalizedScore = maxDiversity > 0 ? (diversityIndex / maxDiversity) * 100 : 0;

    return min(100.0, max(0.0, normalizedScore.toDouble()));
  }

  static RiskProfile _determineRiskProfile(double riskScore, double diversificationScore) {
    if (riskScore < 3 && diversificationScore > 70) {
      return RiskProfile.conservative;
    } else if (riskScore < 6 && diversificationScore > 50) {
      return RiskProfile.moderate;
    } else if (riskScore < 8) {
      return RiskProfile.aggressive;
    } else {
      return RiskProfile.veryAggressive;
    }
  }

  static List<RebalancingSuggestion> _generateSuggestions(
    List<Holding> holdings,
    Map<String, double> allocation,
    double riskScore,
    double diversificationScore,
    double totalValue,
  ) {
    final List<RebalancingSuggestion> suggestions = [];

    // Diversification suggestions
    if (diversificationScore < 40) {
      suggestions.add(RebalancingSuggestion(
        type: SuggestionType.diversification,
        priority: Priority.high,
        title: 'Improve Diversification',
        description: 'Your portfolio is concentrated in few asset types. Consider spreading investments across more sectors.',
        actionText: 'Explore Different Assets',
        estimatedImpact: 'Reduce risk by 15-25%',
      ));
    }

    // Concentration risk
    final maxAllocation = allocation.values.fold<double>(0, max);
    if (maxAllocation > 60) {
      final dominantAsset = allocation.entries
          .firstWhere((entry) => entry.value == maxAllocation)
          .key;
      suggestions.add(RebalancingSuggestion(
        type: SuggestionType.riskReduction,
        priority: Priority.medium,
        title: 'Reduce Concentration Risk',
        description: '$dominantAsset makes up ${maxAllocation.toStringAsFixed(1)}% of your portfolio. Consider rebalancing.',
        actionText: 'Rebalance Portfolio',
        estimatedImpact: 'Lower portfolio volatility',
      ));
    }

    // Risk-based suggestions
    if (riskScore > 7) {
      suggestions.add(RebalancingSuggestion(
        type: SuggestionType.riskReduction,
        priority: Priority.high,
        title: 'High Risk Portfolio',
        description: 'Your portfolio has high risk. Consider adding more stable assets like residential real estate.',
        actionText: 'Add Stable Assets',
        estimatedImpact: 'Reduce risk score to 5-6',
      ));
    }

    // Performance optimization
    final underPerformers = holdings
        .where((h) => h.returnPercent < 0)
        .toList();

    if (underPerformers.isNotEmpty) {
      suggestions.add(RebalancingSuggestion(
        type: SuggestionType.performance,
        priority: Priority.medium,
        title: 'Review Underperforming Assets',
        description: '${underPerformers.length} asset(s) are showing negative returns. Consider rebalancing.',
        actionText: 'Review Holdings',
        estimatedImpact: 'Optimize returns',
      ));
    }

    // Growth opportunities
    if (totalValue < 50000) {
      suggestions.add(RebalancingSuggestion(
        type: SuggestionType.growth,
        priority: Priority.low,
        title: 'Increase Investment Size',
        description: 'Consider increasing your investment amount to access more premium opportunities.',
        actionText: 'Add Funds',
        estimatedImpact: 'Access better deals',
      ));
    }

    // Income optimization
    final totalMonthlyIncome = holdings.fold<double>(0, (sum, h) => sum + h.monthlyIncome);
    final incomeYield = totalValue > 0 ? (totalMonthlyIncome * 12 / totalValue) * 100 : 0;

    if (incomeYield < 6) {
      suggestions.add(RebalancingSuggestion(
        type: SuggestionType.income,
        priority: Priority.low,
        title: 'Improve Income Generation',
        description: 'Your portfolio yields ${incomeYield.toStringAsFixed(1)}%. Consider high-yield assets.',
        actionText: 'Find Income Assets',
        estimatedImpact: 'Increase monthly income',
      ));
    }

    // Sort suggestions by priority
    suggestions.sort((a, b) {
      final priorityOrder = {Priority.high: 0, Priority.medium: 1, Priority.low: 2};
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    return suggestions;
  }
}

/// Portfolio analysis result
class PortfolioAnalysis {
  final double totalValue;
  final Map<String, double> assetAllocation;
  final RiskProfile riskProfile;
  final List<RebalancingSuggestion> suggestions;
  final double riskScore;
  final double diversificationScore;

  const PortfolioAnalysis({
    required this.totalValue,
    required this.assetAllocation,
    required this.riskProfile,
    required this.suggestions,
    required this.riskScore,
    required this.diversificationScore,
  });
}

/// Rebalancing suggestion
class RebalancingSuggestion {
  final SuggestionType type;
  final Priority priority;
  final String title;
  final String description;
  final String actionText;
  final String estimatedImpact;

  const RebalancingSuggestion({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionText,
    required this.estimatedImpact,
  });
}

enum SuggestionType {
  diversification,
  riskReduction,
  performance,
  growth,
  income,
}

enum Priority {
  high,
  medium,
  low,
}

enum RiskProfile {
  conservative,
  moderate,
  aggressive,
  veryAggressive,
}

extension RiskProfileExtension on RiskProfile {
  String get displayName {
    switch (this) {
      case RiskProfile.conservative:
        return 'Conservative';
      case RiskProfile.moderate:
        return 'Moderate';
      case RiskProfile.aggressive:
        return 'Aggressive';
      case RiskProfile.veryAggressive:
        return 'Very Aggressive';
    }
  }

  String get description {
    switch (this) {
      case RiskProfile.conservative:
        return 'Low risk, stable returns';
      case RiskProfile.moderate:
        return 'Balanced risk and returns';
      case RiskProfile.aggressive:
        return 'Higher risk, higher potential returns';
      case RiskProfile.veryAggressive:
        return 'Very high risk, maximum growth potential';
    }
  }
}