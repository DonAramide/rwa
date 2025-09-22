import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/job_model.dart';
import '../core/api_client.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  static OfflineService get instance => _instance;
  OfflineService._internal();

  late Box _agentDataBox;
  late Box _jobsCacheBox;
  late Box _mediaCacheBox;
  final Connectivity _connectivity = Connectivity();
  final ApiClient _apiClient = ApiClient();

  Future<void> initialize() async {
    _agentDataBox = Hive.box('agent_data');
    _jobsCacheBox = Hive.box('jobs_cache');
    _mediaCacheBox = Hive.box('media_cache');

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isConnected = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
    
    if (isConnected) {
      _syncPendingData();
    }
  }

  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
  }

  // Cache management
  Future<void> cacheJobs(List<JobModel> jobs) async {
    final jobsJson = jobs.map((job) => job.toJson()).toList();
    await _jobsCacheBox.put('available_jobs', jobsJson);
    await _jobsCacheBox.put('cached_at', DateTime.now().toIso8601String());
  }

  Future<List<JobModel>?> getCachedJobs() async {
    final cachedData = _jobsCacheBox.get('available_jobs');
    if (cachedData != null) {
      final List<dynamic> jobsJson = List<dynamic>.from(cachedData);
      return jobsJson.map((json) => JobModel.fromJson(json)).toList();
    }
    return null;
  }

  Future<void> cacheAgentData(Map<String, dynamic> agentData) async {
    await _agentDataBox.put('profile', agentData);
    await _agentDataBox.put('cached_at', DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>?> getCachedAgentData() async {
    return _agentDataBox.get('profile');
  }

  // Offline media handling
  Future<void> cacheMediaFile(String filePath, String jobId) async {
    final pendingMedia = _mediaCacheBox.get('pending_uploads') ?? <String, dynamic>{};
    pendingMedia[filePath] = {
      'job_id': jobId,
      'timestamp': DateTime.now().toIso8601String(),
      'uploaded': false,
    };
    await _mediaCacheBox.put('pending_uploads', pendingMedia);
  }

  Future<Map<String, dynamic>> getPendingMedia() async {
    return Map<String, dynamic>.from(_mediaCacheBox.get('pending_uploads') ?? {});
  }

  Future<void> markMediaAsUploaded(String filePath) async {
    final pendingMedia = await getPendingMedia();
    pendingMedia.remove(filePath);
    await _mediaCacheBox.put('pending_uploads', pendingMedia);
  }

  // Offline job updates
  Future<void> cacheJobUpdate(String jobId, Map<String, dynamic> updateData) async {
    final pendingUpdates = _agentDataBox.get('pending_job_updates') ?? <String, dynamic>{};
    pendingUpdates[jobId] = {
      'data': updateData,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _agentDataBox.put('pending_job_updates', pendingUpdates);
  }

  Future<Map<String, dynamic>> getPendingJobUpdates() async {
    return Map<String, dynamic>.from(_agentDataBox.get('pending_job_updates') ?? {});
  }

  Future<void> removePendingJobUpdate(String jobId) async {
    final pendingUpdates = await getPendingJobUpdates();
    pendingUpdates.remove(jobId);
    await _agentDataBox.put('pending_job_updates', pendingUpdates);
  }

  // Sync pending data when connection is restored
  Future<void> _syncPendingData() async {
    await _syncPendingMedia();
    await _syncPendingJobUpdates();
  }

  Future<void> _syncPendingMedia() async {
    final pendingMedia = await getPendingMedia();
    
    for (final entry in pendingMedia.entries) {
      final filePath = entry.key;
      final mediaData = entry.value;
      
      try {
        await _apiClient.uploadFile(filePath, jobId: mediaData['job_id']);
        await markMediaAsUploaded(filePath);
        print('Successfully uploaded cached media: $filePath');
      } catch (e) {
        print('Failed to upload cached media: $filePath, error: $e');
      }
    }
  }

  Future<void> _syncPendingJobUpdates() async {
    final pendingUpdates = await getPendingJobUpdates();
    
    for (final entry in pendingUpdates.entries) {
      final jobId = entry.key;
      final updateData = entry.value['data'];
      
      try {
        await _apiClient.updateJobStatus(jobId, updateData['status'], data: updateData);
        await removePendingJobUpdate(jobId);
        print('Successfully synced job update: $jobId');
      } catch (e) {
        print('Failed to sync job update: $jobId, error: $e');
      }
    }
  }

  // Cache validation
  bool isCacheValid(String cacheKey) {
    final cachedAt = _agentDataBox.get('${cacheKey}_cached_at');
    if (cachedAt == null) return false;
    
    final cacheTime = DateTime.parse(cachedAt);
    final now = DateTime.now();
    const cacheValidDuration = Duration(hours: 1); // Cache valid for 1 hour
    
    return now.difference(cacheTime) < cacheValidDuration;
  }

  Future<void> clearCache() async {
    await _agentDataBox.clear();
    await _jobsCacheBox.clear();
    await _mediaCacheBox.clear();
  }

  Future<void> clearExpiredCache() async {
    // Remove expired cached data
    final keys = ['profile', 'available_jobs'];
    
    for (final key in keys) {
      if (!isCacheValid(key)) {
        await _agentDataBox.delete(key);
        await _agentDataBox.delete('${key}_cached_at');
      }
    }
  }
}