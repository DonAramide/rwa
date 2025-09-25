import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset.dart';
import '../services/assets_service.dart';

// Assets state
class AssetsState {
  final bool isLoading;
  final List<Asset> assets;
  final String? error;
  final bool hasMore;
  final int total;
  final String? selectedType;
  final String? selectedStatus;

  const AssetsState({
    this.isLoading = false,
    this.assets = const [],
    this.error,
    this.hasMore = false,
    this.total = 0,
    this.selectedType,
    this.selectedStatus,
  });

  AssetsState copyWith({
    bool? isLoading,
    List<Asset>? assets,
    String? error,
    bool? hasMore,
    int? total,
    String? selectedType,
    String? selectedStatus,
  }) {
    return AssetsState(
      isLoading: isLoading ?? this.isLoading,
      assets: assets ?? this.assets,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

// Assets notifier
class AssetsNotifier extends StateNotifier<AssetsState> {
  AssetsNotifier() : super(const AssetsState());

  Future<void> loadAssets({
    bool refresh = false,
    String? type,
    String? status,
    String? search,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        assets: [],
        error: null,
        selectedType: type,
        selectedStatus: status,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // Use comprehensive asset data instead of API call for demo
      final allAssetData = ComprehensiveAssetData.getAllAssets();

      // Apply filters
      List<Map<String, dynamic>> filteredData = allAssetData;

      if (type != null) {
        filteredData = filteredData.where((asset) =>
          asset['type'].toString().toLowerCase() == type.toLowerCase()).toList();
      }

      if (status != null) {
        filteredData = filteredData.where((asset) =>
          asset['status'].toString().toLowerCase() == status.toLowerCase()).toList();
      }

      if (search != null && search.isNotEmpty) {
        filteredData = filteredData.where((asset) =>
          asset['title'].toString().toLowerCase().contains(search.toLowerCase()) ||
          (asset['description']?.toString().toLowerCase().contains(search.toLowerCase()) ?? false)
        ).toList();
      }

      // Pagination simulation
      final offset = refresh ? 0 : state.assets.length;
      final limit = 20;
      final endIndex = (offset + limit).clamp(0, filteredData.length);
      final pageData = filteredData.sublist(offset, endIndex);

      final List<Asset> newAssets = pageData
          .map((json) => Asset.fromJson(json))
          .toList();

      state = state.copyWith(
        isLoading: false,
        assets: refresh ? newAssets : [...state.assets, ...newAssets],
        hasMore: endIndex < filteredData.length,
        total: filteredData.length,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Asset> loadAsset(String id) async {
    try {
      // Use comprehensive asset data instead of API call for demo
      final allAssetData = ComprehensiveAssetData.getAllAssets();
      final assetData = allAssetData.firstWhere(
        (asset) => asset['id'].toString() == id,
        orElse: () => throw Exception('Asset not found'),
      );

      return Asset.fromJson(assetData);
    } catch (e) {
      throw Exception('Failed to load asset: $e');
    }
  }

  void setFilters({String? type, String? status}) {
    state = state.copyWith(
      selectedType: type,
      selectedStatus: status,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      selectedType: null,
      selectedStatus: null,
    );
  }
}

// Providers
final assetsProvider = StateNotifierProvider<AssetsNotifier, AssetsState>((ref) {
  return AssetsNotifier();
});

// Computed providers
final filteredAssetsProvider = Provider<List<Asset>>((ref) {
  final assets = ref.watch(assetsProvider).assets;
  final type = ref.watch(assetsProvider).selectedType;
  final status = ref.watch(assetsProvider).selectedStatus;

  return assets.where((asset) {
    if (type != null && asset.type != type) return false;
    if (status != null && asset.status != status) return false;
    return true;
  }).toList();
});

final assetTypesProvider = Provider<List<String>>((ref) {
  final assets = ref.watch(assetsProvider).assets;
  return assets.map((asset) => asset.type).toSet().toList()..sort();
});

final assetStatusesProvider = Provider<List<String>>((ref) {
  final assets = ref.watch(assetsProvider).assets;
  return assets.map((asset) => asset.status).toSet().toList()..sort();
});