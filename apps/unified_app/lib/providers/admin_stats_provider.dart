import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_stats.dart';
import '../services/admin_service.dart';

// Admin Stats State
class AdminStatsState {
  final AdminStats? stats;
  final List<AdminActivity> activities;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const AdminStatsState({
    this.stats,
    this.activities = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  AdminStatsState copyWith({
    AdminStats? stats,
    List<AdminActivity>? activities,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return AdminStatsState(
      stats: stats ?? this.stats,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasData => stats != null;
  bool get isStale => lastUpdated == null ||
    DateTime.now().difference(lastUpdated!).inMinutes > 5;
}

// Admin Stats Notifier
class AdminStatsNotifier extends StateNotifier<AdminStatsState> {
  AdminStatsNotifier() : super(const AdminStatsState());

  Future<void> loadDashboardData({bool forceRefresh = false}) async {
    if (!forceRefresh && state.hasData && !state.isStale) {
      return; // Data is fresh, no need to reload
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load stats and activities in parallel
      final results = await Future.wait([
        AdminService.getDashboardStats(),
        AdminService.getRecentActivity(limit: 10),
      ]);

      final stats = results[0] as AdminStats;
      final activities = results[1] as List<AdminActivity>;

      state = state.copyWith(
        stats: stats,
        activities: activities,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void addActivity(AdminActivity activity) {
    final updatedActivities = [activity, ...state.activities];
    if (updatedActivities.length > 10) {
      updatedActivities.removeLast();
    }

    state = state.copyWith(activities: updatedActivities);
  }

  void updateStats({
    int? totalUsers,
    int? totalAssets,
    int? activeAssets,
    int? pendingAssets,
    double? totalNAV,
    int? recentActivity,
  }) {
    if (state.stats == null) return;

    final updatedStats = AdminStats(
      totalUsers: totalUsers ?? state.stats!.totalUsers,
      totalAssets: totalAssets ?? state.stats!.totalAssets,
      activeAssets: activeAssets ?? state.stats!.activeAssets,
      pendingAssets: pendingAssets ?? state.stats!.pendingAssets,
      totalNAV: totalNAV ?? state.stats!.totalNAV,
      recentActivity: recentActivity ?? state.stats!.recentActivity,
    );

    state = state.copyWith(stats: updatedStats);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const AdminStatsState();
  }
}

// Provider
final adminStatsProvider = StateNotifierProvider<AdminStatsNotifier, AdminStatsState>(
  (ref) => AdminStatsNotifier(),
);

// Computed providers for specific data
final dashboardStatsProvider = Provider<AdminStats?>((ref) {
  return ref.watch(adminStatsProvider).stats;
});

final recentActivitiesProvider = Provider<List<AdminActivity>>((ref) {
  return ref.watch(adminStatsProvider).activities;
});

final adminStatsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminStatsProvider).isLoading;
});

final adminStatsErrorProvider = Provider<String?>((ref) {
  return ref.watch(adminStatsProvider).error;
});

// Auto-refresh provider that triggers periodic updates
final autoRefreshAdminStatsProvider = Provider<void>((ref) {
  final notifier = ref.read(adminStatsProvider.notifier);

  // Load initial data
  notifier.loadDashboardData();

  // Set up periodic refresh every 2 minutes
  final timer = Stream.periodic(const Duration(minutes: 2));
  ref.listen<int>(
    Provider((ref) => DateTime.now().millisecondsSinceEpoch ~/ (2 * 60 * 1000)),
    (previous, next) {
      notifier.loadDashboardData();
    },
  );
});