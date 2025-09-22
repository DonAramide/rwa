import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/job_model.dart';
import '../models/agent_model.dart';
import '../models/earning_model.dart';

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
        }
        handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/agents/apply', data: data);
    return response.data;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Agent profile
  Future<AgentModel> getProfile() async {
    final response = await _dio.get('/profile');
    return AgentModel.fromJson(response.data);
  }

  Future<AgentModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/profile', data: data);
    return AgentModel.fromJson(response.data);
  }

  // Jobs endpoints
  Future<List<JobModel>> getAvailableJobs({
    String? region,
    String? skill,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get('/verification/jobs', queryParameters: {
      if (region != null) 'region': region,
      if (skill != null) 'skill': skill,
      'status': 'open',
      'limit': limit,
      'offset': offset,
    });
    
    final List<dynamic> jobs = response.data['items'] ?? [];
    return jobs.map((job) => JobModel.fromJson(job)).toList();
  }

  Future<List<JobModel>> getMyJobs({String? status}) async {
    final response = await _dio.get('/verification/jobs/my', queryParameters: {
      if (status != null) 'status': status,
    });
    
    final List<dynamic> jobs = response.data['items'] ?? [];
    return jobs.map((job) => JobModel.fromJson(job)).toList();
  }

  Future<JobModel> getJob(String jobId) async {
    final response = await _dio.get('/verification/jobs/$jobId');
    return JobModel.fromJson(response.data);
  }

  Future<void> acceptJob(String jobId) async {
    await _dio.post('/verification/jobs/$jobId/accept');
  }

  Future<void> rejectJob(String jobId, String reason) async {
    await _dio.post('/verification/jobs/$jobId/reject', data: {
      'reason': reason,
    });
  }

  Future<void> updateJobStatus(String jobId, String status, {Map<String, dynamic>? data}) async {
    await _dio.patch('/verification/jobs/$jobId', data: {
      'status': status,
      ...?data,
    });
  }

  Future<void> submitReport(String jobId, Map<String, dynamic> reportData) async {
    await _dio.post('/verification/jobs/$jobId/report', data: reportData);
  }

  // File upload
  Future<String> uploadFile(String filePath, {String? jobId}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (jobId != null) 'job_id': jobId,
    });

    final response = await _dio.post('/upload', data: formData);
    return response.data['url'];
  }

  Future<List<String>> uploadFiles(List<String> filePaths, {String? jobId}) async {
    final formData = FormData();
    
    for (int i = 0; i < filePaths.length; i++) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(filePaths[i]),
      ));
    }
    
    if (jobId != null) {
      formData.fields.add(MapEntry('job_id', jobId));
    }

    final response = await _dio.post('/upload/multiple', data: formData);
    return List<String>.from(response.data['urls']);
  }

  // Earnings endpoints
  Future<List<EarningModel>> getEarnings({
    String? period,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get('/earnings', queryParameters: {
      if (period != null) 'period': period,
      'limit': limit,
      'offset': offset,
    });
    
    final List<dynamic> earnings = response.data['items'] ?? [];
    return earnings.map((earning) => EarningModel.fromJson(earning)).toList();
  }

  Future<Map<String, dynamic>> getEarningsStats() async {
    final response = await _dio.get('/earnings/stats');
    return response.data;
  }

  // Location and navigation
  Future<void> updateLocation(double latitude, double longitude) async {
    await _dio.post('/agents/location', data: {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> getDirections(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    final response = await _dio.get('/navigation/directions', queryParameters: {
      'from_lat': fromLat,
      'from_lng': fromLng,
      'to_lat': toLat,
      'to_lng': toLng,
    });
    return response.data;
  }

  // Reviews and ratings
  Future<void> submitReview(String jobId, int rating, String comment) async {
    await _dio.post('/reviews', data: {
      'job_id': jobId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<Map<String, dynamic>> getReviews() async {
    final response = await _dio.get('/reviews/my');
    return response.data;
  }
}