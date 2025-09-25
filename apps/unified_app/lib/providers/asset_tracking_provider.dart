import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

// Asset telemetry models
class AssetTelemetry {
  final String id;
  final String assetId;
  final String metric;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AssetTelemetry({
    required this.id,
    required this.assetId,
    required this.metric,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata,
  });

  factory AssetTelemetry.fromJson(Map<String, dynamic> json) {
    return AssetTelemetry(
      id: json['id'].toString(),
      assetId: json['assetId'].toString(),
      metric: json['metric'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

// Price update model
class PriceUpdate {
  final String assetId;
  final double currentPrice;
  final double previousPrice;
  final double changeAmount;
  final double changePercent;
  final DateTime timestamp;

  const PriceUpdate({
    required this.assetId,
    required this.currentPrice,
    required this.previousPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.timestamp,
  });

  factory PriceUpdate.fromJson(Map<String, dynamic> json) {
    return PriceUpdate(
      assetId: json['assetId'].toString(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      previousPrice: (json['previousPrice'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// Asset tracking state
class AssetTrackingState {
  final bool isConnected;
  final Map<String, List<AssetTelemetry>> telemetryData;
  final Map<String, PriceUpdate> priceUpdates;
  final Map<String, bool> subscribedAssets;
  final String? error;

  const AssetTrackingState({
    this.isConnected = false,
    this.telemetryData = const {},
    this.priceUpdates = const {},
    this.subscribedAssets = const {},
    this.error,
  });

  AssetTrackingState copyWith({
    bool? isConnected,
    Map<String, List<AssetTelemetry>>? telemetryData,
    Map<String, PriceUpdate>? priceUpdates,
    Map<String, bool>? subscribedAssets,
    String? error,
  }) {
    return AssetTrackingState(
      isConnected: isConnected ?? this.isConnected,
      telemetryData: telemetryData ?? this.telemetryData,
      priceUpdates: priceUpdates ?? this.priceUpdates,
      subscribedAssets: subscribedAssets ?? this.subscribedAssets,
      error: error ?? this.error,
    );
  }
}

// Asset tracking notifier
class AssetTrackingNotifier extends StateNotifier<AssetTrackingState> {
  AssetTrackingNotifier() : super(const AssetTrackingState());

  Timer? _connectionTimer;
  Timer? _pollingTimer;

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> startTracking() async {
    if (state.isConnected) return;

    state = state.copyWith(isConnected: true, error: null);

    // Start periodic polling for real-time updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _pollForUpdates();
    });

    // Simulate connection heartbeat
    _connectionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkConnection();
    });

    // Initial data load
    await _pollForUpdates();
  }

  void stopTracking() {
    _connectionTimer?.cancel();
    _pollingTimer?.cancel();
    state = state.copyWith(isConnected: false);
  }

  Future<void> subscribeToAsset(String assetId) async {
    final updatedSubscriptions = Map<String, bool>.from(state.subscribedAssets);
    updatedSubscriptions[assetId] = true;

    state = state.copyWith(subscribedAssets: updatedSubscriptions);

    // Load initial telemetry data for this asset
    await _loadAssetTelemetry(assetId);
  }

  void unsubscribeFromAsset(String assetId) {
    final updatedSubscriptions = Map<String, bool>.from(state.subscribedAssets);
    updatedSubscriptions.remove(assetId);

    final updatedTelemetry = Map<String, List<AssetTelemetry>>.from(state.telemetryData);
    updatedTelemetry.remove(assetId);

    final updatedPrices = Map<String, PriceUpdate>.from(state.priceUpdates);
    updatedPrices.remove(assetId);

    state = state.copyWith(
      subscribedAssets: updatedSubscriptions,
      telemetryData: updatedTelemetry,
      priceUpdates: updatedPrices,
    );
  }

  Future<void> _loadAssetTelemetry(String assetId) async {
    try {
      final response = await ApiClient.getAssetTelemetry(
        assetId: assetId,
        limit: 100,
      );

      final telemetryItems = response['items'] as List? ?? [];
      final telemetryData = telemetryItems
          .map((json) => AssetTelemetry.fromJson(json as Map<String, dynamic>))
          .toList();

      final updatedTelemetryData = Map<String, List<AssetTelemetry>>.from(state.telemetryData);
      updatedTelemetryData[assetId] = telemetryData;

      state = state.copyWith(telemetryData: updatedTelemetryData);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load telemetry for asset $assetId: $e');
    }
  }

  Future<void> _pollForUpdates() async {
    if (!state.isConnected || state.subscribedAssets.isEmpty) return;

    try {
      // Poll for price updates for all subscribed assets
      for (final assetId in state.subscribedAssets.keys) {
        await _updateAssetPrice(assetId);
        await _updateAssetTelemetry(assetId);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to poll for updates: $e');
    }
  }

  Future<void> _updateAssetPrice(String assetId) async {
    try {
      // Note: This would typically be a WebSocket connection or real-time API
      // For now, we'll use a polling approach with the asset detail endpoint
      final assetResponse = await ApiClient.getAsset(assetId);
      final nav = assetResponse['nav'] as double?;

      if (nav != null) {
        final currentPrice = state.priceUpdates[assetId];
        final previousPrice = currentPrice?.currentPrice ?? nav;

        final changeAmount = nav - previousPrice;
        final changePercent = previousPrice > 0 ? (changeAmount / previousPrice) * 100 : 0.0;

        final priceUpdate = PriceUpdate(
          assetId: assetId,
          currentPrice: nav,
          previousPrice: previousPrice,
          changeAmount: changeAmount,
          changePercent: changePercent,
          timestamp: DateTime.now(),
        );

        final updatedPrices = Map<String, PriceUpdate>.from(state.priceUpdates);
        updatedPrices[assetId] = priceUpdate;

        state = state.copyWith(priceUpdates: updatedPrices);
      }
    } catch (e) {
      // Don't update error state for individual asset failures during polling
      print('Failed to update price for asset $assetId: $e');
    }
  }

  Future<void> _updateAssetTelemetry(String assetId) async {
    try {
      // Get latest telemetry data (only recent entries)
      final lastTelemetryTime = state.telemetryData[assetId]?.first.timestamp ?? DateTime.now().subtract(const Duration(hours: 1));

      final response = await ApiClient.getAssetTelemetry(
        assetId: assetId,
        limit: 10,
      );

      final telemetryItems = response['items'] as List? ?? [];
      final newTelemetryData = telemetryItems
          .map((json) => AssetTelemetry.fromJson(json as Map<String, dynamic>))
          .where((telemetry) => telemetry.timestamp.isAfter(lastTelemetryTime))
          .toList();

      if (newTelemetryData.isNotEmpty) {
        final updatedTelemetryData = Map<String, List<AssetTelemetry>>.from(state.telemetryData);
        final existingData = updatedTelemetryData[assetId] ?? [];

        // Add new data and keep only the latest 100 entries
        final combinedData = [...newTelemetryData, ...existingData].take(100).toList();
        updatedTelemetryData[assetId] = combinedData;

        state = state.copyWith(telemetryData: updatedTelemetryData);
      }
    } catch (e) {
      // Don't update error state for individual asset failures during polling
      print('Failed to update telemetry for asset $assetId: $e');
    }
  }

  void _checkConnection() {
    // Simulate connection health check
    // In a real implementation, this would ping the WebSocket or real-time service
    if (!state.isConnected) {
      startTracking();
    }
  }

  List<AssetTelemetry> getTelemetryForAsset(String assetId, {String? metric}) {
    final telemetryData = state.telemetryData[assetId] ?? [];
    if (metric != null) {
      return telemetryData.where((data) => data.metric == metric).toList();
    }
    return telemetryData;
  }

  PriceUpdate? getPriceUpdateForAsset(String assetId) {
    return state.priceUpdates[assetId];
  }

  bool isTrackingAsset(String assetId) {
    return state.subscribedAssets.containsKey(assetId);
  }
}

// Providers
final assetTrackingProvider = StateNotifierProvider<AssetTrackingNotifier, AssetTrackingState>((ref) {
  return AssetTrackingNotifier();
});

// Computed providers
final isTrackingConnectedProvider = Provider<bool>((ref) {
  return ref.watch(assetTrackingProvider).isConnected;
});

final trackedAssetsCountProvider = Provider<int>((ref) {
  return ref.watch(assetTrackingProvider).subscribedAssets.length;
});

final latestPriceUpdatesProvider = Provider<List<PriceUpdate>>((ref) {
  return ref.watch(assetTrackingProvider).priceUpdates.values.toList();
});

// Provider factory for specific asset telemetry
final assetTelemetryProvider = Provider.family<List<AssetTelemetry>, String>((ref, assetId) {
  return ref.watch(assetTrackingProvider).telemetryData[assetId] ?? [];
});

// Provider factory for specific asset price updates
final assetPriceUpdateProvider = Provider.family<PriceUpdate?, String>((ref, assetId) {
  return ref.watch(assetTrackingProvider).priceUpdates[assetId];
});