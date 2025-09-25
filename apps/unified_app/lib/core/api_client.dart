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
      'superadmin@example.com': 'password123',
      'bank@example.com': 'password123',
      'bankadmin@example.com': 'password123',
      'bankops@example.com': 'password123',
    };

    // Check if it's a demo login
    if (demoCredentials.containsKey(email) && demoCredentials[email] == password) {
      // Map email to appropriate role
      String role;
      String firstName;
      String lastName;

      switch (email) {
        case 'investor@example.com':
          role = 'investor';
          firstName = 'Demo';
          lastName = 'Investor';
          break;
        case 'admin@example.com':
          role = 'admin';
          firstName = 'Demo';
          lastName = 'Admin';
          break;
        case 'agent@example.com':
          role = 'professional_agent';
          firstName = 'Demo';
          lastName = 'Agent';
          break;
        case 'verifier@example.com':
          role = 'verifier';
          firstName = 'Demo';
          lastName = 'Verifier';
          break;
        case 'superadmin@example.com':
          role = 'super_admin';
          firstName = 'Super';
          lastName = 'Admin';
          break;
        case 'bank@example.com':
          role = 'bank_white_label';
          firstName = 'Merchant';
          lastName = 'Partner';
          break;
        case 'bankadmin@example.com':
          role = 'bank_admin';
          firstName = 'Merchant';
          lastName = 'Admin';
          break;
        case 'bankops@example.com':
          role = 'bank_operations';
          firstName = 'Merchant';
          lastName = 'Operations';
          break;
        default:
          role = 'investor';
          firstName = 'Demo';
          lastName = 'User';
      }

      // Return mock successful login response
      return {
        'token': 'demo_token_${email.split('@')[0]}_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': email.split('@')[0],
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invest/holdings'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock portfolio data if backend is not available
      return _getMockPortfolioResponse();
    }
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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/distributions/$assetId'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock distributions data if backend is not available
      return _getMockDistributionsResponse(assetId);
    }
  }

  // Portfolio Analytics endpoints
  static Future<Map<String, dynamic>> getPortfolioPerformance({
    String period = '6M', // 1M, 3M, 6M, 1Y, ALL
    bool includeBenchmark = true,
  }) async {
    try {
      final queryParams = {
        'period': period,
        'includeBenchmark': includeBenchmark.toString(),
      };
      final uri = Uri.parse('$baseUrl/portfolio/performance').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return _getMockPerformanceResponse(period, includeBenchmark);
    }
  }

  static Future<Map<String, dynamic>> getPortfolioAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final uri = Uri.parse('$baseUrl/portfolio/analytics').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return _getMockAnalyticsResponse();
    }
  }

  static Future<Map<String, dynamic>> getAssetPerformance({
    required String assetId,
    String period = '6M',
  }) async {
    try {
      final queryParams = {'period': period};
      final uri = Uri.parse('$baseUrl/assets/$assetId/performance').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return _getMockAssetPerformanceResponse(assetId, period);
    }
  }

  static Future<Map<String, dynamic>> getPortfolioDiversification() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/portfolio/diversification'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return _getMockDiversificationResponse();
    }
  }

  static Future<Map<String, dynamic>> getBenchmarkComparison({
    String benchmark = 'SP500',
    String period = '1Y',
  }) async {
    try {
      final queryParams = {
        'benchmark': benchmark,
        'period': period,
      };
      final uri = Uri.parse('$baseUrl/portfolio/benchmark').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return _getMockBenchmarkResponse(benchmark, period);
    }
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

  // Notification endpoints
  static Future<Map<String, dynamic>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      // Return mock notifications if API is unavailable
      return _getMockNotificationsResponse(limit: limit, offset: offset);
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return success for demo purposes
      return {'success': true};
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return success for demo purposes
      return {'success': true};
    }
  }

  static Future<Map<String, dynamic>> createInvestment({
    required String assetId,
    required double amount,
    String? verificationMethod,
    String? agentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/investments'),
        headers: _headers,
        body: jsonEncode({
          'assetId': assetId,
          'amount': amount,
          'verificationMethod': verificationMethod,
          'agentId': agentId,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock investment response for demo
      return _getMockInvestmentResponse(assetId, amount);
    }
  }

  static Map<String, dynamic> _getMockNotificationsResponse({
    int limit = 20,
    int offset = 0,
  }) {
    final mockNotifications = [
      {
        'id': '1',
        'title': 'Investment Successful',
        'message': 'Your investment of \$5,000 in Luxury Apartment Complex has been processed.',
        'type': 'investment',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'assetId': '1',
        'actionUrl': '/portfolio',
      },
      {
        'id': '2',
        'title': 'Price Alert',
        'message': 'Commercial Property A has increased by 5.2% in the last 24 hours.',
        'type': 'price_alert',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'assetId': '2',
        'actionUrl': '/asset/2',
      },
      {
        'id': '3',
        'title': 'Asset Update',
        'message': 'New telemetry data available for Smart Vehicle Fleet.',
        'type': 'asset_update',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'assetId': '3',
        'actionUrl': '/asset/3/telemetry',
      },
      {
        'id': '4',
        'title': 'Portfolio Update',
        'message': 'Monthly distribution of \$125.50 credited to your account.',
        'type': 'portfolio',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'actionUrl': '/portfolio',
      },
      {
        'id': '5',
        'title': 'Verification Complete',
        'message': 'Agent verification for Industrial Warehouse completed successfully.',
        'type': 'system',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'assetId': '4',
        'actionUrl': '/asset/4',
      },
    ];

    // Apply pagination
    final startIndex = offset;
    final endIndex = (startIndex + limit).clamp(0, mockNotifications.length);
    final paginatedNotifications = mockNotifications.sublist(startIndex, endIndex);

    return {
      'items': paginatedNotifications,
      'total': mockNotifications.length,
      'hasMore': endIndex < mockNotifications.length,
      'limit': limit,
      'offset': offset,
    };
  }

  static Map<String, dynamic> _getMockInvestmentResponse(String assetId, double amount) {
    return {
      'id': 'investment_${DateTime.now().millisecondsSinceEpoch}',
      'assetId': assetId,
      'amount': amount,
      'status': 'pending',
      'transactionId': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now().toIso8601String(),
      'message': 'Investment created successfully',
    };
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

  // API Key Management endpoints
  static Future<Map<String, dynamic>> getApiKeys() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/api-keys'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock API keys if backend is not available
      return _getMockApiKeysResponse();
    }
  }

  static Future<Map<String, dynamic>> createApiKey(Map<String, dynamic> apiKeyData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/api-keys'),
        headers: _headers,
        body: jsonEncode(apiKeyData),
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock created API key if backend is not available
      return _getMockCreateApiKeyResponse(apiKeyData);
    }
  }

  static Future<Map<String, dynamic>> updateApiKey(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/api-keys/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock updated API key if backend is not available
      return _getMockUpdateApiKeyResponse(id, updates);
    }
  }

  static Future<void> deleteApiKey(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/api-keys/$id'),
        headers: _headers,
      );
      _handleResponse(response);
    } catch (e) {
      // Success for demo purposes
    }
  }

  static Future<Map<String, dynamic>> getApiCallLogs(String apiKeyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/api-keys/$apiKeyId/logs'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock call logs if backend is not available
      return _getMockApiCallLogsResponse(apiKeyId);
    }
  }

  // Mock data methods for API key management
  static Map<String, dynamic> _getMockApiKeysResponse() {
    return {
      'items': [
        {
          'id': '1',
          'name': 'Google Maps Production',
          'service': 'google_maps',
          'key': 'AIzaSyCTNAinlHZiX9ZfHs77v_hyeUKkObhsm6k',
          'description': 'Google Maps API for asset location mapping and verification',
          'isActive': true,
          'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'lastUsed': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'permissions': ['maps', 'geocoding', 'places'],
        },
        {
          'id': '2',
          'name': 'Stripe Payments',
          'service': 'stripe',
          'key': 'sk_live_51J5rQ2...',
          'description': 'Stripe API for processing payments and transactions',
          'isActive': true,
          'createdAt': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
          'lastUsed': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
          'permissions': ['payments', 'refunds', 'customers'],
        },
        {
          'id': '3',
          'name': 'Twilio SMS',
          'service': 'twilio',
          'key': 'AC234567890abcdef1234567890abcdef',
          'description': 'Twilio API for SMS notifications and 2FA',
          'isActive': false,
          'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
          'lastUsed': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'permissions': ['sms', 'voice'],
        },
      ],
    };
  }

  static Map<String, dynamic> _getMockCreateApiKeyResponse(Map<String, dynamic> apiKeyData) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': apiKeyData['name'],
      'service': apiKeyData['service'],
      'key': apiKeyData['key'],
      'description': apiKeyData['description'],
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'permissions': apiKeyData['permissions'],
    };
  }

  static Map<String, dynamic> _getMockUpdateApiKeyResponse(String id, Map<String, dynamic> updates) {
    return {
      'id': id,
      'name': updates['name'] ?? 'Updated API Key',
      'service': updates['service'] ?? 'custom',
      'key': updates['key'] ?? 'updated_key',
      'description': updates['description'],
      'isActive': updates['isActive'] ?? true,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'permissions': updates['permissions'] ?? [],
    };
  }

  static Map<String, dynamic> _getMockApiCallLogsResponse(String apiKeyId) {
    return {
      'items': [
        {
          'id': '1',
          'apiKeyId': apiKeyId,
          'endpoint': '/geocoding/v1/json',
          'method': 'GET',
          'statusCode': 200,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
          'responseTime': 120.5,
        },
        {
          'id': '2',
          'apiKeyId': apiKeyId,
          'endpoint': '/maps/api/js',
          'method': 'GET',
          'statusCode': 200,
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'responseTime': 85.2,
        },
        {
          'id': '3',
          'apiKeyId': apiKeyId,
          'endpoint': '/places/v1/autocomplete',
          'method': 'GET',
          'statusCode': 403,
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          'responseTime': 45.8,
          'errorMessage': 'API key quota exceeded',
        },
      ],
    };
  }

  // Merchant Admin endpoints
  static Future<Map<String, dynamic>> getMerchantProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bank/profile'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock bank profile if backend is not available
      return _getMockMerchantProfileResponse();
    }
  }

  static Future<Map<String, dynamic>> updateMerchantProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bank/profile'),
        headers: _headers,
        body: jsonEncode(profileData),
      );
      return _handleResponse(response);
    } catch (e) {
      // Return updated mock profile if backend is not available
      return _getMockMerchantProfileResponse();
    }
  }

  static Future<Map<String, dynamic>> getMerchantDashboard({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final uri = Uri.parse('$baseUrl/bank/analytics/dashboard').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      // Return mock dashboard analytics if backend is not available
      return _getMockMerchantDashboardResponse();
    }
  }

  static Future<Map<String, dynamic>> getMerchantCustomers({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/bank/customers').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      // Return mock customers if backend is not available
      return _getMockMerchantCustomersResponse(page: page, limit: limit, status: status);
    }
  }

  static Future<Map<String, dynamic>> getMerchantTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (type != null) queryParams['type'] = type;

      final uri = Uri.parse('$baseUrl/bank/transactions').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      // Return mock transactions if backend is not available
      return _getMockMerchantTransactionsResponse(page: page, limit: limit, type: type);
    }
  }

  static Future<Map<String, dynamic>> getMerchantAssetProposals({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/bank/asset-proposals').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      // Return mock proposals if backend is not available
      return _getMockMerchantProposalsResponse(page: page, limit: limit, status: status);
    }
  }

  static Future<Map<String, dynamic>> submitMerchantAssetProposal(Map<String, dynamic> proposalData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bank/asset-proposals'),
        headers: _headers,
        body: jsonEncode(proposalData),
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock proposal submission if backend is not available
      return _getMockProposalSubmissionResponse(proposalData);
    }
  }

  static Future<Map<String, dynamic>> getMerchantSettlements({
    int page = 1,
    int limit = 20,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final uri = Uri.parse('$baseUrl/bank/settlements').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      // Return mock settlements if backend is not available
      return _getMockMerchantSettlementsResponse(page: page, limit: limit, status: status);
    }
  }

  static Future<Map<String, dynamic>> updateMerchantBranding(Map<String, dynamic> brandingData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bank/branding'),
        headers: _headers,
        body: jsonEncode(brandingData),
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock branding update if backend is not available
      return _getMockBrandingUpdateResponse(brandingData);
    }
  }

  static Map<String, dynamic> _getMockPortfolioResponse() {
    final holdings = [
      {
        'assetId': '1',
        'assetTitle': 'Premium Office Complex Downtown',
        'assetType': 'commercial',
        'balance': 100.0,
        'lockedBalance': 25.0,
        'value': 12500.0,
        'returnPercent': 8.5,
        'monthlyIncome': 425.0,
        'updatedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'assetId': '2',
        'assetTitle': 'Luxury Residential Apartments',
        'assetType': 'residential',
        'balance': 75.0,
        'lockedBalance': 0.0,
        'value': 15000.0,
        'returnPercent': 12.3,
        'monthlyIncome': 625.0,
        'updatedAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      },
      {
        'assetId': '3',
        'assetTitle': 'Commercial Vehicle Fleet',
        'assetType': 'transport',
        'balance': 200.0,
        'lockedBalance': 50.0,
        'value': 18750.0,
        'returnPercent': 15.2,
        'monthlyIncome': 780.0,
        'updatedAt': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      },
      {
        'assetId': '4',
        'assetTitle': 'Industrial Warehouse Complex',
        'assetType': 'industrial',
        'balance': 150.0,
        'lockedBalance': 10.0,
        'value': 22500.0,
        'returnPercent': 6.8,
        'monthlyIncome': 950.0,
        'updatedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];

    final totalValue = holdings.fold<double>(0.0, (sum, holding) => sum + (holding['value'] as double));
    final totalIncome = holdings.fold<double>(0.0, (sum, holding) => sum + (holding['monthlyIncome'] as double));
    final totalInvested = totalValue * 0.85; // Assume 15% gain overall
    final totalReturn = ((totalValue - totalInvested) / totalInvested) * 100;

    return {
      'summary': {
        'totalValue': totalValue,
        'totalReturn': totalReturn,
        'monthlyIncome': totalIncome,
        'totalHoldings': holdings.length,
        'totalInvested': totalInvested,
      },
      'holdings': holdings,
    };
  }

  static Map<String, dynamic> _getMockDistributionsResponse(String assetId) {
    final distributions = [
      {
        'id': 'dist_${assetId}_1',
        'assetId': assetId,
        'assetTitle': 'Asset Distribution',
        'amount': 125.50,
        'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'status': 'completed',
        'period': 'November 2023',
        'transactionHash': '0x742d35b9cb8b6e08e5e2e41e0f8f6a7b2c6e9d3e4f1e8c6d2a9b7e4f8c6d2a9b',
      },
      {
        'id': 'dist_${assetId}_2',
        'assetId': assetId,
        'assetTitle': 'Asset Distribution',
        'amount': 118.75,
        'date': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'status': 'completed',
        'period': 'October 2023',
        'transactionHash': '0x9b7e4f8c6d2a9b742d35b9cb8b6e08e5e2e41e0f8f6a7b2c6e9d3e4f1e8c6d2a',
      },
      {
        'id': 'dist_${assetId}_3',
        'assetId': assetId,
        'assetTitle': 'Asset Distribution',
        'amount': 142.25,
        'date': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'status': 'completed',
        'period': 'September 2023',
        'transactionHash': '0xe4f1e8c6d2a9b7e4f8c6d2a9b742d35b9cb8b6e08e5e2e41e0f8f6a7b2c6e9d3',
      },
    ];

    return {
      'items': distributions,
      'total': distributions.length,
      'hasMore': false,
    };
  }

  // Mock data methods for Merchant Admin
  static Map<String, dynamic> _getMockMerchantProfileResponse() {
    return {
      'id': 'bank_1',
      'name': 'Premier Investment Merchant',
      'legalName': 'Premier Investment Merchant Limited',
      'registrationNumber': 'PIB2023001',
      'country': 'United States',
      'domain': 'premier-bank.com',
      'subdomain': 'invest',
      'status': 'active',
      'commissionRateBps': 150,
      'revenueShareBps': 3000,
      'contractStartDate': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
      'contractEndDate': DateTime.now().add(const Duration(days: 1095)).toIso8601String(),
      'description': 'Leading provider of real-world asset investment opportunities',
      'contactInfo': {
        'primaryContact': 'John Smith',
        'email': 'admin@premier-bank.com',
        'phone': '+1-555-123-4567',
        'address': '123 Financial District, New York, NY 10004',
      },
      'branding': {
        'logoUrl': 'https://example.com/premier-bank-logo.png',
        'faviconUrl': 'https://example.com/premier-bank-favicon.ico',
        'primaryColor': '#1976d2',
        'secondaryColor': '#42a5f5',
        'themeConfig': {
          'colors': {
            'accent': '#ff5722',
            'success': '#4caf50',
            'warning': '#ff9800',
            'error': '#f44336',
          },
        },
        'customDomain': 'invest.premier-bank.com',
      },
      'createdAt': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    };
  }

  static Map<String, dynamic> _getMockMerchantDashboardResponse() {
    return {
      'totalAum': 12500000.0,
      'activeInvestors': 847,
      'pendingApprovals': 23,
      'revenueEarned': 187500.0,
      'totalAssets': 156,
      'totalInvestments': 2834,
      'completedTransactions': 8921,
      'revenueBreakdown': {
        'commissions': 125000.0,
        'revenueShare': 62500.0,
      },
      'metrics': [
        {
          'label': 'Monthly Growth',
          'value': 8.5,
          'unit': '%',
          'changePercent': 2.3,
          'trend': 'up',
        },
        {
          'label': 'Customer Acquisition',
          'value': 34.0,
          'unit': 'new customers',
          'changePercent': 12.1,
          'trend': 'up',
        },
        {
          'label': 'Average Investment',
          'value': 14750.0,
          'unit': 'USD',
          'changePercent': -3.2,
          'trend': 'down',
        },
        {
          'label': 'Asset Performance',
          'value': 11.2,
          'unit': '% return',
          'changePercent': 0.8,
          'trend': 'up',
        },
      ],
    };
  }

  static Map<String, dynamic> _getMockMerchantCustomersResponse({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    final allCustomers = [
      {
        'id': '1',
        'firstName': 'Alice',
        'lastName': 'Johnson',
        'email': 'alice.johnson@email.com',
        'phone': '+1-555-987-6543',
        'kycStatus': 'approved',
        'totalInvestments': 25000.0,
        'activeAssets': 5,
        'joinedDate': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
        'lastActivity': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'riskLevel': 'moderate',
      },
      {
        'id': '2',
        'firstName': 'Bob',
        'lastName': 'Chen',
        'email': 'bob.chen@email.com',
        'phone': '+1-555-456-7890',
        'kycStatus': 'pending',
        'totalInvestments': 0.0,
        'activeAssets': 0,
        'joinedDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'lastActivity': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'riskLevel': 'low',
      },
      {
        'id': '3',
        'firstName': 'Carol',
        'lastName': 'Williams',
        'email': 'carol.williams@email.com',
        'phone': '+1-555-234-5678',
        'kycStatus': 'approved',
        'totalInvestments': 85000.0,
        'activeAssets': 12,
        'joinedDate': DateTime.now().subtract(const Duration(days: 300)).toIso8601String(),
        'lastActivity': DateTime.now().subtract(const Duration(hours: 24)).toIso8601String(),
        'riskLevel': 'high',
      },
      {
        'id': '4',
        'firstName': 'David',
        'lastName': 'Martinez',
        'email': 'david.martinez@email.com',
        'phone': '+1-555-345-6789',
        'kycStatus': 'rejected',
        'totalInvestments': 0.0,
        'activeAssets': 0,
        'joinedDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'lastActivity': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'riskLevel': 'high',
      },
    ];

    // Filter by status if provided
    var filteredCustomers = allCustomers;
    if (status != null) {
      filteredCustomers = allCustomers.where((customer) => customer['kycStatus'] == status).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, filteredCustomers.length);
    final paginatedCustomers = filteredCustomers.sublist(startIndex, endIndex);

    return {
      'items': paginatedCustomers,
      'total': filteredCustomers.length,
      'hasMore': endIndex < filteredCustomers.length,
      'limit': limit,
      'offset': startIndex,
    };
  }

  static Map<String, dynamic> _getMockMerchantTransactionsResponse({
    int page = 1,
    int limit = 20,
    String? type,
  }) {
    final allTransactions = [
      {
        'id': 'tx_1',
        'customerId': '1',
        'assetId': 'asset_1',
        'type': 'investment',
        'amount': 15000.0,
        'currency': 'USD',
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'processedAt': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)).toIso8601String(),
        'txHash': '0x1234567890abcdef1234567890abcdef12345678',
        'commission': 225.0,
      },
      {
        'id': 'tx_2',
        'customerId': '3',
        'assetId': 'asset_2',
        'type': 'withdrawal',
        'amount': 5000.0,
        'currency': 'USD',
        'status': 'pending',
        'createdAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'processedAt': null,
        'txHash': null,
        'commission': 0.0,
      },
      {
        'id': 'tx_3',
        'customerId': '1',
        'assetId': 'asset_3',
        'type': 'dividend',
        'amount': 750.0,
        'currency': 'USD',
        'status': 'completed',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'processedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'txHash': '0xabcdef1234567890abcdef1234567890abcdef12',
        'commission': 11.25,
      },
    ];

    // Filter by type if provided
    var filteredTransactions = allTransactions;
    if (type != null) {
      filteredTransactions = allTransactions.where((tx) => tx['type'] == type).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, filteredTransactions.length);
    final paginatedTransactions = filteredTransactions.sublist(startIndex, endIndex);

    return {
      'items': paginatedTransactions,
      'total': filteredTransactions.length,
      'hasMore': endIndex < filteredTransactions.length,
      'limit': limit,
      'offset': startIndex,
    };
  }

  static Map<String, dynamic> _getMockMerchantProposalsResponse({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    final allProposals = [
      {
        'id': 'proposal_1',
        'proposerType': 'bank',
        'proposerId': 'bank_admin_1',
        'bankId': 'bank_1',
        'assetDetails': {
          'type': 'real_estate',
          'title': 'Downtown Office Complex',
          'description': 'Premium office space in the financial district',
          'location': {
            'address': '456 Business Ave, Financial District',
            'coordinates': {'lat': 40.7128, 'lng': -74.0060},
            'country': 'United States',
            'state': 'New York',
            'city': 'New York',
          },
          'financials': {
            'estimatedValue': 5000000.0,
            'currency': 'USD',
            'expectedAnnualReturn': 8.5,
            'initialInvestmentTarget': 3000000.0,
          },
        },
        'documents': ['contract.pdf', 'valuation.pdf'],
        'status': 'pending',
        'masterAdminNotes': null,
        'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'proposal_2',
        'proposerType': 'bank',
        'proposerId': 'bank_admin_1',
        'bankId': 'bank_1',
        'assetDetails': {
          'type': 'truck',
          'title': 'Commercial Delivery Fleet',
          'description': 'Fleet of 20 commercial delivery vehicles',
          'location': {
            'address': '789 Industrial Blvd, Warehouse District',
            'coordinates': {'lat': 40.6892, 'lng': -74.0445},
            'country': 'United States',
            'state': 'New York',
            'city': 'Brooklyn',
          },
          'financials': {
            'estimatedValue': 2000000.0,
            'currency': 'USD',
            'expectedAnnualReturn': 12.0,
            'initialInvestmentTarget': 1500000.0,
          },
        },
        'documents': ['fleet_specs.pdf', 'insurance.pdf'],
        'status': 'approved',
        'masterAdminNotes': 'Approved for listing. Vehicle documentation verified.',
        'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'updatedAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      },
    ];

    // Filter by status if provided
    var filteredProposals = allProposals;
    if (status != null) {
      filteredProposals = allProposals.where((proposal) => proposal['status'] == status).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, filteredProposals.length);
    final paginatedProposals = filteredProposals.sublist(startIndex, endIndex);

    return {
      'items': paginatedProposals,
      'total': filteredProposals.length,
      'hasMore': endIndex < filteredProposals.length,
      'limit': limit,
      'offset': startIndex,
    };
  }

  static Map<String, dynamic> _getMockProposalSubmissionResponse(Map<String, dynamic> proposalData) {
    return {
      'id': 'proposal_${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Asset proposal submitted successfully',
      'status': 'pending_master_admin_review',
      'proposal': {
        ...proposalData,
        'id': 'proposal_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    };
  }

  static Map<String, dynamic> _getMockMerchantSettlementsResponse({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    final allSettlements = [
      {
        'id': 'settlement_1',
        'bankId': 'bank_1',
        'periodStart': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'periodEnd': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'totalVolume': 1250000.0,
        'commissionEarned': 18750.0,
        'revenueShare': 37500.0,
        'netPayout': 56250.0,
        'status': 'paid',
        'settlementDate': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'txHash': '0x1234567890abcdef1234567890abcdef12345678',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'settlement_2',
        'bankId': 'bank_1',
        'periodStart': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'periodEnd': DateTime.now().toIso8601String(),
        'totalVolume': 1750000.0,
        'commissionEarned': 26250.0,
        'revenueShare': 52500.0,
        'netPayout': 78750.0,
        'status': 'pending',
        'settlementDate': null,
        'txHash': null,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];

    // Filter by status if provided
    var filteredSettlements = allSettlements;
    if (status != null) {
      filteredSettlements = allSettlements.where((settlement) => settlement['status'] == status).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, filteredSettlements.length);
    final paginatedSettlements = filteredSettlements.sublist(startIndex, endIndex);

    return {
      'items': paginatedSettlements,
      'total': filteredSettlements.length,
      'hasMore': endIndex < filteredSettlements.length,
      'limit': limit,
      'offset': startIndex,
    };
  }

  static Map<String, dynamic> _getMockBrandingUpdateResponse(Map<String, dynamic> brandingData) {
    return {
      'message': 'Merchant branding updated successfully',
      'branding': {
        ...brandingData,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    };
  }

  // Super Admin endpoints
  static Future<Map<String, dynamic>> getPlatformMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/platform/metrics'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock platform metrics if backend is not available
      return _getMockPlatformMetricsResponse();
    }
  }

  static Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/system/health'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock system health if backend is not available
      return _getMockSystemHealthResponse();
    }
  }

  static Future<Map<String, dynamic>> getAllMerchants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/banks'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock banks data if backend is not available
      return _getMockAllMerchantsResponse();
    }
  }

  static Future<Map<String, dynamic>> getSystemAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/system/alerts'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return mock system alerts if backend is not available
      return _getMockSystemAlertsResponse();
    }
  }

  static Future<Map<String, dynamic>> updateMerchantStatus(String merchantId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/super-admin/merchants/$merchantId/status'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );
      return _handleResponse(response);
    } catch (e) {
      // Return success for demo purposes
      return {'success': true, 'message': 'Merchant status updated successfully'};
    }
  }

  static Future<Map<String, dynamic>> resolveSystemAlert(String alertId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/super-admin/system/alerts/$alertId/resolve'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      // Return success for demo purposes
      return {'success': true, 'message': 'Alert resolved successfully'};
    }
  }

  // Super Admin User Management endpoints
  static Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 50,
    String? role,
    String? status,
    String? search,
  }) async {
    try {
      var url = '$baseUrl/super-admin/users?page=$page&limit=$limit';
      if (role != null) url += '&role=$role';
      if (status != null) url += '&status=$status';
      if (search != null) url += '&search=$search';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return _getMockAllUsersResponse();
    }
  }

  static Future<Map<String, dynamic>> getAllAgents({
    int page = 1,
    int limit = 50,
    String? type,
    String? status,
  }) async {
    try {
      var url = '$baseUrl/super-admin/agents?page=$page&limit=$limit';
      if (type != null) url += '&type=$type';
      if (status != null) url += '&status=$status';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return _getMockAllAgentsResponse();
    }
  }

  static Future<Map<String, dynamic>> getSystemActivities({
    int page = 1,
    int limit = 50,
    String? type,
    String? timeRange,
  }) async {
    try {
      var url = '$baseUrl/super-admin/activities?page=$page&limit=$limit';
      if (type != null) url += '&type=$type';
      if (timeRange != null) url += '&timeRange=$timeRange';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return _getMockSystemActivitiesResponse();
    }
  }

  static Future<Map<String, dynamic>> updateUserStatus(String userId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/super-admin/users/$userId/status'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );
      return _handleResponse(response);
    } catch (e) {
      return {'success': true, 'message': 'User status updated successfully'};
    }
  }

  static Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/super-admin/users/$userId'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return _getMockUserDetailsResponse(userId);
    }
  }

  // Mock data methods for Super Admin
  static Map<String, dynamic> _getMockPlatformMetricsResponse() {
    return {
      'totalUsers': 15847,
      'totalMerchants': 23,
      'totalAssetValue': 847500000.0,
      'totalRevenue': 12540000.0,
      'totalTransactions': 89234,
      'monthlyGrowthRate': 8.7,
      'usersByRole': {
        'Investor-Agents': 12450,
        'Professional Agents': 1820,
        'Verifiers': 967,
        'Merchant Admins': 145,
        'Merchant Partners': 23,
      },
      'revenueByMerchant': {
        'Premier Merchant': 3250000.0,
        'Global Investment': 2890000.0,
        'Capital Partners': 2150000.0,
        'Others': 4250000.0,
      },
      'alerts': [],
    };
  }

  static Map<String, dynamic> _getMockSystemHealthResponse() {
    final now = DateTime.now();
    return {
      'cpuUsage': 45.2,
      'memoryUsage': 67.8,
      'diskUsage': 23.4,
      'activeConnections': 12847,
      'responseTime': 89.5,
      'uptime': 99.97,
      'services': [
        {
          'name': 'API Gateway',
          'status': 'healthy',
          'version': '1.2.3',
          'lastCheck': now.subtract(const Duration(minutes: 1)).toIso8601String(),
          'responseTime': 45.2,
        },
        {
          'name': 'Database',
          'status': 'healthy',
          'version': '14.2',
          'lastCheck': now.subtract(const Duration(minutes: 2)).toIso8601String(),
          'responseTime': 12.8,
        },
        {
          'name': 'Redis Cache',
          'status': 'warning',
          'version': '6.2.7',
          'lastCheck': now.subtract(const Duration(minutes: 1)).toIso8601String(),
          'responseTime': 156.3,
          'errorMessage': 'High memory usage detected',
        },
      ],
      'performanceMetrics': [
        {
          'name': 'Response Time',
          'values': [89.5, 92.1, 87.3, 85.6, 91.2, 88.9],
          'timestamps': List.generate(6, (i) => now.subtract(Duration(hours: i)).toIso8601String()),
          'unit': 'ms',
        },
        {
          'name': 'CPU Usage',
          'values': [45.2, 43.8, 47.1, 44.9, 46.3, 42.7],
          'timestamps': List.generate(6, (i) => now.subtract(Duration(hours: i)).toIso8601String()),
          'unit': '%',
        },
      ],
    };
  }

  static Map<String, dynamic> _getMockAllMerchantsResponse() {
    final now = DateTime.now();
    return {
      'banks': [
        {
          'id': 'bank_1',
          'name': 'Premier Investment Merchant',
          'legalName': 'Premier Investment Merchant Limited',
          'registrationNumber': 'PIB2023001',
          'country': 'United States',
          'domain': 'premier-bank.com',
          'subdomain': 'invest',
          'status': 'active',
          'commissionRateBps': 150,
          'revenueShareBps': 3000,
          'contractStartDate': now.subtract(const Duration(days: 365)).toIso8601String(),
          'description': 'Leading provider of real-world asset investment opportunities',
          'totalRevenue': 3250000.0,
          'createdAt': now.subtract(const Duration(days: 365)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': 'bank_2',
          'name': 'Global Investment Partners',
          'legalName': 'Global Investment Partners Inc.',
          'registrationNumber': 'GIP2023002',
          'country': 'United Kingdom',
          'domain': 'global-invest.co.uk',
          'status': 'pending',
          'commissionRateBps': 175,
          'revenueShareBps': 2800,
          'contractStartDate': now.subtract(const Duration(days: 90)).toIso8601String(),
          'description': 'International asset management and investment services',
          'totalRevenue': 2890000.0,
          'createdAt': now.subtract(const Duration(days: 95)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(hours: 12)).toIso8601String(),
        },
      ],
    };
  }

  static Map<String, dynamic> _getMockSystemAlertsResponse() {
    final now = DateTime.now();
    return {
      'alerts': [
        {
          'id': 'alert_1',
          'type': 'warning',
          'title': 'High Memory Usage',
          'message': 'Redis cache memory usage is above 80% threshold',
          'timestamp': now.subtract(const Duration(minutes: 15)).toIso8601String(),
          'isResolved': false,
        },
        {
          'id': 'alert_2',
          'type': 'info',
          'title': 'New Merchant Registration',
          'message': 'Capital Partners Merchant has submitted registration documents',
          'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
          'bankId': 'bank_3',
          'isResolved': false,
        },
      ],
    };
  }

  static Map<String, dynamic> _getMockAllUsersResponse() {
    return {
      'users': [
        {
          'id': '1',
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'role': 'Investor',
          'status': 'Active',
          'joinDate': '2023-05-15',
          'lastLogin': '2024-01-15 10:30:00',
          'phone': '+1-555-0123',
          'kycStatus': 'Verified',
          'totalInvestments': 125000.00,
          'portfolioValue': 134250.00
        },
        {
          'id': '2',
          'name': 'Jane Smith',
          'email': 'jane.smith@example.com',
          'role': 'Professional Agent',
          'status': 'Active',
          'joinDate': '2023-07-22',
          'lastLogin': '2024-01-15 09:45:00',
          'phone': '+1-555-0456',
          'kycStatus': 'Verified',
          'totalInvestments': 89000.00,
          'portfolioValue': 92450.00
        },
        {
          'id': '3',
          'name': 'Mike Johnson',
          'email': 'mike.johnson@example.com',
          'role': 'Merchant Admin',
          'status': 'Active',
          'joinDate': '2023-08-10',
          'lastLogin': '2024-01-14 16:20:00',
          'phone': '+1-555-0789',
          'kycStatus': 'Verified',
          'companyName': 'Johnson Properties LLC'
        },
      ],
      'pagination': {
        'page': 1,
        'limit': 50,
        'total': 15847,
        'totalPages': 317
      }
    };
  }

  static Map<String, dynamic> _getMockAllAgentsResponse() {
    return {
      'agents': [
        {
          'id': '1',
          'name': 'Sarah Johnson',
          'type': 'Professional Agent',
          'rating': 4.8,
          'completedTasks': 234,
          'activeTasks': 12,
          'revenue': 45600.00,
          'location': 'New York, USA',
          'kycStatus': 'Verified',
          'joinDate': '2023-05-15',
          'email': 'sarah@agents.com',
          'phone': '+1-555-0123',
          'specialties': ['Real Estate', 'Technology'],
          'status': 'Active',
          'lastActive': '2 hours ago',
        },
        {
          'id': '2',
          'name': 'Mike Chen',
          'type': 'Verifier',
          'rating': 4.9,
          'completedTasks': 189,
          'activeTasks': 8,
          'revenue': 28900.00,
          'location': 'Singapore',
          'kycStatus': 'Verified',
          'joinDate': '2023-07-22',
          'email': 'mike.chen@agents.com',
          'phone': '+65-555-0456',
          'specialties': ['Document Verification', 'Asset Assessment'],
          'status': 'Active',
          'lastActive': '30 minutes ago',
        },
        {
          'id': '3',
          'name': 'Anna Rodriguez',
          'type': 'Investor Agent',
          'rating': 4.7,
          'completedTasks': 156,
          'activeTasks': 5,
          'revenue': 22100.00,
          'location': 'Madrid, Spain',
          'kycStatus': 'Verified',
          'joinDate': '2023-09-08',
          'email': 'anna.rodriguez@agents.com',
          'phone': '+34-555-0789',
          'specialties': ['Investment Analysis', 'Risk Assessment'],
          'status': 'Active',
          'lastActive': '1 hour ago',
        },
      ],
      'pagination': {
        'page': 1,
        'limit': 50,
        'total': 1820,
        'totalPages': 37
      }
    };
  }

  static Map<String, dynamic> _getMockSystemActivitiesResponse() {
    return {
      'activities': [
        {
          'id': '1',
          'action': 'New Merchant Registration',
          'user': 'First National Merchant',
          'userId': 'merchant_001',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
          'type': 'merchant',
          'details': 'Successfully registered new merchant account'
        },
        {
          'id': '2',
          'action': 'Asset Verification',
          'user': 'John Doe',
          'userId': 'user_001',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          'type': 'asset',
          'details': 'Verified residential property in Manhattan'
        },
        {
          'id': '3',
          'action': 'User Registration',
          'user': 'Jane Smith',
          'userId': 'user_002',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
          'type': 'user',
          'details': 'New investor registered with KYC pending'
        },
        {
          'id': '4',
          'action': 'Transaction Completed',
          'user': 'ABC Corp',
          'userId': 'merchant_002',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
          'type': 'transaction',
          'details': 'Asset purchase transaction for \$125,000'
        },
        {
          'id': '5',
          'action': 'Compliance Check',
          'user': 'XYZ Merchant',
          'userId': 'merchant_003',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
          'type': 'compliance',
          'details': 'Routine compliance audit completed'
        },
      ],
      'pagination': {
        'page': 1,
        'limit': 50,
        'total': 5432,
        'totalPages': 109
      }
    };
  }

  static Map<String, dynamic> _getMockUserDetailsResponse(String userId) {
    return {
      'user': {
        'id': userId,
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'role': 'Investor',
        'status': 'Active',
        'joinDate': '2023-05-15',
        'lastLogin': '2024-01-15 10:30:00',
        'phone': '+1-555-0123',
        'kycStatus': 'Verified',
        'totalInvestments': 125000.00,
        'portfolioValue': 134250.00,
        'address': {
          'street': '123 Main St',
          'city': 'New York',
          'state': 'NY',
          'zipCode': '10001',
          'country': 'USA'
        },
        'investments': [
          {
            'assetId': 'asset_001',
            'assetTitle': 'Manhattan Office Building',
            'amount': 50000.00,
            'date': '2023-06-15',
            'currentValue': 52500.00,
            'roi': 5.0
          },
          {
            'assetId': 'asset_002',
            'assetTitle': 'Tech Startup Equity',
            'amount': 75000.00,
            'date': '2023-08-20',
            'currentValue': 81750.00,
            'roi': 9.0
          }
        ],
        'recentActivity': [
          {
            'action': 'Investment',
            'description': 'Invested in Manhattan Office Building',
            'amount': 50000.00,
            'timestamp': '2023-06-15 14:30:00'
          },
          {
            'action': 'KYC Update',
            'description': 'Updated KYC documentation',
            'timestamp': '2023-07-01 09:15:00'
          }
        ]
      }
    };
  }

  // Portfolio Analytics Mock Responses
  static Map<String, dynamic> _getMockPerformanceResponse(String period, bool includeBenchmark) {
    final months = period == '1M' ? 1 : period == '3M' ? 3 : period == '6M' ? 6 : period == '1Y' ? 12 : 24;
    final dataPoints = <Map<String, dynamic>>[];
    final benchmarkPoints = <Map<String, dynamic>>[];

    double baseValue = 100000.0;
    double benchmarkBase = 100000.0;

    for (int i = 0; i < months; i++) {
      final date = DateTime.now().subtract(Duration(days: (months - i) * 30));
      final volatility = 0.02 + (i * 0.001);
      final trend = 1.0 + (i * 0.008); // 0.8% monthly growth

      baseValue *= trend + (DateTime.now().millisecond % 100 - 50) * volatility / 1000;
      benchmarkBase *= (trend * 0.7) + (DateTime.now().millisecond % 80 - 40) * volatility / 1500;

      dataPoints.add({
        'date': date.toIso8601String(),
        'value': baseValue.roundToDouble(),
        'return': ((baseValue - 100000) / 100000 * 100).roundToDouble(),
      });

      if (includeBenchmark) {
        benchmarkPoints.add({
          'date': date.toIso8601String(),
          'value': benchmarkBase.roundToDouble(),
          'return': ((benchmarkBase - 100000) / 100000 * 100).roundToDouble(),
        });
      }
    }

    final totalReturn = ((dataPoints.last['value'] as double) - 100000) / 100000 * 100;
    final benchmarkReturn = benchmarkPoints.isNotEmpty
        ? ((benchmarkPoints.last['value'] as double) - 100000) / 100000 * 100
        : 0.0;

    return {
      'success': true,
      'data': {
        'period': period,
        'portfolio': {
          'dataPoints': dataPoints,
          'totalReturn': totalReturn,
          'volatility': 15.2,
          'sharpeRatio': 1.3,
          'maxDrawdown': -8.5,
          'currentValue': dataPoints.last['value'],
          'bestPerformer': {
            'assetTitle': 'Tech Infrastructure Fund',
            'return': 24.7,
          },
          'worstPerformer': {
            'assetTitle': 'Traditional Retail REIT',
            'return': -3.2,
          },
        },
        'benchmark': includeBenchmark ? {
          'name': 'S&P 500',
          'dataPoints': benchmarkPoints,
          'totalReturn': benchmarkReturn,
          'volatility': 16.8,
        } : null,
        'metrics': {
          'monthlyIncome': 3250.0,
          'dividendYield': 4.2,
          'totalFees': 156.0,
          'taxEfficiency': 87.3,
        }
      }
    };
  }

  static Map<String, dynamic> _getMockAnalyticsResponse() {
    return {
      'success': true,
      'data': {
        'performanceMetrics': {
          'totalReturn': 18.7,
          'annualizedReturn': 12.4,
          'volatility': 15.2,
          'sharpeRatio': 1.3,
          'maxDrawdown': -8.5,
          'beta': 0.9,
          'alpha': 3.2,
          'informationRatio': 0.8,
        },
        'riskMetrics': {
          'valueAtRisk': -12500.0,
          'expectedShortfall': -18750.0,
          'downsideDeviation': 11.8,
          'calmarRatio': 1.5,
          'sortinoRatio': 1.8,
        },
        'incomeAnalysis': {
          'monthlyIncome': 3250.0,
          'quarterlyIncome': 9750.0,
          'annualizedIncome': 39000.0,
          'yieldOnCost': 4.2,
          'incomeGrowthRate': 8.5,
          'payoutRatio': 0.65,
        },
        'correlationMatrix': {
          'realEstate': {
            'realEstate': 1.0,
            'technology': 0.3,
            'healthcare': 0.1,
            'energy': -0.2,
          },
          'technology': {
            'realEstate': 0.3,
            'technology': 1.0,
            'healthcare': 0.5,
            'energy': 0.1,
          },
        }
      }
    };
  }

  static Map<String, dynamic> _getMockAssetPerformanceResponse(String assetId, String period) {
    final months = period == '1M' ? 1 : period == '3M' ? 3 : period == '6M' ? 6 : period == '1Y' ? 12 : 24;
    final dataPoints = <Map<String, dynamic>>[];

    double baseValue = 25000.0; // Asset-specific base value

    for (int i = 0; i < months; i++) {
      final date = DateTime.now().subtract(Duration(days: (months - i) * 30));
      final trend = 1.0 + (i * 0.01); // 1% monthly growth for individual asset
      baseValue *= trend;

      dataPoints.add({
        'date': date.toIso8601String(),
        'value': baseValue.roundToDouble(),
        'shares': 100,
        'pricePerShare': (baseValue / 100).roundToDouble(),
      });
    }

    return {
      'success': true,
      'data': {
        'assetId': assetId,
        'assetTitle': 'Premium Office Complex Downtown',
        'assetType': 'Commercial Real Estate',
        'period': period,
        'dataPoints': dataPoints,
        'metrics': {
          'totalReturn': ((dataPoints.last['value'] as double) - 25000) / 25000 * 100,
          'dividendYield': 6.8,
          'capitalAppreciation': 12.3,
          'occupancyRate': 94.5,
          'operatingRatio': 0.72,
        },
        'distributions': [
          {
            'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            'amount': 425.0,
            'type': 'rent',
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
            'amount': 425.0,
            'type': 'rent',
          },
        ]
      }
    };
  }

  static Map<String, dynamic> _getMockDiversificationResponse() {
    return {
      'success': true,
      'data': {
        'assetAllocation': {
          'realEstate': {
            'percentage': 65.0,
            'value': 97500.0,
            'assets': 8,
          },
          'technology': {
            'percentage': 20.0,
            'value': 30000.0,
            'assets': 3,
          },
          'healthcare': {
            'percentage': 10.0,
            'value': 15000.0,
            'assets': 2,
          },
          'energy': {
            'percentage': 5.0,
            'value': 7500.0,
            'assets': 1,
          },
        },
        'geographicAllocation': {
          'northAmerica': 70.0,
          'europe': 20.0,
          'asiaPacific': 8.0,
          'emergingMarkets': 2.0,
        },
        'concentrationMetrics': {
          'herfindahlIndex': 0.18, // Lower = more diversified
          'topAssetPercentage': 22.5,
          'top3AssetsPercentage': 58.2,
          'effectiveNumberAssets': 5.6,
        },
        'diversificationScore': 7.8, // Out of 10
        'recommendations': [
          {
            'type': 'underweight',
            'sector': 'International Exposure',
            'suggestion': 'Consider adding more international assets to reduce geographic concentration',
          },
          {
            'type': 'rebalance',
            'sector': 'Real Estate',
            'suggestion': 'Real estate allocation is high - consider taking profits to rebalance',
          },
        ],
      }
    };
  }

  static Map<String, dynamic> _getMockBenchmarkResponse(String benchmark, String period) {
    final benchmarkName = benchmark == 'SP500' ? 'S&P 500' :
                          benchmark == 'REIT' ? 'FTSE NAREIT All REITs Index' :
                          benchmark == 'TECH' ? 'NASDAQ 100' : benchmark;

    return {
      'success': true,
      'data': {
        'benchmark': {
          'name': benchmarkName,
          'symbol': benchmark,
          'period': period,
        },
        'comparison': {
          'portfolioReturn': 18.7,
          'benchmarkReturn': benchmark == 'SP500' ? 14.2 :
                           benchmark == 'REIT' ? 16.8 : 22.1,
          'outperformance': benchmark == 'SP500' ? 4.5 :
                          benchmark == 'REIT' ? 1.9 : -3.4,
          'trackingError': 8.3,
          'informationRatio': 0.54,
          'upCaptureRatio': 1.12,
          'downCaptureRatio': 0.88,
        },
        'monthlyComparison': List.generate(12, (index) {
          final month = DateTime.now().subtract(Duration(days: (12 - index) * 30));
          final portfolioReturn = 0.8 + (index * 0.15) + (DateTime.now().millisecond % 100 - 50) * 0.01;
          final benchmarkReturn = portfolioReturn * 0.9 + (DateTime.now().microsecond % 50 - 25) * 0.005;

          return {
            'month': month.toIso8601String().substring(0, 7), // YYYY-MM format
            'portfolioReturn': portfolioReturn.toStringAsFixed(2),
            'benchmarkReturn': benchmarkReturn.toStringAsFixed(2),
            'outperformance': (portfolioReturn - benchmarkReturn).toStringAsFixed(2),
          };
        }),
        'riskAdjustedMetrics': {
          'portfolioSharpe': 1.3,
          'benchmarkSharpe': benchmark == 'SP500' ? 1.1 :
                           benchmark == 'REIT' ? 1.0 : 1.5,
          'portfolioVolatility': 15.2,
          'benchmarkVolatility': benchmark == 'SP500' ? 16.8 :
                                benchmark == 'REIT' ? 18.5 : 24.3,
        }
      }
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