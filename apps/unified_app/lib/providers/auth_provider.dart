import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/user_role.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final String? email;
  final UserRole? userRole;
  final List<UserRole> availableRoles;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.userId,
    this.email,
    this.userRole,
    this.availableRoles = const [],
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    String? userId,
    String? email,
    UserRole? userRole,
    List<UserRole>? availableRoles,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
      availableRoles: availableRoles ?? this.availableRoles,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ApiClient.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      
      // Handle 2FA requirement
      if (response['requires2FA'] == true) {
        state = state.copyWith(
          isLoading: false,
          error: 'Please check your email for 2FA code',
        );
      } else {
        // Direct login success
        await _handleLoginSuccess(response, email, null);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
    UserRole? role,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ApiClient.login(
        email: email,
        password: password,
      );
      
      // Handle 2FA requirement
      if (response['requires2FA'] == true) {
        state = state.copyWith(
          isLoading: false,
          error: 'Please check your email for 2FA code',
        );
      } else {
        // Direct login success
        await _handleLoginSuccess(response, email, role);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loginWithBiometrics() async {
    // Placeholder for biometric authentication
    throw Exception('Biometric authentication not yet implemented');
  }

  void setSelectedRole(UserRole role) {
    state = state.copyWith(userRole: role);
  }

  void switchRole(UserRole newRole) {
    if (state.availableRoles.contains(newRole)) {
      state = state.copyWith(userRole: newRole);
    }
  }

  Future<void> verify2FA({
    required String token,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await ApiClient.verify2FA(
        token: token,
        code: code,
      );
      
      await _handleLoginSuccess(response, state.email ?? '', null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    ApiClient.clearAuthToken();
    state = const AuthState();
  }

  Future<void> submitKYC(Map<String, dynamic> kycData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await ApiClient.submitKYC(kycData: kycData);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> checkKYCStatus() async {
    try {
      await ApiClient.getKYCStatus();
      // Update KYC status in state if needed
    } catch (e) {
      // Handle error silently for KYC check
    }
  }

  Future<void> _handleLoginSuccess(Map<String, dynamic> response, String email, UserRole? role) async {
    final token = response['token'] as String?;

    if (token != null) {
      ApiClient.setAuthToken(token);

      // Extract user data and role from response
      final user = response['user'] as Map<String, dynamic>?;
      final userId = user?['id'] as String?;

      // Map role from API response to UserRole enum
      UserRole userRole;
      List<UserRole> availableRoles;

      if (role != null) {
        // Role was passed explicitly (legacy support)
        userRole = role;
        availableRoles = [role];
      } else if (user?['role'] != null) {
        // Map string role from API response to enum
        userRole = _mapStringToUserRole(user!['role'] as String);
        availableRoles = [userRole];
      } else {
        // Default fallback
        userRole = UserRole.investorAgent;
        availableRoles = UserRole.values;
      }

      final newState = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: token,
        userId: userId,
        email: email,
        userRole: userRole,
        availableRoles: availableRoles,
        error: null,
      );

      state = newState;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid login response',
      );
    }
  }

  UserRole _mapStringToUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'investor':
      case 'investor_agent':
        return UserRole.investorAgent;
      case 'professional_agent':
      case 'agent':
        return UserRole.professionalAgent;
      case 'verifier':
        return UserRole.verifier;
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
      case 'superadmin':
        return UserRole.superAdmin;
      case 'bank_white_label':
      case 'bankwhitelabel':
        return UserRole.merchantWhiteLabel;
      default:
        return UserRole.investorAgent;
    }
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Computed providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return null;
  
  return {
    'id': auth.userId,
    'email': auth.email,
    'token': auth.token,
  };
});