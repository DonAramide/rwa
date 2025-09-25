import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/asset.dart';
import '../models/user_role.dart';

/// Service for generating mock portfolio data and analytics
class PortfolioDataService {
  static final Random _random = Random();

  /// Generate mock portfolio assets based on user role
  static List<Asset> generateMockPortfolio({
    required UserRole userRole,
    required String userId,
    int? count,
  }) {
    final assetCount = count ?? _getDefaultAssetCount(userRole);
    final assets = <Asset>[];

    for (int i = 0; i < assetCount; i++) {
      assets.add(_generateMockAsset(userRole, userId, i));
    }

    return assets;
  }

  /// Generate portfolio performance data
  static PortfolioPerformance generatePerformanceData({
    required List<Asset> assets,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final totalValue = assets.fold<double>(0, (sum, asset) => sum + asset.currentValue);
    final totalInvested = assets.fold<double>(0, (sum, asset) => sum + asset.purchasePrice);

    final performanceHistory = _generatePerformanceHistory(
      startDate: startDate,
      endDate: endDate,
      startValue: totalInvested,
      endValue: totalValue,
    );

    return PortfolioPerformance(
      totalValue: totalValue,
      totalInvested: totalInvested,
      totalReturn: totalValue - totalInvested,
      returnPercentage: ((totalValue - totalInvested) / totalInvested) * 100,
      performanceHistory: performanceHistory,
      lastUpdated: DateTime.now(),
    );
  }

  /// Generate asset allocation data
  static Map<String, double> generateAssetAllocation(List<Asset> assets) {
    final totalValue = assets.fold<double>(0, (sum, asset) => sum + asset.currentValue);
    final allocation = <String, double>{};

    for (final asset in assets) {
      final percentage = (asset.currentValue / totalValue) * 100;
      allocation[asset.assetType] = (allocation[asset.assetType] ?? 0) + percentage;
    }

    return allocation;
  }

  /// Generate dividend history
  static List<DividendPayment> generateDividendHistory({
    required List<Asset> assets,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final dividends = <DividendPayment>[];
    final monthsDiff = endDate.difference(startDate).inDays ~/ 30;

    for (final asset in assets) {
      // Generate quarterly dividends for real estate assets
      if (asset.assetType == 'Real Estate' && asset.currentValue > 100000) {
        for (int i = 0; i < monthsDiff ~/ 3; i++) {
          final paymentDate = startDate.add(Duration(days: i * 90));
          if (paymentDate.isBefore(endDate)) {
            dividends.add(DividendPayment(
              assetId: asset.id,
              assetTitle: asset.title,
              amount: asset.currentValue * (0.02 + _random.nextDouble() * 0.03), // 2-5% quarterly
              paymentDate: paymentDate,
              currency: 'NGN',
            ));
          }
        }
      }
    }

    dividends.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return dividends;
  }

  /// Generate rebalancing suggestions
  static List<RebalancingSuggestion> generateRebalancingSuggestions({
    required List<Asset> assets,
    required Map<String, double> targetAllocation,
  }) {
    final currentAllocation = generateAssetAllocation(assets);
    final suggestions = <RebalancingSuggestion>[];
    final totalValue = assets.fold<double>(0, (sum, asset) => sum + asset.currentValue);

    for (final entry in targetAllocation.entries) {
      final assetType = entry.key;
      final targetPercent = entry.value;
      final currentPercent = currentAllocation[assetType] ?? 0;
      final difference = targetPercent - currentPercent;

      if (difference.abs() > 5) { // Only suggest if difference > 5%
        final action = difference > 0 ? RebalanceAction.buy : RebalanceAction.sell;
        final amount = (difference.abs() / 100) * totalValue;

        suggestions.add(RebalancingSuggestion(
          assetType: assetType,
          action: action,
          currentPercent: currentPercent,
          targetPercent: targetPercent,
          suggestedAmount: amount,
          reason: _getRebalanceReason(action, difference.abs()),
        ));
      }
    }

    return suggestions;
  }

  // Private helper methods
  static int _getDefaultAssetCount(UserRole userRole) {
    switch (userRole) {
      case UserRole.superAdmin:
        return 25;
      case UserRole.admin:
        return 15;
      case UserRole.merchantAdmin:
      case UserRole.merchantOperations:
        return 12;
      case UserRole.professionalAgent:
        return 8;
      case UserRole.investorAgent:
        return 5;
      default:
        return 3;
    }
  }

  static Asset _generateMockAsset(UserRole userRole, String userId, int index) {
    final assetTypes = ['Real Estate', 'Agriculture', 'Infrastructure', 'Technology', 'Manufacturing'];
    final locations = ['Lagos', 'Abuja', 'Port Harcourt', 'Kano', 'Ibadan', 'Enugu'];
    final assetType = assetTypes[_random.nextInt(assetTypes.length)];

    final basePrice = _getBasePriceForRole(userRole) * (0.5 + _random.nextDouble());
    final currentMultiplier = 0.8 + _random.nextDouble() * 0.4; // 80% to 120% of purchase price

    return Asset(
      id: 'mock_asset_${userId}_$index',
      title: _generateAssetTitle(assetType, index),
      description: _generateAssetDescription(assetType),
      assetType: assetType,
      location: locations[_random.nextInt(locations.length)],
      totalValue: basePrice,
      currentValue: basePrice * currentMultiplier,
      purchasePrice: basePrice,
      shares: _random.nextInt(1000) + 100,
      totalShares: _random.nextInt(10000) + 1000,
      dividendYield: _random.nextDouble() * 8 + 2, // 2-10% yield
      riskLevel: RiskLevel.values[_random.nextInt(RiskLevel.values.length)],
      status: AssetStatus.active,
      createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
      images: _generateMockImages(assetType),
      documents: [],
      source: AssetSource.individual,
      metadata: AssetMetadata(
        uploaderId: userId,
        uploaderName: 'Mock User',
        uploadedAt: DateTime.now(),
        customMetadata: {
          'mockData': true,
          'generatedAt': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  static double _getBasePriceForRole(UserRole userRole) {
    switch (userRole) {
      case UserRole.superAdmin:
        return 10000000 + _random.nextDouble() * 50000000; // 10M - 60M
      case UserRole.admin:
        return 5000000 + _random.nextDouble() * 20000000; // 5M - 25M
      case UserRole.merchantAdmin:
      case UserRole.merchantOperations:
        return 2000000 + _random.nextDouble() * 10000000; // 2M - 12M
      case UserRole.professionalAgent:
        return 1000000 + _random.nextDouble() * 5000000; // 1M - 6M
      case UserRole.investorAgent:
        return 500000 + _random.nextDouble() * 2000000; // 500K - 2.5M
      default:
        return 100000 + _random.nextDouble() * 500000; // 100K - 600K
    }
  }

  static String _generateAssetTitle(String assetType, int index) {
    switch (assetType) {
      case 'Real Estate':
        final types = ['Luxury Apartment Complex', 'Commercial Plaza', 'Residential Estate', 'Office Building'];
        return '${types[_random.nextInt(types.length)]} ${index + 1}';
      case 'Agriculture':
        final types = ['Rice Farm', 'Palm Oil Plantation', 'Cassava Processing Plant', 'Poultry Farm'];
        return '${types[_random.nextInt(types.length)]} ${index + 1}';
      case 'Infrastructure':
        final types = ['Solar Power Plant', 'Water Treatment Facility', 'Telecom Tower', 'Road Construction'];
        return '${types[_random.nextInt(types.length)]} Project ${index + 1}';
      case 'Technology':
        final types = ['Data Center', 'Software Platform', 'Fintech Startup', 'E-commerce Platform'];
        return '${types[_random.nextInt(types.length)]} ${index + 1}';
      case 'Manufacturing':
        final types = ['Textile Factory', 'Food Processing Plant', 'Cement Factory', 'Steel Mill'];
        return '${types[_random.nextInt(types.length)]} ${index + 1}';
      default:
        return '$assetType Asset ${index + 1}';
    }
  }

  static String _generateAssetDescription(String assetType) {
    switch (assetType) {
      case 'Real Estate':
        return 'Premium real estate investment with strong rental yield potential and capital appreciation prospects.';
      case 'Agriculture':
        return 'Agricultural asset with sustainable farming practices and consistent revenue generation.';
      case 'Infrastructure':
        return 'Critical infrastructure investment supporting economic development and providing stable returns.';
      case 'Technology':
        return 'Technology asset with high growth potential and innovative market solutions.';
      case 'Manufacturing':
        return 'Manufacturing facility with efficient operations and strong market demand.';
      default:
        return 'Diversified asset investment with balanced risk and return profile.';
    }
  }

  static List<String> _generateMockImages(String assetType) {
    return [
      'https://via.placeholder.com/800x600?text=${assetType.replaceAll(' ', '+')}+1',
      'https://via.placeholder.com/800x600?text=${assetType.replaceAll(' ', '+')}+2',
      'https://via.placeholder.com/800x600?text=${assetType.replaceAll(' ', '+')}+3',
    ];
  }

  static List<PerformancePoint> _generatePerformanceHistory({
    required DateTime startDate,
    required DateTime endDate,
    required double startValue,
    required double endValue,
  }) {
    final points = <PerformancePoint>[];
    final days = endDate.difference(startDate).inDays;
    final dailyGrowthRate = pow(endValue / startValue, 1 / days) - 1;

    for (int i = 0; i <= days; i += 7) { // Weekly points
      final date = startDate.add(Duration(days: i));
      final volatility = (_random.nextDouble() - 0.5) * 0.02; // ±1% daily volatility
      final expectedValue = startValue * pow(1 + dailyGrowthRate + volatility, i);

      points.add(PerformancePoint(
        date: date,
        value: expectedValue.toDouble(),
      ));
    }

    return points;
  }

  static String _getRebalanceReason(RebalanceAction action, double percentDiff) {
    if (action == RebalanceAction.buy) {
      return 'Underweight by ${percentDiff.toStringAsFixed(1)}%. Consider increasing allocation.';
    } else {
      return 'Overweight by ${percentDiff.toStringAsFixed(1)}%. Consider reducing allocation.';
    }
  }
}

/// Portfolio performance model
class PortfolioPerformance {
  final double totalValue;
  final double totalInvested;
  final double totalReturn;
  final double returnPercentage;
  final List<PerformancePoint> performanceHistory;
  final DateTime lastUpdated;

  const PortfolioPerformance({
    required this.totalValue,
    required this.totalInvested,
    required this.totalReturn,
    required this.returnPercentage,
    required this.performanceHistory,
    required this.lastUpdated,
  });
}

/// Performance point for charts
class PerformancePoint {
  final DateTime date;
  final double value;

  const PerformancePoint({
    required this.date,
    required this.value,
  });
}

/// Dividend payment model
class DividendPayment {
  final String assetId;
  final String assetTitle;
  final double amount;
  final DateTime paymentDate;
  final String currency;

  const DividendPayment({
    required this.assetId,
    required this.assetTitle,
    required this.amount,
    required this.paymentDate,
    required this.currency,
  });
}

/// Rebalancing suggestion model
class RebalancingSuggestion {
  final String assetType;
  final RebalanceAction action;
  final double currentPercent;
  final double targetPercent;
  final double suggestedAmount;
  final String reason;

  const RebalancingSuggestion({
    required this.assetType,
    required this.action,
    required this.currentPercent,
    required this.targetPercent,
    required this.suggestedAmount,
    required this.reason,
  });
}

/// Rebalance action enum
enum RebalanceAction { buy, sell }