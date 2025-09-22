import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/brand_model.dart';
import 'auth_provider.dart';

final brandProvider = StateNotifierProvider<BrandNotifier, BrandState>((ref) {
  return BrandNotifier(ref.read(apiClientProvider));
});

class BrandState {
  final List<BrandConfig> brands;
  final BrandConfig? selectedBrand;
  final BrandConfig? activeBrand;
  final String? selectedBankId;
  final bool isLoading;
  final String? error;

  BrandState({
    this.brands = const [],
    this.selectedBrand,
    this.activeBrand,
    this.selectedBankId,
    this.isLoading = false,
    this.error,
  });

  BrandState copyWith({
    List<BrandConfig>? brands,
    BrandConfig? selectedBrand,
    BrandConfig? activeBrand,
    String? selectedBankId,
    bool? isLoading,
    String? error,
  }) {
    return BrandState(
      brands: brands ?? this.brands,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      activeBrand: activeBrand ?? this.activeBrand,
      selectedBankId: selectedBankId ?? this.selectedBankId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BrandNotifier extends StateNotifier<BrandState> {
  final ApiClient _apiClient;

  BrandNotifier(this._apiClient) : super(BrandState());

  Future<void> loadBrands({String? bankId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final brands = await _apiClient.getAllBrands(bankId: bankId);
      state = state.copyWith(
        brands: brands.map((brand) => BrandConfig.fromJson(brand)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBrandById(String brandId) async {
    try {
      final brand = await _apiClient.getBrandById(brandId);
      state = state.copyWith(
        selectedBrand: BrandConfig.fromJson(brand),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createBrand(BrandConfig brandConfig) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newBrand = await _apiClient.createBrand(brandConfig.toJson());
      final updatedBrands = List<BrandConfig>.from(state.brands);
      updatedBrands.add(BrandConfig.fromJson(newBrand));

      state = state.copyWith(
        brands: updatedBrands,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateBrand(String brandId, BrandConfig brandConfig) async {
    try {
      final updatedBrand = await _apiClient.updateBrand(brandId, brandConfig.toJson());

      final updatedBrands = state.brands.map((brand) {
        if (brand.id == brandId) {
          return BrandConfig.fromJson(updatedBrand);
        }
        return brand;
      }).toList();

      state = state.copyWith(
        brands: updatedBrands,
        selectedBrand: state.selectedBrand?.id == brandId
            ? BrandConfig.fromJson(updatedBrand)
            : state.selectedBrand,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteBrand(String brandId) async {
    try {
      await _apiClient.deleteBrand(brandId);

      final updatedBrands = state.brands.where((brand) => brand.id != brandId).toList();

      state = state.copyWith(
        brands: updatedBrands,
        selectedBrand: state.selectedBrand?.id == brandId ? null : state.selectedBrand,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> activateBrand(String brandId, String bankId) async {
    try {
      await _apiClient.activateBrand(brandId, bankId);

      // Update brand active status in local state
      final updatedBrands = state.brands.map((brand) {
        if (brand.bankId == bankId) {
          return brand.copyWith(isActive: brand.id == brandId);
        }
        return brand;
      }).toList();

      final activeBrand = updatedBrands.firstWhere(
        (brand) => brand.id == brandId,
        orElse: () => state.activeBrand!,
      );

      state = state.copyWith(
        brands: updatedBrands,
        activeBrand: activeBrand,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String> uploadBrandAsset(String brandId, String assetType, List<int> fileBytes, String fileName) async {
    try {
      final uploadUrl = await _apiClient.uploadBrandAsset(brandId, assetType, fileBytes, fileName);
      return uploadUrl;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void selectBrand(String brandId) {
    final brand = state.brands.firstWhere(
      (brand) => brand.id == brandId,
      orElse: () => throw Exception('Brand not found'),
    );
    state = state.copyWith(selectedBrand: brand);
  }

  void selectBankId(String bankId) {
    state = state.copyWith(selectedBankId: bankId);
    loadBrands(bankId: bankId);
  }

  void clearSelection() {
    state = state.copyWith(
      selectedBrand: null,
      selectedBankId: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper getters
  List<BrandConfig> getBrandsForBank(String bankId) {
    return state.brands.where((brand) => brand.bankId == bankId).toList();
  }

  BrandConfig? getActiveBrandForBank(String bankId) {
    return state.brands
        .where((brand) => brand.bankId == bankId && brand.isActive)
        .firstOrNull;
  }

  List<BrandConfig> get pendingBrands {
    return state.brands.where((brand) => !brand.isActive).toList();
  }

  List<BrandConfig> get activeBrands {
    return state.brands.where((brand) => brand.isActive).toList();
  }
}