import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flag.dart';
import '../services/monitoring_service.dart';
import '../../../core/providers/api_client_provider.dart';

final monitoringServiceProvider = Provider<MonitoringService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MonitoringService(apiClient);
});

final flagsProvider = FutureProvider.family<FlagResponse, FlagFilters>((ref, filters) {
  final service = ref.watch(monitoringServiceProvider);
  return service.getFlags(
    assetId: filters.assetId,
    status: filters.status,
    type: filters.type,
    severity: filters.severity,
    limit: filters.limit,
    offset: filters.offset,
  );
});

final myFlagsProvider = FutureProvider.family<FlagResponse, PaginationParams>((ref, params) {
  final service = ref.watch(monitoringServiceProvider);
  return service.getMyFlags(
    limit: params.limit,
    offset: params.offset,
  );
});

final assetFlagsProvider = FutureProvider.family<FlagResponse, AssetFlagsParams>((ref, params) {
  final service = ref.watch(monitoringServiceProvider);
  return service.getAssetFlags(
    params.assetId,
    limit: params.limit,
    offset: params.offset,
  );
});

final investorAgentStatsProvider = FutureProvider<InvestorAgentStats>((ref) {
  final service = ref.watch(monitoringServiceProvider);
  return service.getInvestorAgentStats();
});

final leaderboardProvider = FutureProvider.family<List<dynamic>, int>((ref, limit) {
  final service = ref.watch(monitoringServiceProvider);
  return service.getLeaderboard(limit: limit);
});

final pendingFlagsProvider = FutureProvider<FlagResponse>((ref) {
  final service = ref.watch(monitoringServiceProvider);
  return service.getPendingFlags();
});

final escalatedFlagsProvider = FutureProvider<FlagResponse>((ref) {
  final service = ref.watch(monitoringServiceProvider);
  return service.getEscalatedFlags();
});

// State management for creating flags
final createFlagProvider = StateNotifierProvider<CreateFlagNotifier, AsyncValue<Flag?>>((ref) {
  final service = ref.watch(monitoringServiceProvider);
  return CreateFlagNotifier(service);
});

class CreateFlagNotifier extends StateNotifier<AsyncValue<Flag?>> {
  final MonitoringService _service;

  CreateFlagNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> createFlag(CreateFlagRequest request) async {
    state = const AsyncValue.loading();
    try {
      final flag = await _service.createFlag(request);
      state = AsyncValue.data(flag);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Filter and pagination classes
class FlagFilters {
  final int? assetId;
  final FlagStatus? status;
  final FlagType? type;
  final FlagSeverity? severity;
  final int limit;
  final int offset;

  const FlagFilters({
    this.assetId,
    this.status,
    this.type,
    this.severity,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlagFilters &&
          runtimeType == other.runtimeType &&
          assetId == other.assetId &&
          status == other.status &&
          type == other.type &&
          severity == other.severity &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode =>
      assetId.hashCode ^
      status.hashCode ^
      type.hashCode ^
      severity.hashCode ^
      limit.hashCode ^
      offset.hashCode;
}

class PaginationParams {
  final int limit;
  final int offset;

  const PaginationParams({
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationParams &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => limit.hashCode ^ offset.hashCode;
}

class AssetFlagsParams {
  final int assetId;
  final int limit;
  final int offset;

  const AssetFlagsParams({
    required this.assetId,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetFlagsParams &&
          runtimeType == other.runtimeType &&
          assetId == other.assetId &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => assetId.hashCode ^ limit.hashCode ^ offset.hashCode;
}