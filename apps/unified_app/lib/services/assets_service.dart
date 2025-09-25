import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asset.dart';

class AssetsService {
  static const String baseUrl = 'http://localhost:3000/v1';

  // Asset filters
  static Future<List<Asset>> getAssets({
    int limit = 20,
    int offset = 0,
    String? type,
    String? status,
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    // For now, return mock data. In real app, this would call:
    // final response = await http.get(Uri.parse('$baseUrl/assets'));

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 400));

    // Generate dynamic mock data based on filters
    final List<Asset> mockAssets = _generateMockAssets();

    // Apply filters
    List<Asset> filteredAssets = mockAssets;

    if (type != null && type.isNotEmpty && type != 'All Types') {
      filteredAssets = filteredAssets.where((asset) =>
        asset.type.toLowerCase() == type.toLowerCase()).toList();
    }

    if (status != null && status.isNotEmpty && status != 'All Status') {
      filteredAssets = filteredAssets.where((asset) =>
        asset.status.toLowerCase() == status.toLowerCase()).toList();
    }

    if (category != null && category.isNotEmpty && category != 'All Categories') {
      filteredAssets = filteredAssets.where((asset) =>
        asset.type.toLowerCase().contains(category.toLowerCase())).toList();
    }

    if (search != null && search.isNotEmpty) {
      filteredAssets = filteredAssets.where((asset) =>
        asset.title.toLowerCase().contains(search.toLowerCase()) ||
        (asset.description?.toLowerCase().contains(search.toLowerCase()) ?? false)
      ).toList();
    }

    if (minPrice != null) {
      filteredAssets = filteredAssets.where((asset) =>
        asset.nav != null && double.tryParse(asset.nav) != null && double.parse(asset.nav) >= minPrice).toList();
    }

    if (maxPrice != null) {
      filteredAssets = filteredAssets.where((asset) =>
        asset.nav != null && double.tryParse(asset.nav) != null && double.parse(asset.nav) <= maxPrice).toList();
    }

    // Apply pagination
    final startIndex = offset;
    final endIndex = (offset + limit).clamp(0, filteredAssets.length);

    if (startIndex >= filteredAssets.length) {
      return [];
    }

    return filteredAssets.sublist(startIndex, endIndex);
  }

  static Future<Asset?> getAsset(String id) async {
    // For now, return mock data. In real app, this would call:
    // final response = await http.get(Uri.parse('$baseUrl/assets/$id'));

    await Future.delayed(const Duration(milliseconds: 300));

    final allAssets = _generateMockAssets();
    try {
      return allAssets.firstWhere((asset) => asset.id.toString() == id);
    } catch (e) {
      return null;
    }
  }

  static Future<int> getAssetsCount({
    String? type,
    String? status,
    String? search,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final assets = await getAssets(
      limit: 1000, // Get all for counting
      type: type,
      status: status,
      search: search,
      category: category,
    );

    return assets.length;
  }

  static Future<void> createAsset(Map<String, dynamic> assetData) async {
    // In real app, this would call:
    // await http.post(Uri.parse('$baseUrl/assets'), body: jsonEncode(assetData));

    await Future.delayed(const Duration(milliseconds: 600));
    // Mock success
  }

  static Future<void> updateAsset(String id, Map<String, dynamic> assetData) async {
    // In real app, this would call:
    // await http.put(Uri.parse('$baseUrl/assets/$id'), body: jsonEncode(assetData));

    await Future.delayed(const Duration(milliseconds: 500));
    // Mock success
  }

  static Future<void> deleteAsset(String id) async {
    // In real app, this would call:
    // await http.delete(Uri.parse('$baseUrl/assets/$id'));

    await Future.delayed(const Duration(milliseconds: 400));
    // Mock success
  }

  static Future<void> verifyAsset(String id) async {
    // In real app, this would call:
    // await http.patch(Uri.parse('$baseUrl/assets/$id/verify'));

    await Future.delayed(const Duration(milliseconds: 500));
    // Mock success
  }

  // Generate mock assets for demonstration
  static List<Asset> _generateMockAssets() {
    final now = DateTime.now();

    return [
      Asset(
        id: 1001,
        title: 'Luxury Villa in Beverly Hills',
        type: 'Real Estate',
        spvId: 'SPV-1001-RE',
        status: 'active',
        nav: '2500000',
        verificationRequired: true,
        createdAt: now.subtract(const Duration(days: 30)),
        description: 'Stunning 5-bedroom luxury villa with pool and panoramic city views',
        location: AssetLocation(
          latitude: 34.0522,
          longitude: -118.4004,
          address: '1234 Sunset Blvd',
          city: 'Beverly Hills',
          state: 'CA',
          country: 'USA',
        ),
      ),
      Asset(
        id: 1002,
        title: 'Modern Family Home',
        type: 'Real Estate',
        spvId: 'SPV-1002-RE',
        status: 'active',
        nav: '850000',
        verificationRequired: true,
        createdAt: now.subtract(const Duration(days: 25)),
        description: 'Contemporary 4-bedroom family home in prime location',
        location: AssetLocation(
          latitude: 40.7831,
          longitude: -73.9851,
          address: '456 Park Ave',
          city: 'New York',
          state: 'NY',
          country: 'USA',
        ),
      ),
      Asset(
        id: 1003,
        title: 'Manhattan Penthouse',
        type: 'Real Estate',
        spvId: 'SPV-1003-RE',
        status: 'active',
        nav: '4200000',
        verificationRequired: true,
        createdAt: now.subtract(const Duration(days: 20)),
        description: 'Exclusive penthouse with 360-degree city views',
        location: AssetLocation(
          latitude: 40.7614,
          longitude: -73.9776,
          address: '789 Fifth Ave',
          city: 'New York',
          state: 'NY',
          country: 'USA',
        ),
      ),
      Asset(
        id: 1004,
        title: 'Downtown Loft Complex',
        type: 'Real Estate',
        spvId: 'SPV-1004-RE',
        status: 'pending',
        nav: '1800000',
        verificationRequired: true,
        createdAt: now.subtract(const Duration(days: 15)),
        description: 'Modern loft complex in the heart of downtown',
        location: AssetLocation(
          latitude: 41.8781,
          longitude: -87.6298,
          address: '321 State St',
          city: 'Chicago',
          state: 'IL',
          country: 'USA',
        ),
      ),
      Asset(
        id: 2001,
        title: 'Luxury Sports Car Collection',
        type: 'Transportation',
        spvId: 'SPV-2001-TR',
        status: 'active',
        nav: '3500000',
        verificationRequired: true,
        createdAt: now.subtract(const Duration(days: 10)),
        description: 'Premium collection of luxury sports cars',
        location: AssetLocation(
        latitude: 43.7384,
        longitude: 7.4246,
        address: "Monaco Garage",
        city: "Monaco",
        state: "Monaco",
        country: "Monaco",
        ),
      ),
      Asset(
        id: 2002,
        title: 'Commercial Fleet Vehicles',
        type: 'Transportation',
        spvId: 'SPV-2002-TR',
        status: 'active',
        nav: '850000',
        verificationRequired: true,
        createdAt: now.subtract(const Duration(days: 8)),
        description: 'Fleet of commercial delivery vehicles',
        location: AssetLocation(
        latitude: 52.5200,
        longitude: 13.4050,
        address: 'Berlin Distribution Center',
        city: 'Berlin',
        state: 'Berlin',
        country: 'Germany',
        ),
      ),
      Asset(
        id: 3001,
        title: 'Gold Investment Portfolio',
        type: 'Precious Metals',
        spvId: 'SPV-3001-PM',
        status: 'active',
        nav: '2100000',
        verificationRequired: true,
        createdAt: now.subtract(const Duration(days: 5)),
        description: 'Diversified gold investment portfolio',
        location: AssetLocation(
        latitude: 51.5074,
        longitude: -0.1278,
        address: 'London Bullion Vault',
        city: 'London',
        state: 'England',
        country: 'UK',
        ),
      ),
      Asset(
        id: 4001,
        title: 'Tech Startup Equity',
        type: 'Financial',
        spvId: 'SPV-4001-FI',
        status: 'active',
        nav: '1200000',
        verificationRequired: true,
        createdAt: now.subtract(const Duration(days: 3)),
        description: 'Equity stake in promising tech startup',
        location: AssetLocation(
        latitude: 37.7749,
        longitude: -122.4194,
        address: 'Market Street',
        city: 'San Francisco',
        state: 'CA',
        country: 'USA',
        ),
        
        
      ),
    ];
  }

  // Get asset categories
  static Future<List<String>> getAssetCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));

    return [
      'All Categories',
      'Real Estate',
      'Transportation',
      'Precious Metals',
      'Financial',
      'Technology',
      'Agriculture',
    ];
  }

  // Get asset types
  static Future<List<String>> getAssetTypes() async {
    await Future.delayed(const Duration(milliseconds: 100));

    return [
      'All Types',
      'House',
      'Apartment',
      'Commercial',
      'Car',
      'Truck',
      'Fleet',
      'Gold',
      'Silver',
      'Equity',
      'Bond',
    ];
  }
}