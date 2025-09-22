import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api_client.dart';
import '../models/flag.dart';

class MonitoringService {
  final ApiClient _apiClient;

  MonitoringService(this._apiClient);

  Future<Flag> createFlag(CreateFlagRequest request) async {
    final response = await _apiClient.post('/monitoring/flags', request.toJson());
    return Flag.fromJson(response);
  }

  Future<Flag> voteOnFlag(int flagId, VoteType voteType) async {
    final response = await _apiClient.post(
      '/monitoring/flags/$flagId/vote',
      {'vote_type': voteType.name},
    );
    return Flag.fromJson(response);
  }

  Future<FlagResponse> getFlags({
    int? assetId,
    FlagStatus? status,
    FlagType? type,
    FlagSeverity? severity,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (assetId != null) queryParams['asset_id'] = assetId.toString();
    if (status != null) queryParams['status'] = status.name;
    if (type != null) queryParams['type'] = type.name;
    if (severity != null) queryParams['severity'] = severity.name;

    final response = await _apiClient.get('/monitoring/flags', queryParams: queryParams);
    return FlagResponse.fromJson(response);
  }

  Future<FlagResponse> getMyFlags({
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final response = await _apiClient.get('/monitoring/flags/my-flags', queryParams: queryParams);
    return FlagResponse.fromJson(response);
  }

  Future<Flag> getFlagById(int id) async {
    final response = await _apiClient.get('/monitoring/flags/$id');
    return Flag.fromJson(response);
  }

  Future<FlagResponse> getAssetFlags(int assetId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final response = await _apiClient.get('/monitoring/flags/asset/$assetId', queryParams: queryParams);
    return FlagResponse.fromJson(response);
  }

  Future<InvestorAgentStats> getInvestorAgentStats() async {
    final response = await _apiClient.get('/monitoring/investor-agent/stats');
    return InvestorAgentStats.fromJson(response);
  }

  Future<List<dynamic>> getLeaderboard({int limit = 10}) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };

    final response = await _apiClient.get('/monitoring/leaderboard', queryParams: queryParams);
    return response as List<dynamic>;
  }

  Future<FlagResponse> getPendingFlags() async {
    final response = await _apiClient.get('/monitoring/dashboard/pending-flags');
    return FlagResponse.fromJson(response);
  }

  Future<FlagResponse> getEscalatedFlags() async {
    final response = await _apiClient.get('/monitoring/dashboard/escalated-flags');
    return FlagResponse.fromJson(response);
  }
}