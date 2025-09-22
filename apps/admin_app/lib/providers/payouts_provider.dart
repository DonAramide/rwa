import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import 'auth_provider.dart';

final payoutsProvider = StateNotifierProvider<PayoutsNotifier, PayoutsState>((ref) {
  return PayoutsNotifier(ref.read(apiClientProvider));
});

class PayoutsState {
  final List<Map<String, dynamic>> distributions;
  final bool isLoading;
  final String? error;
  final int total;
  final bool hasMore;
  final Map<String, dynamic>? selectedDistribution;

  PayoutsState({
    this.distributions = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.hasMore = false,
    this.selectedDistribution,
  });

  PayoutsState copyWith({
    List<Map<String, dynamic>>? distributions,
    bool? isLoading,
    String? error,
    int? total,
    bool? hasMore,
    Map<String, dynamic>? selectedDistribution,
  }) {
    return PayoutsState(
      distributions: distributions ?? this.distributions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      selectedDistribution: selectedDistribution ?? this.selectedDistribution,
    );
  }
}

class PayoutsNotifier extends StateNotifier<PayoutsState> {
  final ApiClient _apiClient;
  
  PayoutsNotifier(this._apiClient) : super(PayoutsState());

  Future<void> loadDistributions({
    int? assetId,
    String? period,
    int limit = 20,
    int offset = 0,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiClient.getDistributions(
        assetId: assetId,
        period: period,
        limit: limit,
        offset: offset,
      );

      final List<Map<String, dynamic>> newDistributions = 
          (response as List).cast<Map<String, dynamic>>();

      List<Map<String, dynamic>> allDistributions;
      if (loadMore) {
        allDistributions = [...state.distributions, ...newDistributions];
      } else {
        allDistributions = newDistributions;
      }

      state = state.copyWith(
        distributions: allDistributions,
        isLoading: false,
        hasMore: newDistributions.length == limit,
        total: state.total + newDistributions.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> triggerPayout(int assetId, double amount, String period) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newDistribution = await _apiClient.triggerPayout(assetId, amount, period);
      
      state = state.copyWith(
        distributions: [newDistribution, ...state.distributions],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelectedDistribution() {
    state = state.copyWith(selectedDistribution: null);
  }

  // Analytics helpers
  List<Map<String, dynamic>> get recentDistributions {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    return state.distributions.where((dist) {
      final createdAt = DateTime.parse(dist['created_at'] as String);
      return createdAt.isAfter(thirtyDaysAgo);
    }).toList();
  }

  double get totalPayoutsThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return state.distributions
        .where((dist) {
          final createdAt = DateTime.parse(dist['created_at'] as String);
          return createdAt.isAfter(startOfMonth);
        })
        .fold<double>(0.0, (sum, dist) {
          final net = dist['net'];
          if (net is num) return sum + net.toDouble();
          return sum;
        });
  }

  double get totalPayoutsAllTime {
    return state.distributions.fold<double>(0.0, (sum, dist) {
      final net = dist['net'];
      if (net is num) return sum + net.toDouble();
      return sum;
    });
  }

  Map<String, double> get payoutsByPeriod {
    final Map<String, double> periods = {};
    
    for (final dist in state.distributions) {
      final period = dist['period'] as String;
      final net = dist['net'];
      if (net is num) {
        periods[period] = (periods[period] ?? 0.0) + net.toDouble();
      }
    }
    
    return periods;
  }

  Map<int, double> get payoutsByAsset {
    final Map<int, double> assets = {};
    
    for (final dist in state.distributions) {
      final assetId = dist['asset_id'] as int;
      final net = dist['net'];
      if (net is num) {
        assets[assetId] = (assets[assetId] ?? 0.0) + net.toDouble();
      }
    }
    
    return assets;
  }

  List<Map<String, dynamic>> get pendingPayouts {
    return state.distributions
        .where((dist) => dist['status'] == 'pending')
        .toList();
  }

  List<Map<String, dynamic>> get completedPayouts {
    return state.distributions
        .where((dist) => dist['status'] == 'completed')
        .toList();
  }

  List<Map<String, dynamic>> get failedPayouts {
    return state.distributions
        .where((dist) => dist['status'] == 'failed')
        .toList();
  }
}