import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

// Asset model
class Asset {
  final String id;
  final String type;
  final String title;
  final String? description;
  final double? nav; // Net Asset Value
  final String status;
  final List<String> documents;
  final bool verificationRequired;
  final DateTime? lastVerifiedAt;
  final DateTime createdAt;
  final Map<String, dynamic>? coordinates;
  final Map<String, dynamic>? metadata;

  const Asset({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.nav,
    required this.status,
    required this.documents,
    required this.verificationRequired,
    this.lastVerifiedAt,
    required this.createdAt,
    this.coordinates,
    this.metadata,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'].toString(),
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      nav: json['nav'] != null ? double.tryParse(json['nav'].toString()) : null,
      status: json['status'] as String,
      documents: List<String>.from(json['documents'] ?? []),
      verificationRequired: json['verification_required'] as bool? ?? false,
      lastVerifiedAt: json['lastVerifiedAt'] != null 
          ? DateTime.parse(json['lastVerifiedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      coordinates: json['coordinates'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

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
      final response = await ApiClient.getAssets(
        limit: 20,
        offset: refresh ? 0 : state.assets.length,
        type: type ?? state.selectedType,
        status: status ?? state.selectedStatus,
        search: search,
      );

      final List<Asset> newAssets = (response['items'] as List)
          .map((json) => Asset.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        assets: refresh ? newAssets : [...state.assets, ...newAssets],
        hasMore: response['hasMore'] as bool,
        total: response['total'] as int,
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
      final response = await ApiClient.getAsset(id);
      return Asset.fromJson(response);
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