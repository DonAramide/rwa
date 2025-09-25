import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/portfolio_provider.dart';
import '../providers/assets_provider.dart';

/// Provider for real-time update service
final realTimeUpdateServiceProvider = Provider<RealTimeUpdateService>((ref) {
  return RealTimeUpdateService(ref);
});

/// Service for handling real-time portfolio and market updates
class RealTimeUpdateService {
  final Ref _ref;
  Timer? _portfolioTimer;
  Timer? _marketTimer;
  Timer? _priceTimer;
  bool _isActive = false;

  static const Duration _portfolioUpdateInterval = Duration(minutes: 2);
  static const Duration _marketUpdateInterval = Duration(minutes: 1);
  static const Duration _priceUpdateInterval = Duration(seconds: 30);

  RealTimeUpdateService(this._ref);

  /// Start real-time updates
  void startUpdates() {
    if (_isActive) return;

    _isActive = true;
    _startPortfolioUpdates();
    _startMarketUpdates();
    _startPriceUpdates();
  }

  /// Stop all real-time updates
  void stopUpdates() {
    _isActive = false;
    _portfolioTimer?.cancel();
    _marketTimer?.cancel();
    _priceTimer?.cancel();
  }

  /// Start portfolio-specific updates
  void _startPortfolioUpdates() {
    _portfolioTimer?.cancel();
    _portfolioTimer = Timer.periodic(_portfolioUpdateInterval, (_) {
      if (!_isActive) return;
      _updatePortfolio();
    });
  }

  /// Start market data updates
  void _startMarketUpdates() {
    _marketTimer?.cancel();
    _marketTimer = Timer.periodic(_marketUpdateInterval, (_) {
      if (!_isActive) return;
      _updateMarketData();
    });
  }

  /// Start price updates for holdings
  void _startPriceUpdates() {
    _priceTimer?.cancel();
    _priceTimer = Timer.periodic(_priceUpdateInterval, (_) {
      if (!_isActive) return;
      _updatePrices();
    });
  }

  /// Update portfolio data
  Future<void> _updatePortfolio() async {
    try {
      final portfolioNotifier = _ref.read(portfolioProvider.notifier);
      await portfolioNotifier.refreshPortfolio();
    } catch (e) {
      // Silently handle errors - real-time updates shouldn't be disruptive
    }
  }

  /// Update market/asset data
  Future<void> _updateMarketData() async {
    try {
      final assetsNotifier = _ref.read(assetsProvider.notifier);
      await assetsNotifier.loadAssets(refresh: true);
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Update price data for portfolio holdings
  Future<void> _updatePrices() async {
    try {
      final holdings = _ref.read(holdingsProvider);
      if (holdings.isNotEmpty) {
        // Update price data for each holding
        final portfolioNotifier = _ref.read(portfolioProvider.notifier);
        await portfolioNotifier.updateHoldingPrices();
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Force refresh all data
  Future<void> forceRefresh() async {
    await Future.wait([
      _updatePortfolio(),
      _updateMarketData(),
      _updatePrices(),
    ]);
  }

  /// Update specific asset prices
  Future<void> updateAssetPrice(String assetId) async {
    try {
      final portfolioNotifier = _ref.read(portfolioProvider.notifier);
      await portfolioNotifier.updateSpecificAssetPrice(assetId);
    } catch (e) {
      // Handle error
    }
  }

  /// Get update status
  bool get isActive => _isActive;

  /// Get next update times
  Map<String, DateTime> getNextUpdateTimes() {
    final now = DateTime.now();
    return {
      'portfolio': now.add(_portfolioUpdateInterval),
      'market': now.add(_marketUpdateInterval),
      'prices': now.add(_priceUpdateInterval),
    };
  }

  /// Set custom update intervals (for testing or different user preferences)
  void setUpdateIntervals({
    Duration? portfolioInterval,
    Duration? marketInterval,
    Duration? priceInterval,
  }) {
    if (portfolioInterval != null) {
      _startPortfolioUpdatesWithInterval(portfolioInterval);
    }
    if (marketInterval != null) {
      _startMarketUpdatesWithInterval(marketInterval);
    }
    if (priceInterval != null) {
      _startPriceUpdatesWithInterval(priceInterval);
    }
  }

  void _startPortfolioUpdatesWithInterval(Duration interval) {
    _portfolioTimer?.cancel();
    _portfolioTimer = Timer.periodic(interval, (_) {
      if (!_isActive) return;
      _updatePortfolio();
    });
  }

  void _startMarketUpdatesWithInterval(Duration interval) {
    _marketTimer?.cancel();
    _marketTimer = Timer.periodic(interval, (_) {
      if (!_isActive) return;
      _updateMarketData();
    });
  }

  void _startPriceUpdatesWithInterval(Duration interval) {
    _priceTimer?.cancel();
    _priceTimer = Timer.periodic(interval, (_) {
      if (!_isActive) return;
      _updatePrices();
    });
  }

  /// Dispose resources
  void dispose() {
    stopUpdates();
  }
}

/// Provider for real-time update status
final realTimeUpdateStatusProvider = StateProvider<RealTimeUpdateStatus>((ref) {
  return RealTimeUpdateStatus(
    isActive: false,
    lastPortfolioUpdate: null,
    lastMarketUpdate: null,
    lastPriceUpdate: null,
  );
});

/// Real-time update status data class
class RealTimeUpdateStatus {
  final bool isActive;
  final DateTime? lastPortfolioUpdate;
  final DateTime? lastMarketUpdate;
  final DateTime? lastPriceUpdate;

  const RealTimeUpdateStatus({
    required this.isActive,
    this.lastPortfolioUpdate,
    this.lastMarketUpdate,
    this.lastPriceUpdate,
  });

  RealTimeUpdateStatus copyWith({
    bool? isActive,
    DateTime? lastPortfolioUpdate,
    DateTime? lastMarketUpdate,
    DateTime? lastPriceUpdate,
  }) {
    return RealTimeUpdateStatus(
      isActive: isActive ?? this.isActive,
      lastPortfolioUpdate: lastPortfolioUpdate ?? this.lastPortfolioUpdate,
      lastMarketUpdate: lastMarketUpdate ?? this.lastMarketUpdate,
      lastPriceUpdate: lastPriceUpdate ?? this.lastPriceUpdate,
    );
  }
}

/// Extension methods for portfolio provider to support real-time updates
extension PortfolioProviderExtensions on PortfolioNotifier {
  /// Update price data for all holdings
  Future<void> updateHoldingPrices() async {
    try {
      final currentState = state;
      if (currentState.holdings.isEmpty) return;

      // Simulate price updates (in real implementation, this would call price APIs)
      final updatedHoldings = currentState.holdings.map((holding) {
        // Simulate small price fluctuations (-2% to +2%)
        final random = DateTime.now().millisecond / 1000.0;
        final priceChange = (random - 0.5) * 0.04; // -2% to +2%
        final newValue = holding.value * (1 + priceChange);
        final newReturnPercent = ((newValue / holding.value) - 1) * 100;

        return holding.copyWith(
          value: newValue,
          returnPercent: holding.returnPercent + newReturnPercent,
          updatedAt: DateTime.now(),
        );
      }).toList();

      // Update state with new holding values
      state = currentState.copyWith(holdings: updatedHoldings);
    } catch (e) {
      // Handle error silently for real-time updates
    }
  }

  /// Update specific asset price
  Future<void> updateSpecificAssetPrice(String assetId) async {
    try {
      final currentState = state;
      final updatedHoldings = currentState.holdings.map((holding) {
        if (holding.assetId == assetId) {
          // Simulate price update for specific asset
          final random = DateTime.now().millisecond / 1000.0;
          final priceChange = (random - 0.5) * 0.04;
          final newValue = holding.value * (1 + priceChange);

          return holding.copyWith(
            value: newValue,
            updatedAt: DateTime.now(),
          );
        }
        return holding;
      }).toList();

      state = currentState.copyWith(holdings: updatedHoldings);
    } catch (e) {
      // Handle error silently
    }
  }
}

/// Extension for Holding to support copyWith
extension HoldingExtensions on Holding {
  Holding copyWith({
    double? value,
    double? returnPercent,
    DateTime? updatedAt,
  }) {
    return Holding(
      assetId: assetId,
      assetTitle: assetTitle,
      assetType: assetType,
      balance: balance,
      value: value ?? this.value,
      returnPercent: returnPercent ?? this.returnPercent,
      monthlyIncome: monthlyIncome,
      lockedBalance: lockedBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}