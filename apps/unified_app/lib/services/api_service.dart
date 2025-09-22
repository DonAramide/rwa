import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asset.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/v1';

  static Future<AssetResponse> getAssets({
    String? type,
    String? status,
    String? search,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    if (location != null) queryParams['location'] = location;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    final uri = Uri.parse('$baseUrl/assets').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AssetResponse.fromJson(data);
      } else {
        throw Exception('Failed to load assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load assets: $e');
    }
  }

  static Future<Asset> getAsset(int id) async {
    final uri = Uri.parse('$baseUrl/assets/$id');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Asset.fromJson(data);
      } else {
        throw Exception('Failed to load asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load asset: $e');
    }
  }
}