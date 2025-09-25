import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/asset.dart';

/// Provider for managing the user's watchlist
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, WatchlistState>((ref) {
  return WatchlistNotifier();
});

/// Provider to check if a specific asset is in the watchlist
final isInWatchlistProvider = Provider.family<bool, String>((ref, assetId) {
  final watchlist = ref.watch(watchlistProvider);
  return watchlist.watchlistAssets.any((asset) => asset.id.toString() == assetId);
});

/// Provider for watchlist assets count
final watchlistCountProvider = Provider<int>((ref) {
  final watchlist = ref.watch(watchlistProvider);
  return watchlist.watchlistAssets.length;
});

class WatchlistNotifier extends StateNotifier<WatchlistState> {
  static const String _storageKey = 'watchlist_assets';

  WatchlistNotifier() : super(const WatchlistState()) {
    _loadWatchlist();
  }

  /// Load watchlist from local storage
  Future<void> _loadWatchlist() async {
    try {
      state = state.copyWith(isLoading: true);

      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList(_storageKey) ?? [];

      final List<Asset> assets = [];
      for (final jsonString in watchlistJson) {
        try {
          final assetData = jsonDecode(jsonString) as Map<String, dynamic>;
          final asset = Asset.fromJson(assetData);
          assets.add(asset);
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }

      state = state.copyWith(
        watchlistAssets: assets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load watchlist: $e',
      );
    }
  }

  /// Save watchlist to local storage
  Future<void> _saveWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = state.watchlistAssets
          .map((asset) => jsonEncode(asset.toJson()))
          .toList();

      await prefs.setStringList(_storageKey, watchlistJson);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save watchlist: $e');
    }
  }

  /// Add an asset to the watchlist
  Future<void> addToWatchlist(Asset asset) async {
    try {
      // Check if asset is already in watchlist
      final isAlreadyAdded = state.watchlistAssets
          .any((existingAsset) => existingAsset.id == asset.id);

      if (isAlreadyAdded) {
        state = state.copyWith(error: 'Asset is already in your watchlist');
        return;
      }

      // Add asset to watchlist
      final updatedAssets = [...state.watchlistAssets, asset];

      state = state.copyWith(
        watchlistAssets: updatedAssets,
        error: null,
      );

      await _saveWatchlist();
    } catch (e) {
      state = state.copyWith(error: 'Failed to add to watchlist: $e');
    }
  }

  /// Remove an asset from the watchlist
  Future<void> removeFromWatchlist(String assetId) async {
    try {
      final updatedAssets = state.watchlistAssets
          .where((asset) => asset.id.toString() != assetId)
          .toList();

      state = state.copyWith(
        watchlistAssets: updatedAssets,
        error: null,
      );

      await _saveWatchlist();
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove from watchlist: $e');
    }
  }

  /// Toggle asset in watchlist
  Future<void> toggleWatchlist(Asset asset) async {
    final isInWatchlist = state.watchlistAssets
        .any((existingAsset) => existingAsset.id == asset.id);

    if (isInWatchlist) {
      await removeFromWatchlist(asset.id.toString());
    } else {
      await addToWatchlist(asset);
    }
  }

  /// Clear all assets from watchlist
  Future<void> clearWatchlist() async {
    try {
      state = state.copyWith(watchlistAssets: []);
      await _saveWatchlist();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear watchlist: $e');
    }
  }

  /// Refresh watchlist data (reload from storage)
  Future<void> refreshWatchlist() async {
    await _loadWatchlist();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update asset data in watchlist (useful when asset details change)
  Future<void> updateAssetInWatchlist(Asset updatedAsset) async {
    try {
      final updatedAssets = state.watchlistAssets.map((asset) {
        return asset.id == updatedAsset.id ? updatedAsset : asset;
      }).toList();

      state = state.copyWith(watchlistAssets: updatedAssets);
      await _saveWatchlist();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update asset: $e');
    }
  }

  /// Get watchlist analytics
  WatchlistAnalytics getAnalytics() {
    final assets = state.watchlistAssets;

    if (assets.isEmpty) {
      return const WatchlistAnalytics(
        totalAssets: 0,
        averageNav: 0,
        assetTypes: {},
        locations: {},
      );
    }

    // Calculate average NAV
    final totalNav = assets.fold<double>(0, (sum, asset) {
      final nav = double.tryParse(asset.nav) ?? 0;
      return sum + nav;
    });
    final averageNav = totalNav / assets.length;

    // Count asset types
    final Map<String, int> assetTypes = {};
    for (final asset in assets) {
      assetTypes[asset.type] = (assetTypes[asset.type] ?? 0) + 1;
    }

    // Count locations
    final Map<String, int> locations = {};
    for (final asset in assets) {
      final location = asset.location?.city ?? 'Unknown';
      locations[location] = (locations[location] ?? 0) + 1;
    }

    return WatchlistAnalytics(
      totalAssets: assets.length,
      averageNav: averageNav,
      assetTypes: assetTypes,
      locations: locations,
    );
  }
}

/// Watchlist state class
class WatchlistState {
  final List<Asset> watchlistAssets;
  final bool isLoading;
  final String? error;

  const WatchlistState({
    this.watchlistAssets = const [],
    this.isLoading = false,
    this.error,
  });

  WatchlistState copyWith({
    List<Asset>? watchlistAssets,
    bool? isLoading,
    String? error,
  }) {
    return WatchlistState(
      watchlistAssets: watchlistAssets ?? this.watchlistAssets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Watchlist analytics data class
class WatchlistAnalytics {
  final int totalAssets;
  final double averageNav;
  final Map<String, int> assetTypes;
  final Map<String, int> locations;

  const WatchlistAnalytics({
    required this.totalAssets,
    required this.averageNav,
    required this.assetTypes,
    required this.locations,
  });
}

/// Extension to add toJson/fromJson methods to Asset if not present
extension AssetJson on Asset {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'spvId': spvId,
      'status': status,
      'nav': nav,
      'verificationRequired': verificationRequired,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
      'location': location?.toJson(),
    };
  }

  static Asset fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      spvId: json['spvId'] as String,
      status: json['status'] as String,
      nav: json['nav'] as String,
      verificationRequired: json['verificationRequired'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images: List<String>.from(json['images'] as List? ?? []),
      location: json['location'] != null
          ? AssetLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}

extension AssetLocationJson on AssetLocation {
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
    };
  }

  static AssetLocation fromJson(Map<String, dynamic> json) {
    return AssetLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
    );
  }
}