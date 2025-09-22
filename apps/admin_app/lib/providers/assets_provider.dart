import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import 'auth_provider.dart';

final assetsProvider = StateNotifierProvider<AssetsNotifier, AssetsState>((ref) {
  return AssetsNotifier(ref.read(apiClientProvider));
});

class AssetsState {
  final List<Map<String, dynamic>> assets;
  final bool isLoading;
  final String? error;
  final int total;
  final bool hasMore;
  final Map<String, dynamic>? selectedAsset;

  AssetsState({
    this.assets = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.hasMore = false,
    this.selectedAsset,
  });

  AssetsState copyWith({
    List<Map<String, dynamic>>? assets,
    bool? isLoading,
    String? error,
    int? total,
    bool? hasMore,
    Map<String, dynamic>? selectedAsset,
  }) {
    return AssetsState(
      assets: assets ?? this.assets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      selectedAsset: selectedAsset ?? this.selectedAsset,
    );
  }
}

class AssetsNotifier extends StateNotifier<AssetsState> {
  final ApiClient _apiClient;
  
  AssetsNotifier(this._apiClient) : super(AssetsState());

  Future<void> loadAssets({
    String? type,
    String? status,
    int limit = 20,
    int offset = 0,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiClient.getAssets(
        type: type,
        status: status,
        limit: limit,
        offset: offset,
      );

      final List<Map<String, dynamic>> newAssets = 
          (response as List).cast<Map<String, dynamic>>();

      List<Map<String, dynamic>> allAssets;
      if (loadMore) {
        allAssets = [...state.assets, ...newAssets];
      } else {
        allAssets = newAssets;
      }

      state = state.copyWith(
        assets: allAssets,
        isLoading: false,
        hasMore: newAssets.length == limit,
        total: state.total + newAssets.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAsset(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final asset = await _apiClient.getAsset(id);
      state = state.copyWith(
        selectedAsset: asset,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createAsset(Map<String, dynamic> assetData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newAsset = await _apiClient.createAsset(assetData);
      state = state.copyWith(
        assets: [newAsset, ...state.assets],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateAsset(int id, Map<String, dynamic> assetData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAsset = await _apiClient.updateAsset(id, assetData);
      
      final updatedAssets = state.assets.map((asset) {
        if (asset['id'] == id) {
          return updatedAsset;
        }
        return asset;
      }).toList();

      state = state.copyWith(
        assets: updatedAssets,
        selectedAsset: state.selectedAsset?['id'] == id ? updatedAsset : state.selectedAsset,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> verifyAsset(int id, bool approved, String? notes) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiClient.verifyAsset(id, approved, notes);
      
      // Update the asset status in the list
      final updatedAssets = state.assets.map((asset) {
        if (asset['id'] == id) {
          return {
            ...asset,
            'status': approved ? 'active' : 'rejected',
            'verification_notes': notes,
          };
        }
        return asset;
      }).toList();

      state = state.copyWith(
        assets: updatedAssets,
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

  void clearSelectedAsset() {
    state = state.copyWith(selectedAsset: null);
  }

  // Filter helpers
  List<Map<String, dynamic>> get pendingAssets =>
      state.assets.where((asset) => asset['status'] == 'pending').toList();

  List<Map<String, dynamic>> get activeAssets =>
      state.assets.where((asset) => asset['status'] == 'active').toList();

  List<Map<String, dynamic>> get rejectedAssets =>
      state.assets.where((asset) => asset['status'] == 'rejected').toList();

  Map<String, int> get assetsByType {
    final Map<String, int> types = {};
    for (final asset in state.assets) {
      final type = asset['type'] as String;
      types[type] = (types[type] ?? 0) + 1;
    }
    return types;
  }

  double get totalPortfolioValue {
    return state.assets.fold<double>(0.0, (sum, asset) {
      final nav = asset['nav'];
      if (nav is num) return sum + nav.toDouble();
      return sum;
    });
  }
}