import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent_model.dart';
import '../core/api_client.dart';
import '../services/offline_service.dart';

final agentProvider = StateNotifierProvider<AgentNotifier, AgentState>((ref) {
  return AgentNotifier();
});

class AgentState {
  final AgentModel? agent;
  final bool isLoading;
  final String? error;

  AgentState({
    this.agent,
    this.isLoading = false,
    this.error,
  });

  AgentState copyWith({
    AgentModel? agent,
    bool? isLoading,
    String? error,
  }) {
    return AgentState(
      agent: agent ?? this.agent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AgentNotifier extends StateNotifier<AgentState> {
  final ApiClient _apiClient = ApiClient();

  AgentNotifier() : super(AgentState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final agent = await _apiClient.getProfile();
      await OfflineService.instance.cacheAgentData(agent.toJson());
      
      state = state.copyWith(
        agent: agent,
        isLoading: false,
      );
    } catch (e) {
      // Try to load from cache
      final cachedData = await OfflineService.instance.getCachedAgentData();
      if (cachedData != null) {
        state = state.copyWith(
          agent: AgentModel.fromJson(cachedData),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAgent = await _apiClient.updateProfile(data);
      await OfflineService.instance.cacheAgentData(updatedAgent.toJson());
      
      state = state.copyWith(
        agent: updatedAgent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}