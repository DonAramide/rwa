import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final String? email;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.userId,
    this.email,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    String? userId,
    String? email,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      email: email ?? this.email,
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
        await _handleLoginSuccess(response, email);
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
        await _handleLoginSuccess(response, email);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
      
      await _handleLoginSuccess(response, state.email ?? '');
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

  Future<void> _handleLoginSuccess(Map<String, dynamic> response, String email) async {
    final token = response['token'] as String?;
    
    if (token != null) {
      ApiClient.setAuthToken(token);
      
      final newState = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: token,
        userId: null, // Will be extracted from token if needed
        email: email,
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