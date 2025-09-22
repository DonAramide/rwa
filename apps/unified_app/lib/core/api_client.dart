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
    // Demo credentials for testing
    final demoCredentials = {
      'investor@example.com': 'password123',
      'admin@example.com': 'password123',
      'agent@example.com': 'password123',
      'verifier@example.com': 'password123',
    };

    // Check if it's a demo login
    if (demoCredentials.containsKey(email) && demoCredentials[email] == password) {
      // Return mock successful login response
      return {
        'token': 'demo_token_${email.split('@')[0]}_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': email.split('@')[0],
          'email': email,
          'firstName': email.split('@')[0].toUpperCase(),
          'lastName': 'Demo',
        },
        'message': 'Login successful'
      };
    }

    // Try actual API login for real credentials
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      // If API is not available and not demo credentials, throw error
      throw ApiException(
        statusCode: 401,
        message: 'Invalid credentials or API unavailable',
        details: {'error': 'Authentication failed'},
      );
    }
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
    try {
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
    } catch (e) {
      // Fallback to mock data if backend is not available
      return _getMockAgentsResponse(limit: limit, offset: offset, regions: regions, skills: skills, minRating: minRating);
    }
  }

  // Verification endpoints
  static Future<Map<String, dynamic>> createVerificationJob({
    required String assetId,
    required String agentId,
    required double price,
    required String currency,
  }) async {
    try {
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
    } catch (e) {
      // Fallback to mock data if backend is not available
      return _getMockVerificationJobResponse(assetId, agentId, price, currency);
    }
  }

  // ROFR (Right of First Refusal) endpoints
  static Future<Map<String, dynamic>> createRofrOffer(Map<String, dynamic> offerData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rofr/offers'),
      headers: _headers,
      body: jsonEncode(offerData),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getUserRofrOffers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rofr/offers/user'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> submitRofrResponse(Map<String, dynamic> responseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rofr/responses'),
      headers: _headers,
      body: jsonEncode(responseData),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getAssetShareholders(String assetId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/assets/$assetId/shareholders'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getRofrNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rofr/notifications'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> sendRofrNotification(Map<String, dynamic> notificationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rofr/notifications'),
      headers: _headers,
      body: jsonEncode(notificationData),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> markRofrNotificationAsRead(String notificationId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/rofr/notifications/$notificationId/read'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> listOnMarket(Map<String, dynamic> marketData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/market/listings'),
      headers: _headers,
      body: jsonEncode(marketData),
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

  // Investor verification endpoints
  static Future<Map<String, dynamic>> getVerificationStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/verification/status'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> submitVerification(Map<String, dynamic> verificationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/submit'),
      headers: _headers,
      body: jsonEncode(verificationData),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> uploadVerificationDocument({
    required String type,
    required String filename,
    required List<int> fileBytes,
  }) async {
    // Simulate file upload for demo
    await Future.delayed(const Duration(seconds: 1));

    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'url': 'https://example.com/uploads/$filename',
      'type': type,
      'filename': filename,
      'uploadDate': DateTime.now().toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> requestProfessionalVerification(Map<String, dynamic> requestData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/professional-request'),
      headers: _headers,
      body: jsonEncode(requestData),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> approveVerification({
    required String verificationId,
    required String reviewerId,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/$verificationId/approve'),
      headers: _headers,
      body: jsonEncode({
        'reviewerId': reviewerId,
        'notes': notes,
        'approvalDate': DateTime.now().toIso8601String(),
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> rejectVerification({
    required String verificationId,
    required String reviewerId,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verification/$verificationId/reject'),
      headers: _headers,
      body: jsonEncode({
        'reviewerId': reviewerId,
        'reason': reason,
        'rejectionDate': DateTime.now().toIso8601String(),
      }),
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

  // Mock data methods
  static Map<String, dynamic> _getMockAgentsResponse({
    int limit = 20,
    int offset = 0,
    List<String>? regions,
    List<String>? skills,
    double? minRating,
  }) {
    final mockAgents = [
      {
        'id': '1',
        'userId': 'user1',
        'status': 'approved',
        'regions': ['New York', 'California', 'Texas'],
        'skills': ['Real Estate', 'Property Inspection', 'Commercial'],
        'bio': 'Experienced real estate professional with 10+ years in property verification and asset evaluation.',
        'kycLevel': 'Level 3',
        'ratingAvg': 4.8,
        'ratingCount': 47,
        'createdAt': '2023-01-15T10:30:00Z',
      },
      {
        'id': '2',
        'userId': 'user2',
        'status': 'approved',
        'regions': ['Florida', 'Georgia', 'Alabama'],
        'skills': ['Automotive', 'Heavy Machinery', 'Equipment'],
        'bio': 'Certified automotive and machinery inspector specializing in high-value asset verification.',
        'kycLevel': 'Level 3',
        'ratingAvg': 4.9,
        'ratingCount': 63,
        'createdAt': '2023-02-20T14:15:00Z',
      },
      {
        'id': '3',
        'userId': 'user3',
        'status': 'approved',
        'regions': ['Washington', 'Oregon', 'California'],
        'skills': ['Land', 'Agriculture', 'Environmental'],
        'bio': 'Environmental scientist and certified land surveyor with expertise in agricultural property assessment.',
        'kycLevel': 'Level 2',
        'ratingAvg': 4.6,
        'ratingCount': 28,
        'createdAt': '2023-03-10T09:45:00Z',
      },
      {
        'id': '4',
        'userId': 'user4',
        'status': 'approved',
        'regions': ['Illinois', 'Michigan', 'Ohio'],
        'skills': ['Industrial', 'Warehousing', 'Logistics'],
        'bio': 'Industrial asset specialist with background in warehouse and logistics facility verification.',
        'kycLevel': 'Level 3',
        'ratingAvg': 4.7,
        'ratingCount': 35,
        'createdAt': '2023-01-28T16:20:00Z',
      },
      {
        'id': '5',
        'userId': 'user5',
        'status': 'approved',
        'regions': ['Nevada', 'Arizona', 'Utah'],
        'skills': ['Luxury Assets', 'Art', 'Collectibles'],
        'bio': 'Fine art and luxury asset appraiser with certification in high-value collectible verification.',
        'kycLevel': 'Level 3',
        'ratingAvg': 4.9,
        'ratingCount': 52,
        'createdAt': '2023-02-05T11:30:00Z',
      },
      // Field Verifiers
      {
        'id': '6',
        'userId': 'user6',
        'status': 'approved',
        'regions': ['New York', 'New Jersey', 'Connecticut'],
        'skills': ['Field Verification', 'Photo Documentation', 'GPS Tracking'],
        'bio': 'Local field verifier specializing in on-site asset verification and photo documentation.',
        'kycLevel': 'Level 1',
        'ratingAvg': 4.3,
        'ratingCount': 89,
        'createdAt': '2023-03-15T08:20:00Z',
      },
      {
        'id': '7',
        'userId': 'user7',
        'status': 'approved',
        'regions': ['California', 'Oregon', 'Washington'],
        'skills': ['Field Verification', 'Video Documentation', 'Location Tracking'],
        'bio': 'Mobile field verifier with expertise in video documentation and real-time location verification.',
        'kycLevel': 'Level 1',
        'ratingAvg': 4.5,
        'ratingCount': 134,
        'createdAt': '2023-04-01T12:45:00Z',
      },
      {
        'id': '8',
        'userId': 'user8',
        'status': 'approved',
        'regions': ['Texas', 'Louisiana', 'Oklahoma'],
        'skills': ['Field Verification', 'Rapid Response', 'Drone Photography'],
        'bio': 'Fast-response field verifier offering same-day verification with drone photography capabilities.',
        'kycLevel': 'Level 2',
        'ratingAvg': 4.7,
        'ratingCount': 76,
        'createdAt': '2023-03-28T15:10:00Z',
      },
    ];

    // Apply filters if provided
    var filteredAgents = mockAgents.where((agent) {
      if (regions != null && regions.isNotEmpty) {
        final agentRegions = List<String>.from(agent['regions'] as List);
        if (!agentRegions.any((region) => regions.contains(region))) return false;
      }
      if (skills != null && skills.isNotEmpty) {
        final agentSkills = List<String>.from(agent['skills'] as List);
        if (!agentSkills.any((skill) => skills.contains(skill))) return false;
      }
      if (minRating != null && (agent['ratingAvg'] as double) < minRating) return false;
      return true;
    }).toList();

    // Apply pagination
    final startIndex = offset;
    final endIndex = (startIndex + limit).clamp(0, filteredAgents.length);
    final paginatedAgents = filteredAgents.sublist(startIndex, endIndex);

    return {
      'items': paginatedAgents,
      'total': filteredAgents.length,
      'hasMore': endIndex < filteredAgents.length,
      'limit': limit,
      'offset': offset,
    };
  }

  static Map<String, dynamic> _getMockVerificationJobResponse(
    String assetId,
    String agentId,
    double price,
    String currency,
  ) {
    return {
      'id': 'job_${DateTime.now().millisecondsSinceEpoch}',
      'assetId': assetId,
      'investorId': 'current_user_id',
      'agentId': agentId,
      'status': 'pending',
      'price': price,
      'currency': currency,
      'slaDueAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
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