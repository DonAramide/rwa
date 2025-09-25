import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_key.dart';
import '../core/api_client.dart';

class ApiKeyState {
  final bool isLoading;
  final List<ApiKey> apiKeys;
  final List<ApiCallLog> callLogs;
  final String? error;

  const ApiKeyState({
    this.isLoading = false,
    this.apiKeys = const [],
    this.callLogs = const [],
    this.error,
  });

  ApiKeyState copyWith({
    bool? isLoading,
    List<ApiKey>? apiKeys,
    List<ApiCallLog>? callLogs,
    String? error,
  }) {
    return ApiKeyState(
      isLoading: isLoading ?? this.isLoading,
      apiKeys: apiKeys ?? this.apiKeys,
      callLogs: callLogs ?? this.callLogs,
      error: error ?? this.error,
    );
  }
}

class ApiKeyNotifier extends StateNotifier<ApiKeyState> {
  ApiKeyNotifier() : super(const ApiKeyState()) {
    loadApiKeys();
  }

  Future<void> loadApiKeys() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.getApiKeys();
      final apiKeys = (response['items'] as List)
          .map((json) => ApiKey.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        isLoading: false,
        apiKeys: apiKeys,
      );
    } catch (e) {
      // Load mock data if API is unavailable
      state = state.copyWith(
        isLoading: false,
        apiKeys: _getMockApiKeys(),
      );
    }
  }

  Future<void> createApiKey({
    required String name,
    required String service,
    required String key,
    String? description,
    required List<String> permissions,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.createApiKey({
        'name': name,
        'service': service,
        'key': key,
        'description': description,
        'permissions': permissions,
      });

      final newApiKey = ApiKey.fromJson(response);
      final updatedKeys = [...state.apiKeys, newApiKey];

      state = state.copyWith(
        isLoading: false,
        apiKeys: updatedKeys,
      );
    } catch (e) {
      // Create mock API key for demo
      final newApiKey = ApiKey(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        service: service,
        key: key,
        description: description,
        isActive: true,
        createdAt: DateTime.now(),
        permissions: permissions,
      );

      final updatedKeys = [...state.apiKeys, newApiKey];

      state = state.copyWith(
        isLoading: false,
        apiKeys: updatedKeys,
      );
    }
  }

  Future<void> updateApiKey(String id, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiClient.updateApiKey(id, updates);
      final updatedApiKey = ApiKey.fromJson(response);

      final updatedKeys = state.apiKeys.map((key) {
        return key.id == id ? updatedApiKey : key;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        apiKeys: updatedKeys,
      );
    } catch (e) {
      // Update mock API key for demo
      final updatedKeys = state.apiKeys.map((key) {
        if (key.id == id) {
          return key.copyWith(
            name: updates['name'] as String? ?? key.name,
            isActive: updates['isActive'] as bool? ?? key.isActive,
            description: updates['description'] as String? ?? key.description,
          );
        }
        return key;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        apiKeys: updatedKeys,
      );
    }
  }

  Future<void> toggleApiKey(String id) async {
    final keyIndex = state.apiKeys.indexWhere((key) => key.id == id);
    if (keyIndex != -1) {
      final currentKey = state.apiKeys[keyIndex];
      await updateApiKey(id, {'isActive': !currentKey.isActive});
    }
  }

  Future<void> deleteApiKey(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ApiClient.deleteApiKey(id);
      final updatedKeys = state.apiKeys.where((key) => key.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        apiKeys: updatedKeys,
      );
    } catch (e) {
      // Delete mock API key for demo
      final updatedKeys = state.apiKeys.where((key) => key.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        apiKeys: updatedKeys,
      );
    }
  }

  Future<void> loadApiCallLogs(String apiKeyId) async {
    try {
      final response = await ApiClient.getApiCallLogs(apiKeyId);
      final callLogs = (response['items'] as List)
          .map((json) => ApiCallLog.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(callLogs: callLogs);
    } catch (e) {
      // Load mock call logs for demo
      state = state.copyWith(callLogs: _getMockCallLogs(apiKeyId));
    }
  }

  List<ApiKey> _getMockApiKeys() {
    return [
      ApiKey(
        id: '1',
        name: 'Google Maps Production',
        service: 'google_maps',
        key: 'AIzaSyCTNAinlHZiX9ZfHs77v_hyeUKkObhsm6k',
        description: 'Google Maps API for asset location mapping and verification',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
        permissions: ['maps', 'geocoding', 'places'],
      ),
      ApiKey(
        id: '2',
        name: 'Stripe Payments',
        service: 'stripe',
        key: 'sk_live_51J5rQ2...',
        description: 'Stripe API for processing payments and transactions',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastUsed: DateTime.now().subtract(const Duration(minutes: 30)),
        permissions: ['payments', 'refunds', 'customers'],
      ),
      ApiKey(
        id: '3',
        name: 'Twilio SMS',
        service: 'twilio',
        key: 'AC234567890abcdef1234567890abcdef',
        description: 'Twilio API for SMS notifications and 2FA',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        lastUsed: DateTime.now().subtract(const Duration(days: 5)),
        permissions: ['sms', 'voice'],
      ),
    ];
  }

  List<ApiCallLog> _getMockCallLogs(String apiKeyId) {
    return [
      ApiCallLog(
        id: '1',
        apiKeyId: apiKeyId,
        endpoint: '/geocoding/v1/json',
        method: 'GET',
        statusCode: 200,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        responseTime: 120.5,
      ),
      ApiCallLog(
        id: '2',
        apiKeyId: apiKeyId,
        endpoint: '/maps/api/js',
        method: 'GET',
        statusCode: 200,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        responseTime: 85.2,
      ),
      ApiCallLog(
        id: '3',
        apiKeyId: apiKeyId,
        endpoint: '/places/v1/autocomplete',
        method: 'GET',
        statusCode: 403,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        responseTime: 45.8,
        errorMessage: 'API key quota exceeded',
      ),
    ];
  }
}

// Providers
final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, ApiKeyState>((ref) {
  return ApiKeyNotifier();
});

// Computed providers
final activeApiKeysProvider = Provider<List<ApiKey>>((ref) {
  return ref.watch(apiKeyProvider).apiKeys.where((key) => key.isActive).toList();
});

final googleMapsApiKeyProvider = Provider<String?>((ref) {
  final apiKeys = ref.watch(apiKeyProvider).apiKeys;
  final googleMapsKey = apiKeys
      .where((key) => key.service == 'google_maps' && key.isActive)
      .firstOrNull;
  return googleMapsKey?.key;
});