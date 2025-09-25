import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_stats.dart';
import '../services/admin_service.dart';

// Admin Users State
class AdminUsersState {
  final List<AdminUser> users;
  final bool isLoading;
  final String? error;
  final int totalCount;
  final String? currentFilter;

  const AdminUsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.totalCount = 0,
    this.currentFilter,
  });

  AdminUsersState copyWith({
    List<AdminUser>? users,
    bool? isLoading,
    String? error,
    int? totalCount,
    String? currentFilter,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalCount: totalCount ?? this.totalCount,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

// Admin Users Notifier
class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  AdminUsersNotifier() : super(const AdminUsersState());

  Future<void> loadUsers({
    int limit = 50,
    int offset = 0,
    String? roleFilter,
    String? statusFilter,
    bool? kycFilter,
    String? searchQuery,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Build filter query
      final filters = <String, dynamic>{};
      if (roleFilter != null && roleFilter != 'All Roles') {
        filters['role'] = roleFilter.toLowerCase();
      }
      if (statusFilter != null && statusFilter != 'All Status') {
        filters['status'] = statusFilter.toLowerCase();
      }
      if (kycFilter != null) {
        filters['kycVerified'] = kycFilter;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filters['search'] = searchQuery;
      }

      // In a real app, this would call the API with filters
      final users = await AdminService.getUsers(
        limit: limit,
        offset: offset,
        filters: filters,
      );

      // Apply client-side filtering for demo purposes
      final filteredUsers = _applyFilters(users, filters);

      state = state.copyWith(
        users: filteredUsers,
        isLoading: false,
        totalCount: filteredUsers.length,
        currentFilter: _buildFilterString(filters),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  List<AdminUser> _applyFilters(List<AdminUser> users, Map<String, dynamic> filters) {
    var filteredUsers = users;

    if (filters.containsKey('role')) {
      filteredUsers = filteredUsers.where((user) => user.role == filters['role']).toList();
    }

    if (filters.containsKey('status')) {
      filteredUsers = filteredUsers.where((user) => user.status == filters['status']).toList();
    }

    if (filters.containsKey('kycVerified')) {
      filteredUsers = filteredUsers.where((user) => user.kycVerified == filters['kycVerified']).toList();
    }

    if (filters.containsKey('search')) {
      final query = filters['search'].toString().toLowerCase();
      filteredUsers = filteredUsers.where((user) =>
        user.email.toLowerCase().contains(query) ||
        user.role.toLowerCase().contains(query)
      ).toList();
    }

    return filteredUsers;
  }

  String _buildFilterString(Map<String, dynamic> filters) {
    final parts = <String>[];
    filters.forEach((key, value) {
      parts.add('$key: $value');
    });
    return parts.join(', ');
  }

  Future<void> updateUserStatus(int userId, String newStatus) async {
    try {
      await AdminService.updateUserStatus(userId, newStatus);

      // Update the user in the current state
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return AdminUser(
            id: user.id,
            email: user.email,
            role: user.role,
            status: newStatus,
            kycVerified: user.kycVerified,
            createdAt: user.createdAt,
            lastLogin: user.lastLogin,
          );
        }
        return user;
      }).toList();

      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update user status: $e');
    }
  }

  Future<void> approveKyc(int userId) async {
    try {
      await AdminService.approveKyc(userId);

      // Update the user in the current state
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return AdminUser(
            id: user.id,
            email: user.email,
            role: user.role,
            status: user.status,
            kycVerified: true,
            createdAt: user.createdAt,
            lastLogin: user.lastLogin,
          );
        }
        return user;
      }).toList();

      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      state = state.copyWith(error: 'Failed to approve KYC: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const AdminUsersState();
  }
}

// Provider
final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AdminUsersState>(
  (ref) => AdminUsersNotifier(),
);

// Computed providers for specific data
final adminUsersListProvider = Provider<List<AdminUser>>((ref) {
  return ref.watch(adminUsersProvider).users;
});

final adminUsersCountProvider = Provider<int>((ref) {
  return ref.watch(adminUsersProvider).totalCount;
});

final adminUsersLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminUsersProvider).isLoading;
});

final adminUsersErrorProvider = Provider<String?>((ref) {
  return ref.watch(adminUsersProvider).error;
});