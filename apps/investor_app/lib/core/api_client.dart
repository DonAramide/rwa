import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/v1';
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verify2FA({
    required String token,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/2fa/verify'),
      headers: _headers,
      body: jsonEncode({
        'token': token,
        'code': code,
      }),
    );
    return _handleResponse(response);
  }

  // KYC endpoints
  static Future<Map<String, dynamic>> submitKYC({
    required Map<String, dynamic> kycData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/kyc/submit'),
      headers: _headers,
      body: jsonEncode(kycData),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getKYCStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/kyc/status'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Assets endpoints
  static Future<Map<String, dynamic>> getAssets({
    int limit = 20,
    int offset = 0,
    String? type,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/assets').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getAsset(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/assets/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Wallet endpoints
  static Future<Map<String, dynamic>> linkWallet({
    required String address,
    required String chainId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wallet/link'),
      headers: _headers,
      body: jsonEncode({
        'address': address,
        'chainId': chainId,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getWalletBalances() async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/balances'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Investment endpoints
  static Future<Map<String, dynamic>> getHoldings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/invest/holdings'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Marketplace endpoints
  static Future<Map<String, dynamic>> getOrderbook(String assetId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orderbook/$assetId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> createOrder({
    required String assetId,
    required String side,
    required double quantity,
    required double price,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers,
      body: jsonEncode({
        'assetId': assetId,
        'side': side,
        'quantity': quantity,
        'price': price,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Revenue endpoints
  static Future<Map<String, dynamic>> getDistributions(String assetId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/distributions/$assetId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // IoT endpoints
  static Future<Map<String, dynamic>> getAssetTelemetry({
    required String assetId,
    int limit = 100,
    int offset = 0,
  }) async {
    final queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    final uri = Uri.parse('$baseUrl/assets/$assetId/telemetry').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  // Agents endpoints
  static Future<Map<String, dynamic>> searchAgents({
    int limit = 20,
    int offset = 0,
    List<String>? regions,
    List<String>? skills,
    double? minRating,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (regions != null && regions.isNotEmpty) {
      queryParams['regions'] = regions.join(',');
    }
    if (skills != null && skills.isNotEmpty) {
      queryParams['skills'] = skills.join(',');
    }
    if (minRating != null) {
      queryParams['minRating'] = minRating.toString();
    }

    final uri = Uri.parse('$baseUrl/agents/search').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  // Verification endpoints
  static Future<Map<String, dynamic>> createVerificationJob({
    required String assetId,
    required String agentId,
    required double price,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/jobs'),
      headers: _headers,
      body: jsonEncode({
        'assetId': assetId,
        'agentId': agentId,
        'price': price,
        'currency': currency,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getVerificationReport(String reportId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/verification/reports/$reportId'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Helper method to handle responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = response.body.isNotEmpty 
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      throw ApiException(
        statusCode: response.statusCode,
        message: errorBody['message'] ?? 'Unknown error occurred',
        details: errorBody,
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic> details;

  ApiException({
    required this.statusCode,
    required this.message,
    required this.details,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}