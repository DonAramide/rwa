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
  final String? selectedCategory;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final DateTime? lastUpdated;

  const AssetsState({
    this.isLoading = false,
    this.assets = const [],
    this.error,
    this.hasMore = false,
    this.total = 0,
    this.selectedType,
    this.selectedStatus,
    this.selectedCategory,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.lastUpdated,
  });

  AssetsState copyWith({
    bool? isLoading,
    List<Asset>? assets,
    String? error,
    bool? hasMore,
    int? total,
    String? selectedType,
    String? selectedStatus,
    String? selectedCategory,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    DateTime? lastUpdated,
  }) {
    return AssetsState(
      isLoading: isLoading ?? this.isLoading,
      assets: assets ?? this.assets,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasData => assets.isNotEmpty;
  bool get isStale => lastUpdated == null ||
    DateTime.now().difference(lastUpdated!).inMinutes > 10;

  Map<String, dynamic> get activeFilters {
    final filters = <String, dynamic>{};
    if (selectedType != null && selectedType != 'All Types') {
      filters['type'] = selectedType;
    }
    if (selectedStatus != null && selectedStatus != 'All Status') {
      filters['status'] = selectedStatus;
    }
    if (selectedCategory != null && selectedCategory != 'All Categories') {
      filters['category'] = selectedCategory;
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filters['search'] = searchQuery;
    }
    if (minPrice != null) {
      filters['minPrice'] = minPrice;
    }
    if (maxPrice != null) {
      filters['maxPrice'] = maxPrice;
    }
    return filters;
  }

  bool get hasActiveFilters => activeFilters.isNotEmpty;
}

// Assets notifier
class AssetsNotifier extends StateNotifier<AssetsState> {
  AssetsNotifier() : super(const AssetsState());

  Future<void> loadAssets({
    bool refresh = false,
    String? type,
    String? status,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    // Don't reload if data is fresh and no filters changed
    if (!refresh && state.hasData && !state.isStale && !_filtersChanged(
      type: type,
      status: status,
      category: category,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
    )) {
      return;
    }

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        assets: [],
        error: null,
        hasMore: false,
        selectedType: type,
        selectedStatus: status,
        selectedCategory: category,
        searchQuery: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // Load assets and total count in parallel
      final results = await Future.wait([
        AssetsService.getAssets(
          limit: 20,
          offset: refresh ? 0 : state.assets.length,
          type: type ?? state.selectedType,
          status: status ?? state.selectedStatus,
          category: category ?? state.selectedCategory,
          search: search ?? state.searchQuery,
          minPrice: minPrice ?? state.minPrice,
          maxPrice: maxPrice ?? state.maxPrice,
        ),
        AssetsService.getAssetsCount(
          type: type ?? state.selectedType,
          status: status ?? state.selectedStatus,
          category: category ?? state.selectedCategory,
          search: search ?? state.searchQuery,
        ),
      ]);

      final newAssets = results[0] as List<Asset>;
      final totalCount = results[1] as int;

      final allAssets = refresh ? newAssets : [...state.assets, ...newAssets];

      state = state.copyWith(
        isLoading: false,
        assets: allAssets,
        hasMore: allAssets.length < totalCount,
        total: totalCount,
        selectedType: type ?? state.selectedType,
        selectedStatus: status ?? state.selectedStatus,
        selectedCategory: category ?? state.selectedCategory,
        searchQuery: search ?? state.searchQuery,
        minPrice: minPrice ?? state.minPrice,
        maxPrice: maxPrice ?? state.maxPrice,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreAssets() async {
    if (state.isLoading || !state.hasMore) return;

    try {
      state = state.copyWith(isLoading: true);

      final newAssets = await AssetsService.getAssets(
        limit: 20,
        offset: state.assets.length,
        type: state.selectedType,
        status: state.selectedStatus,
        category: state.selectedCategory,
        search: state.searchQuery,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
      );

      final allAssets = [...state.assets, ...newAssets];

      state = state.copyWith(
        isLoading: false,
        assets: allAssets,
        hasMore: allAssets.length < state.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchAssets(String query) async {
    await loadAssets(refresh: true, search: query);
  }

  Future<void> filterAssets({
    String? type,
    String? status,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    await loadAssets(
      refresh: true,
      type: type,
      status: status,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Future<void> clearFilters() async {
    await loadAssets(refresh: true);
  }

  Future<void> createAsset(Map<String, dynamic> assetData) async {
    try {
      await AssetsService.createAsset(assetData);
      // Refresh the list to include the new asset
      await loadAssets(refresh: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create asset: $e');
    }
  }

  Future<void> updateAsset(String id, Map<String, dynamic> assetData) async {
    try {
      await AssetsService.updateAsset(id, assetData);
      // Refresh the list to show updated data
      await loadAssets(refresh: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update asset: $e');
    }
  }

  Future<void> deleteAsset(String id) async {
    try {
      await AssetsService.deleteAsset(id);
      // Remove the asset from the current list
      final updatedAssets = state.assets.where((asset) => asset.id.toString() != id).toList();
      state = state.copyWith(
        assets: updatedAssets,
        total: state.total - 1,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete asset: $e');
    }
  }

  Future<void> verifyAsset(String id) async {
    try {
      await AssetsService.verifyAsset(id);
      // Update the asset status in the current list
      final updatedAssets = state.assets.map((asset) {
        if (asset.id.toString() == id) {
          return Asset(
            id: asset.id,
            title: asset.title,
            type: asset.type,
            spvId: asset.spvId,
            status: 'verified',
            nav: asset.nav,
            verificationRequired: asset.verificationRequired,
            createdAt: asset.createdAt,
            images: asset.images,
            description: asset.description,
            location: asset.location,
            category: asset.category,
            subCategory: asset.subCategory,
          );
        }
        return asset;
      }).toList();

      state = state.copyWith(assets: updatedAssets);
    } catch (e) {
      state = state.copyWith(error: 'Failed to verify asset: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const AssetsState();
  }

  Future<void> setFilters({
    String? type,
    String? status,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    await loadAssets(
      refresh: true,
      type: type,
      status: status,
      category: category,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  bool _filtersChanged({
    String? type,
    String? status,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) {
    return type != state.selectedType ||
           status != state.selectedStatus ||
           category != state.selectedCategory ||
           search != state.searchQuery ||
           minPrice != state.minPrice ||
           maxPrice != state.maxPrice;
  }
}

// Provider
final assetsProvider = StateNotifierProvider<AssetsNotifier, AssetsState>(
  (ref) => AssetsNotifier(),
);

// Computed providers for specific data
final assetsListProvider = Provider<List<Asset>>((ref) {
  return ref.watch(assetsProvider).assets;
});

final assetsCountProvider = Provider<int>((ref) {
  return ref.watch(assetsProvider).total;
});

final assetsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(assetsProvider).isLoading;
});

final assetsErrorProvider = Provider<String?>((ref) {
  return ref.watch(assetsProvider).error;
});

final assetsFiltersProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(assetsProvider).activeFilters;
});

final hasMoreAssetsProvider = Provider<bool>((ref) {
  return ref.watch(assetsProvider).hasMore;
});

// Asset categories and types providers
final assetCategoriesProvider = FutureProvider<List<String>>((ref) async {
  return await AssetsService.getAssetCategories();
});

final assetTypesProvider = FutureProvider<List<String>>((ref) async {
  return await AssetsService.getAssetTypes();
});

// Single asset provider
final singleAssetProvider = FutureProvider.family<Asset?, String>((ref, id) async {
  return await AssetsService.getAsset(id);
});

// Auto-refresh provider
final autoRefreshAssetsProvider = Provider<void>((ref) {
  final notifier = ref.read(assetsProvider.notifier);

  // Load initial data
  notifier.loadAssets();

  // Set up periodic refresh every 5 minutes
  final timer = Stream.periodic(const Duration(minutes: 5));
  ref.listen<int>(
    Provider((ref) => DateTime.now().millisecondsSinceEpoch ~/ (5 * 60 * 1000)),
    (previous, next) {
      notifier.loadAssets();
    },
  );
});