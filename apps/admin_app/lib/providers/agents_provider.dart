import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import 'auth_provider.dart';

final agentsProvider = StateNotifierProvider<AgentsNotifier, AgentsState>((ref) {
  return AgentsNotifier(ref.read(apiClientProvider));
});

class AgentsState {
  final List<Map<String, dynamic>> agents;
  final bool isLoading;
  final String? error;
  final int total;
  final bool hasMore;
  final Map<String, dynamic>? selectedAgent;

  AgentsState({
    this.agents = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.hasMore = false,
    this.selectedAgent,
  });

  AgentsState copyWith({
    List<Map<String, dynamic>>? agents,
    bool? isLoading,
    String? error,
    int? total,
    bool? hasMore,
    Map<String, dynamic>? selectedAgent,
  }) {
    return AgentsState(
      agents: agents ?? this.agents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      selectedAgent: selectedAgent ?? this.selectedAgent,
    );
  }
}

class AgentsNotifier extends StateNotifier<AgentsState> {
  final ApiClient _apiClient;
  
  AgentsNotifier(this._apiClient) : super(AgentsState());

  Future<void> loadAgents({
    String? status,
    List<String>? regions,
    int limit = 20,
    int offset = 0,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiClient.getAgents(
        status: status,
        regions: regions,
        limit: limit,
        offset: offset,
      );

      // The API client returns a List directly
      final List<Map<String, dynamic>> newAgents = 
          (response as List).cast<Map<String, dynamic>>();

      List<Map<String, dynamic>> allAgents;
      if (loadMore) {
        allAgents = [...state.agents, ...newAgents];
      } else {
        allAgents = newAgents;
      }

      state = state.copyWith(
        agents: allAgents,
        isLoading: false,
        hasMore: newAgents.length == limit,
        total: state.total + newAgents.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAgent(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final agent = await _apiClient.getAgent(id);
      state = state.copyWith(
        selectedAgent: agent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateAgentStatus(int id, String status, String? notes) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiClient.updateAgentStatus(id, status, notes);
      
      // Update the agent status in the list
      final updatedAgents = state.agents.map((agent) {
        if (agent['id'] == id) {
          return {
            ...agent,
            'status': status,
            'admin_notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          };
        }
        return agent;
      }).toList();

      state = state.copyWith(
        agents: updatedAgents,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> approveAgent(int id, String? notes) async {
    await updateAgentStatus(id, 'approved', notes);
  }

  Future<void> suspendAgent(int id, String? notes) async {
    await updateAgentStatus(id, 'suspended', notes);
  }

  Future<void> rejectAgent(int id, String? notes) async {
    await updateAgentStatus(id, 'rejected', notes);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelectedAgent() {
    state = state.copyWith(selectedAgent: null);
  }

  // Filter helpers
  List<Map<String, dynamic>> get pendingAgents =>
      state.agents.where((agent) => agent['status'] == 'pending').toList();

  List<Map<String, dynamic>> get approvedAgents =>
      state.agents.where((agent) => agent['status'] == 'approved').toList();

  List<Map<String, dynamic>> get suspendedAgents =>
      state.agents.where((agent) => agent['status'] == 'suspended').toList();

  List<Map<String, dynamic>> get rejectedAgents =>
      state.agents.where((agent) => agent['status'] == 'rejected').toList();

  Map<String, int> get agentsByRegion {
    final Map<String, int> regions = {};
    for (final agent in state.agents) {
      final agentRegions = agent['regions'] as List?;
      if (agentRegions != null) {
        for (final region in agentRegions) {
          regions[region] = (regions[region] ?? 0) + 1;
        }
      }
    }
    return regions;
  }

  Map<String, int> get agentsByStatus {
    final Map<String, int> statuses = {};
    for (final agent in state.agents) {
      final status = agent['status'] as String;
      statuses[status] = (statuses[status] ?? 0) + 1;
    }
    return statuses;
  }

  double get averageRating {
    final ratedAgents = state.agents.where((agent) => 
        agent['rating_avg'] != null && (agent['rating_avg'] as num) > 0).toList();
    
    if (ratedAgents.isEmpty) return 0.0;
    
    final totalRating = ratedAgents.fold<double>(0.0, (sum, agent) => 
        sum + (agent['rating_avg'] as num).toDouble());
    
    return totalRating / ratedAgents.length;
  }
}