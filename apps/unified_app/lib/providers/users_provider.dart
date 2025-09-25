import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

// User data models
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String joinDate;
  final String lastLogin;
  final String phone;
  final String kycStatus;
  final double? totalInvestments;
  final double? portfolioValue;
  final String? companyName;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.lastLogin,
    required this.phone,
    required this.kycStatus,
    this.totalInvestments,
    this.portfolioValue,
    this.companyName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      joinDate: json['joinDate'] as String,
      lastLogin: json['lastLogin'] as String,
      phone: json['phone'] as String,
      kycStatus: json['kycStatus'] as String,
      totalInvestments: (json['totalInvestments'] as num?)?.toDouble(),
      portfolioValue: (json['portfolioValue'] as num?)?.toDouble(),
      companyName: json['companyName'] as String?,
    );
  }
}

class Agent {
  final String id;
  final String name;
  final String type;
  final double rating;
  final int completedTasks;
  final int activeTasks;
  final double revenue;
  final String location;
  final String kycStatus;
  final String joinDate;
  final String email;
  final String phone;
  final List<String> specialties;
  final String status;
  final String lastActive;

  const Agent({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.completedTasks,
    required this.activeTasks,
    required this.revenue,
    required this.location,
    required this.kycStatus,
    required this.joinDate,
    required this.email,
    required this.phone,
    required this.specialties,
    required this.status,
    required this.lastActive,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'].toString(),
      name: json['name'] as String,
      type: json['type'] as String,
      rating: (json['rating'] as num).toDouble(),
      completedTasks: json['completedTasks'] as int,
      activeTasks: json['activeTasks'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      location: json['location'] as String,
      kycStatus: json['kycStatus'] as String,
      joinDate: json['joinDate'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      specialties: List<String>.from(json['specialties'] as List),
      status: json['status'] as String,
      lastActive: json['lastActive'] as String,
    );
  }
}

class SystemActivity {
  final String id;
  final String action;
  final String user;
  final String userId;
  final String timestamp;
  final String type;
  final String details;

  const SystemActivity({
    required this.id,
    required this.action,
    required this.user,
    required this.userId,
    required this.timestamp,
    required this.type,
    required this.details,
  });

  factory SystemActivity.fromJson(Map<String, dynamic> json) {
    return SystemActivity(
      id: json['id'].toString(),
      action: json['action'] as String,
      user: json['user'] as String,
      userId: json['userId'] as String,
      timestamp: json['timestamp'] as String,
      type: json['type'] as String,
      details: json['details'] as String,
    );
  }
}

// Users state
class UsersState {
  final bool isLoading;
  final List<User> users;
  final String? error;
  final int totalUsers;
  final int currentPage;
  final int totalPages;

  const UsersState({
    this.isLoading = false,
    this.users = const [],
    this.error,
    this.totalUsers = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  UsersState copyWith({
    bool? isLoading,
    List<User>? users,
    String? error,
    int? totalUsers,
    int? currentPage,
    int? totalPages,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: error ?? this.error,
      totalUsers: totalUsers ?? this.totalUsers,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// Agents state
class AgentsState {
  final bool isLoading;
  final List<Agent> agents;
  final String? error;
  final int totalAgents;
  final int currentPage;
  final int totalPages;

  const AgentsState({
    this.isLoading = false,
    this.agents = const [],
    this.error,
    this.totalAgents = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  AgentsState copyWith({
    bool? isLoading,
    List<Agent>? agents,
    String? error,
    int? totalAgents,
    int? currentPage,
    int? totalPages,
  }) {
    return AgentsState(
      isLoading: isLoading ?? this.isLoading,
      agents: agents ?? this.agents,
      error: error ?? this.error,
      totalAgents: totalAgents ?? this.totalAgents,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// Activities state
class ActivitiesState {
  final bool isLoading;
  final List<SystemActivity> activities;
  final String? error;
  final int totalActivities;
  final int currentPage;
  final int totalPages;

  const ActivitiesState({
    this.isLoading = false,
    this.activities = const [],
    this.error,
    this.totalActivities = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  ActivitiesState copyWith({
    bool? isLoading,
    List<SystemActivity>? activities,
    String? error,
    int? totalActivities,
    int? currentPage,
    int? totalPages,
  }) {
    return ActivitiesState(
      isLoading: isLoading ?? this.isLoading,
      activities: activities ?? this.activities,
      error: error ?? this.error,
      totalActivities: totalActivities ?? this.totalActivities,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// Users notifier
class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier() : super(const UsersState());

  Future<void> loadUsers({
    int page = 1,
    String? role,
    String? status,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.getAllUsers(
        page: page,
        role: role,
        status: status,
        search: search,
      );

      final usersData = response['users'] as List;
      final users = usersData
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();

      final pagination = response['pagination'] as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        users: users,
        totalUsers: pagination['total'] as int,
        currentPage: pagination['page'] as int,
        totalPages: pagination['totalPages'] as int,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await ApiClient.updateUserStatus(userId, status);
      // Reload the users list to reflect changes
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Agents notifier
class AgentsNotifier extends StateNotifier<AgentsState> {
  AgentsNotifier() : super(const AgentsState());

  Future<void> loadAgents({
    int page = 1,
    String? type,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.getAllAgents(
        page: page,
        type: type,
        status: status,
      );

      final agentsData = response['agents'] as List;
      final agents = agentsData
          .map((json) => Agent.fromJson(json as Map<String, dynamic>))
          .toList();

      final pagination = response['pagination'] as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        agents: agents,
        totalAgents: pagination['total'] as int,
        currentPage: pagination['page'] as int,
        totalPages: pagination['totalPages'] as int,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Activities notifier
class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  ActivitiesNotifier() : super(const ActivitiesState());

  Future<void> loadActivities({
    int page = 1,
    String? type,
    String? timeRange,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.getSystemActivities(
        page: page,
        type: type,
        timeRange: timeRange,
      );

      final activitiesData = response['activities'] as List;
      final activities = activitiesData
          .map((json) => SystemActivity.fromJson(json as Map<String, dynamic>))
          .toList();

      final pagination = response['pagination'] as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        activities: activities,
        totalActivities: pagination['total'] as int,
        currentPage: pagination['page'] as int,
        totalPages: pagination['totalPages'] as int,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Providers
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier();
});

final agentsProvider = StateNotifierProvider<AgentsNotifier, AgentsState>((ref) {
  return AgentsNotifier();
});

final activitiesProvider = StateNotifierProvider<ActivitiesNotifier, ActivitiesState>((ref) {
  return ActivitiesNotifier();
});