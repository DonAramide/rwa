import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/v1';
  late final Dio _dio;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
          // Could trigger a navigation to login screen here
        }
        handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/admin/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Asset endpoints
  Future<List<dynamic>> getAssets({
    String? type,
    String? status,
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get('/assets', queryParameters: {
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
    return response.data['items'] ?? [];
  }

  Future<Map<String, dynamic>> getAsset(int id) async {
    final response = await _dio.get('/assets/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createAsset(Map<String, dynamic> assetData) async {
    final response = await _dio.post('/admin/assets', data: assetData);
    return response.data;
  }

  Future<Map<String, dynamic>> updateAsset(int id, Map<String, dynamic> assetData) async {
    final response = await _dio.put('/admin/assets/$id', data: assetData);
    return response.data;
  }

  Future<void> verifyAsset(int id, bool approved, String? notes) async {
    await _dio.post('/admin/assets/$id/verify', data: {
      'approved': approved,
      'notes': notes,
    });
  }

  // Agent endpoints
  Future<List<dynamic>> getAgents({
    String? status,
    List<String>? regions,
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get('/agents/search', queryParameters: {
      if (status != null) 'status': status,
      if (regions != null) 'regions': regions.join(','),
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
    return response.data['items'] ?? [];
  }

  Future<Map<String, dynamic>> getAgent(int id) async {
    final response = await _dio.get('/agents/$id');
    return response.data;
  }

  Future<void> updateAgentStatus(int id, String status, String? notes) async {
    await _dio.patch('/admin/agents/$id', data: {
      'status': status,
      'notes': notes,
    });
  }

  // Verification job endpoints
  Future<List<dynamic>> getVerificationJobs({
    String? status,
    int? assetId,
    int? agentId,
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get('/verification/jobs', queryParameters: {
      if (status != null) 'status': status,
      if (assetId != null) 'asset_id': assetId,
      if (agentId != null) 'agent_id': agentId,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
    return response.data['items'] ?? [];
  }

  Future<Map<String, dynamic>> getVerificationReport(int reportId) async {
    final response = await _dio.get('/verification/reports/$reportId');
    return response.data;
  }

  Future<void> resolveDispute(int jobId, String resolution, String notes) async {
    await _dio.post('/admin/verification/jobs/$jobId/resolve', data: {
      'resolution': resolution,
      'notes': notes,
    });
  }

  // Revenue and payout endpoints
  Future<List<dynamic>> getDistributions({
    int? assetId,
    String? period,
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get('/revenue/distributions', queryParameters: {
      if (assetId != null) 'asset_id': assetId,
      if (period != null) 'period': period,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
    return response.data['items'] ?? [];
  }

  Future<Map<String, dynamic>> triggerPayout(int assetId, double amount, String period) async {
    final response = await _dio.post('/admin/distributions/trigger', data: {
      'asset_id': assetId,
      'amount': amount,
      'period': period,
    });
    return response.data;
  }

  // Dashboard analytics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _dio.get('/admin/dashboard/stats');
    return response.data;
  }

  Future<List<dynamic>> getRecentActivity({int limit = 10}) async {
    final response = await _dio.get('/admin/dashboard/activity', queryParameters: {
      'limit': limit,
    });
    return response.data;
  }

  // Users and KYC
  Future<List<dynamic>> getUsers({
    String? kycStatus,
    String? type,
    int? limit,
    int? offset,
  }) async {
    final response = await _dio.get('/admin/users', queryParameters: {
      if (kycStatus != null) 'kyc_status': kycStatus,
      if (type != null) 'type': type,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });
    return response.data['items'] ?? [];
  }

  Future<void> updateKycStatus(int userId, String status, String? notes) async {
    await _dio.patch('/admin/users/$userId/kyc', data: {
      'status': status,
      'notes': notes,
    });
  }

  // Analytics endpoints
  Future<Map<String, dynamic>> getAnalyticsDashboard({String? period}) async {
    final response = await _dio.get('/admin/analytics/dashboard', queryParameters: {
      if (period != null) 'period': period,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getRevenueAnalytics({
    String? period,
    String? assetType,
  }) async {
    final response = await _dio.get('/admin/analytics/revenue', queryParameters: {
      if (period != null) 'period': period,
      if (assetType != null) 'asset_type': assetType,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getUserGrowthMetrics({String? period}) async {
    final response = await _dio.get('/admin/analytics/user-growth', queryParameters: {
      if (period != null) 'period': period,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getAssetPerformance({
    String? period,
    int? limit,
  }) async {
    final response = await _dio.get('/admin/analytics/asset-performance', queryParameters: {
      if (period != null) 'period': period,
      if (limit != null) 'limit': limit,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getTransactionVolume({String? period}) async {
    final response = await _dio.get('/admin/analytics/transaction-volume', queryParameters: {
      if (period != null) 'period': period,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getGeographicDistribution({String? metric}) async {
    final response = await _dio.get('/admin/analytics/geographic-distribution', queryParameters: {
      if (metric != null) 'metric': metric,
    });
    return response.data;
  }

  // Banking analytics endpoints
  Future<Map<String, dynamic>> getBankingOverview({
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get('/analytics/banking/overview', queryParameters: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getBankPerformanceComparison({
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get('/analytics/banking/performance', queryParameters: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getProposalPipelineAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get('/analytics/banking/proposals', queryParameters: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getBankingRevenueAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get('/analytics/banking/revenue', queryParameters: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return response.data;
  }

  // Bank management endpoints (Master Admin)
  Future<List<dynamic>> getAllBanks({
    String? status,
    int? page,
    int? limit,
  }) async {
    final response = await _dio.get('/admin/banks', queryParameters: {
      if (status != null) 'status': status,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    return response.data['items'] ?? [];
  }

  Future<Map<String, dynamic>> getBankById(String bankId) async {
    final response = await _dio.get('/admin/banks/$bankId');
    return response.data;
  }

  Future<Map<String, dynamic>> createBank(Map<String, dynamic> bankData) async {
    final response = await _dio.post('/admin/banks', data: bankData);
    return response.data;
  }

  Future<Map<String, dynamic>> updateBank(String bankId, Map<String, dynamic> updateData) async {
    final response = await _dio.patch('/admin/banks/$bankId', data: updateData);
    return response.data;
  }

  Future<void> updateBankStatus(String bankId, String status) async {
    await _dio.patch('/admin/banks/$bankId/status', data: {
      'status': status,
    });
  }

  Future<void> deleteBank(String bankId) async {
    await _dio.delete('/admin/banks/$bankId');
  }

  Future<Map<String, dynamic>> getBankSettings(String bankId) async {
    final response = await _dio.get('/admin/banks/$bankId/settings');
    return response.data;
  }

  Future<Map<String, dynamic>> updateBankSettings(String bankId, Map<String, dynamic> settings) async {
    final response = await _dio.patch('/admin/banks/$bankId/settings', data: settings);
    return response.data;
  }

  // Bank proposals management (Master Admin view)
  Future<List<dynamic>> getBankProposals({
    String? bankId,
    String? status,
    int? page,
    int? limit,
  }) async {
    final response = await _dio.get('/admin/proposals', queryParameters: {
      if (bankId != null) 'bankId': bankId,
      if (status != null) 'status': status,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    return response.data['items'] ?? [];
  }

  Future<void> approveProposal(String proposalId, {String? notes}) async {
    await _dio.post('/admin/proposals/$proposalId/approve', data: {
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> rejectProposal(String proposalId, {String? reason}) async {
    await _dio.post('/admin/proposals/$proposalId/reject', data: {
      if (reason != null) 'reason': reason,
    });
  }

  // Brand management endpoints
  Future<List<dynamic>> getAllBrands({String? bankId}) async {
    final response = await _dio.get('/admin/brands', queryParameters: {
      if (bankId != null) 'bankId': bankId,
    });
    return response.data['items'] ?? [];
  }

  Future<Map<String, dynamic>> getBrandById(String brandId) async {
    final response = await _dio.get('/admin/brands/$brandId');
    return response.data;
  }

  Future<Map<String, dynamic>> createBrand(Map<String, dynamic> brandData) async {
    final response = await _dio.post('/admin/brands', data: brandData);
    return response.data;
  }

  Future<Map<String, dynamic>> updateBrand(String brandId, Map<String, dynamic> brandData) async {
    final response = await _dio.patch('/admin/brands/$brandId', data: brandData);
    return response.data;
  }

  Future<void> deleteBrand(String brandId) async {
    await _dio.delete('/admin/brands/$brandId');
  }

  Future<void> activateBrand(String brandId, String bankId) async {
    await _dio.post('/admin/brands/$brandId/activate', data: {
      'bankId': bankId,
    });
  }

  Future<String> uploadBrandAsset(String brandId, String assetType, List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      'assetType': assetType,
    });

    final response = await _dio.post('/admin/brands/$brandId/assets', data: formData);
    return response.data['url'];
  }

  Future<Map<String, dynamic>> getBrandAssets(String brandId) async {
    final response = await _dio.get('/admin/brands/$brandId/assets');
    return response.data;
  }

  Future<void> deleteBrandAsset(String brandId, String assetType) async {
    await _dio.delete('/admin/brands/$brandId/assets/$assetType');
  }

  // Brand theme endpoints
  Future<Map<String, dynamic>> getBrandTheme(String brandId) async {
    final response = await _dio.get('/admin/brands/$brandId/theme');
    return response.data;
  }

  Future<Map<String, dynamic>> updateBrandTheme(String brandId, Map<String, dynamic> themeData) async {
    final response = await _dio.patch('/admin/brands/$brandId/theme', data: themeData);
    return response.data;
  }

  Future<Map<String, dynamic>> previewBrandTheme(Map<String, dynamic> themeData) async {
    final response = await _dio.post('/admin/brands/preview-theme', data: themeData);
    return response.data;
  }
}