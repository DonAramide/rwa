import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

// Agent models
class Agent {
  final String id;
  final String userId;
  final String status;
  final List<String> regions;
  final List<String> skills;
  final String bio;
  final String kycLevel;
  final double ratingAvg;
  final int ratingCount;
  final DateTime createdAt;

  const Agent({
    required this.id,
    required this.userId,
    required this.status,
    required this.regions,
    required this.skills,
    required this.bio,
    required this.kycLevel,
    required this.ratingAvg,
    required this.ratingCount,
    required this.createdAt,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      status: json['status'] as String,
      regions: List<String>.from(json['regions'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'] as String,
      kycLevel: json['kycLevel'] as String,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class VerificationJob {
  final String id;
  final String assetId;
  final String investorId;
  final String? agentId;
  final String status;
  final double price;
  final String currency;
  final String? escrowPaymentId;
  final DateTime? slaDueAt;
  final DateTime createdAt;

  const VerificationJob({
    required this.id,
    required this.assetId,
    required this.investorId,
    this.agentId,
    required this.status,
    required this.price,
    required this.currency,
    this.escrowPaymentId,
    this.slaDueAt,
    required this.createdAt,
  });

  factory VerificationJob.fromJson(Map<String, dynamic> json) {
    return VerificationJob(
      id: json['id'].toString(),
      assetId: json['assetId'].toString(),
      investorId: json['investorId'].toString(),
      agentId: json['agentId']?.toString(),
      status: json['status'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      escrowPaymentId: json['escrowPaymentId']?.toString(),
      slaDueAt: json['slaDueAt'] != null ? DateTime.parse(json['slaDueAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class VerificationReport {
  final String id;
  final String jobId;
  final String summary;
  final Map<String, dynamic> checklist;
  final List<String> photos;
  final List<String> videos;
  final Map<String, dynamic>? gpsPath;
  final List<String> docHashes;
  final DateTime submittedAt;

  const VerificationReport({
    required this.id,
    required this.jobId,
    required this.summary,
    required this.checklist,
    required this.photos,
    required this.videos,
    this.gpsPath,
    required this.docHashes,
    required this.submittedAt,
  });

  factory VerificationReport.fromJson(Map<String, dynamic> json) {
    return VerificationReport(
      id: json['id'].toString(),
      jobId: json['jobId'].toString(),
      summary: json['summary'] as String,
      checklist: json['checklist'] as Map<String, dynamic>,
      photos: List<String>.from(json['photos'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      gpsPath: json['gpsPath'] as Map<String, dynamic>?,
      docHashes: List<String>.from(json['docHashes'] ?? []),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }
}

// Agents state
class AgentsState {
  final bool isLoading;
  final List<Agent> agents;
  final String? error;
  final bool hasMore;
  final int total;
  final List<String>? selectedRegions;
  final List<String>? selectedSkills;
  final double? minRating;

  const AgentsState({
    this.isLoading = false,
    this.agents = const [],
    this.error,
    this.hasMore = false,
    this.total = 0,
    this.selectedRegions,
    this.selectedSkills,
    this.minRating,
  });

  AgentsState copyWith({
    bool? isLoading,
    List<Agent>? agents,
    String? error,
    bool? hasMore,
    int? total,
    List<String>? selectedRegions,
    List<String>? selectedSkills,
    double? minRating,
  }) {
    return AgentsState(
      isLoading: isLoading ?? this.isLoading,
      agents: agents ?? this.agents,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      selectedRegions: selectedRegions ?? this.selectedRegions,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      minRating: minRating ?? this.minRating,
    );
  }
}

// Agents notifier
class AgentsNotifier extends StateNotifier<AgentsState> {
  AgentsNotifier() : super(const AgentsState());

  Future<void> loadAgents({
    bool refresh = false,
    List<String>? regions,
    List<String>? skills,
    double? minRating,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        agents: [],
        error: null,
        selectedRegions: regions,
        selectedSkills: skills,
        minRating: minRating,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await ApiClient.searchAgents(
        limit: 20,
        offset: refresh ? 0 : state.agents.length,
        regions: regions ?? state.selectedRegions,
        skills: skills ?? state.selectedSkills,
        minRating: minRating ?? state.minRating,
      );

      final List<Agent> newAgents = (response['items'] as List)
          .map((json) => Agent.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        agents: refresh ? newAgents : [...state.agents, ...newAgents],
        hasMore: response['hasMore'] as bool,
        total: response['total'] as int,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<VerificationJob> createVerificationJob({
    required String assetId,
    required String agentId,
    required double price,
    required String currency,
  }) async {
    try {
      final response = await ApiClient.createVerificationJob(
        assetId: assetId,
        agentId: agentId,
        price: price,
        currency: currency,
      );
      return VerificationJob.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create verification job: $e');
    }
  }

  Future<VerificationReport> getVerificationReport(String reportId) async {
    try {
      final response = await ApiClient.getVerificationReport(reportId);
      return VerificationReport.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get verification report: $e');
    }
  }

  void setFilters({
    List<String>? regions,
    List<String>? skills,
    double? minRating,
  }) {
    state = state.copyWith(
      selectedRegions: regions,
      selectedSkills: skills,
      minRating: minRating,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      selectedRegions: null,
      selectedSkills: null,
      minRating: null,
    );
  }
}

// Providers
final agentsProvider = StateNotifierProvider<AgentsNotifier, AgentsState>((ref) {
  return AgentsNotifier();
});

// Computed providers
final filteredAgentsProvider = Provider<List<Agent>>((ref) {
  final agents = ref.watch(agentsProvider).agents;
  final regions = ref.watch(agentsProvider).selectedRegions;
  final skills = ref.watch(agentsProvider).selectedSkills;
  final minRating = ref.watch(agentsProvider).minRating;

  return agents.where((agent) {
    if (regions != null && regions.isNotEmpty) {
      if (!agent.regions.any((region) => regions.contains(region))) return false;
    }
    if (skills != null && skills.isNotEmpty) {
      if (!agent.skills.any((skill) => skills.contains(skill))) return false;
    }
    if (minRating != null && agent.ratingAvg < minRating) return false;
    return true;
  }).toList();
});

final availableRegionsProvider = Provider<List<String>>((ref) {
  final agents = ref.watch(agentsProvider).agents;
  final regions = <String>{};
  for (final agent in agents) {
    regions.addAll(agent.regions);
  }
  return regions.toList()..sort();
});

final availableSkillsProvider = Provider<List<String>>((ref) {
  final agents = ref.watch(agentsProvider).agents;
  final skills = <String>{};
  for (final agent in agents) {
    skills.addAll(agent.skills);
  }
  return skills.toList()..sort();
});


