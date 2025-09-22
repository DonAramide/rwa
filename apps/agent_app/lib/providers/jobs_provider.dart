import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job_model.dart';
import '../core/api_client.dart';
import '../services/offline_service.dart';

final jobsProvider = StateNotifierProvider<JobsNotifier, JobsState>((ref) {
  return JobsNotifier();
});

class JobsState {
  final List<JobModel> availableJobs;
  final List<JobModel> activeJobs;
  final List<JobModel> completedJobs;
  final bool isLoading;
  final String? error;
  final double monthlyEarnings;

  JobsState({
    this.availableJobs = const [],
    this.activeJobs = const [],
    this.completedJobs = const [],
    this.isLoading = false,
    this.error,
    this.monthlyEarnings = 0.0,
  });

  JobsState copyWith({
    List<JobModel>? availableJobs,
    List<JobModel>? activeJobs,
    List<JobModel>? completedJobs,
    bool? isLoading,
    String? error,
    double? monthlyEarnings,
  }) {
    return JobsState(
      availableJobs: availableJobs ?? this.availableJobs,
      activeJobs: activeJobs ?? this.activeJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
    );
  }
}

class JobsNotifier extends StateNotifier<JobsState> {
  final ApiClient _apiClient = ApiClient();

  JobsNotifier() : super(JobsState());

  Future<void> loadAvailableJobs() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final jobs = await _apiClient.getAvailableJobs();
      await OfflineService.instance.cacheJobs(jobs);
      
      state = state.copyWith(
        availableJobs: jobs,
        isLoading: false,
      );
    } catch (e) {
      // Try to load from cache
      final cachedJobs = await OfflineService.instance.getCachedJobs();
      state = state.copyWith(
        availableJobs: cachedJobs ?? [],
        isLoading: false,
        error: cachedJobs == null ? e.toString() : null,
      );
    }
  }

  Future<void> loadMyJobs() async {
    try {
      final active = await _apiClient.getMyJobs(status: 'in_progress');
      final completed = await _apiClient.getMyJobs(status: 'completed');
      
      state = state.copyWith(
        activeJobs: active,
        completedJobs: completed,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> acceptJob(String jobId) async {
    try {
      await _apiClient.acceptJob(jobId);
      await loadAvailableJobs();
      await loadMyJobs();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _apiClient.updateJobStatus(jobId, status);
      await loadMyJobs();
    } catch (e) {
      // Cache for offline sync
      await OfflineService.instance.cacheJobUpdate(jobId, {'status': status});
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateJobMedia(String jobId, List<String> mediaUrls) async {
    try {
      // Upload media files
      final uploadedUrls = await _apiClient.uploadFiles(mediaUrls, jobId: jobId);
      
      // Update job with media URLs
      await _apiClient.updateJobStatus(jobId, 'media_uploaded', data: {
        'media_urls': uploadedUrls,
      });
      
      await loadMyJobs();
    } catch (e) {
      // Cache for offline sync
      await OfflineService.instance.cacheJobUpdate(jobId, {
        'status': 'media_uploaded',
        'media_urls': mediaUrls,
      });
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> submitReport(String jobId, Map<String, dynamic> reportData) async {
    try {
      await _apiClient.submitReport(jobId, reportData);
      await loadMyJobs();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}