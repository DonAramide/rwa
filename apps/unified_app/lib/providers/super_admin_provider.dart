import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/merchant_models.dart';

// Global platform metrics
class PlatformMetrics {
  final int totalUsers;
  final int totalMerchants;
  final double totalAssetValue;
  final double totalRevenue;
  final int totalTransactions;
  final double monthlyGrowthRate;
  final Map<String, int> usersByRole;
  final Map<String, double> revenueByMerchant;
  final List<SystemAlert> alerts;

  const PlatformMetrics({
    required this.totalUsers,
    required this.totalMerchants,
    required this.totalAssetValue,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.monthlyGrowthRate,
    required this.usersByRole,
    required this.revenueByMerchant,
    required this.alerts,
  });

  factory PlatformMetrics.fromJson(Map<String, dynamic> json) {
    return PlatformMetrics(
      totalUsers: json['totalUsers'] as int,
      totalMerchants: json['totalMerchants'] as int,
      totalAssetValue: (json['totalAssetValue'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalTransactions: json['totalTransactions'] as int,
      monthlyGrowthRate: (json['monthlyGrowthRate'] as num).toDouble(),
      usersByRole: Map<String, int>.from(json['usersByRole'] as Map),
      revenueByMerchant: Map<String, double>.from(json['revenueByMerchant'] as Map),
      alerts: (json['alerts'] as List)
          .map((alert) => SystemAlert.fromJson(alert))
          .toList(),
    );
  }
}

// System health metrics
class SystemHealth {
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int activeConnections;
  final double responseTime;
  final double uptime;
  final List<ServiceStatus> services;
  final List<PerformanceMetric> performanceMetrics;

  const SystemHealth({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.activeConnections,
    required this.responseTime,
    required this.uptime,
    required this.services,
    required this.performanceMetrics,
  });

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    return SystemHealth(
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      memoryUsage: (json['memoryUsage'] as num).toDouble(),
      diskUsage: (json['diskUsage'] as num).toDouble(),
      activeConnections: json['activeConnections'] as int,
      responseTime: (json['responseTime'] as num).toDouble(),
      uptime: (json['uptime'] as num).toDouble(),
      services: (json['services'] as List)
          .map((service) => ServiceStatus.fromJson(service))
          .toList(),
      performanceMetrics: (json['performanceMetrics'] as List)
          .map((metric) => PerformanceMetric.fromJson(metric))
          .toList(),
    );
  }
}

class SystemAlert {
  final String id;
  final String type; // 'warning', 'error', 'info'
  final String title;
  final String message;
  final DateTime timestamp;
  final String? merchantId;
  final bool isResolved;

  const SystemAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.merchantId,
    required this.isResolved,
  });

  factory SystemAlert.fromJson(Map<String, dynamic> json) {
    return SystemAlert(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      merchantId: json['merchantId'] as String?,
      isResolved: json['isResolved'] as bool,
    );
  }
}

class ServiceStatus {
  final String name;
  final String status; // 'healthy', 'warning', 'error'
  final String? version;
  final DateTime lastCheck;
  final double? responseTime;
  final String? errorMessage;

  const ServiceStatus({
    required this.name,
    required this.status,
    this.version,
    required this.lastCheck,
    this.responseTime,
    this.errorMessage,
  });

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      name: json['name'] as String,
      status: json['status'] as String,
      version: json['version'] as String?,
      lastCheck: DateTime.parse(json['lastCheck'] as String),
      responseTime: (json['responseTime'] as num?)?.toDouble(),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

class PerformanceMetric {
  final String name;
  final List<double> values;
  final List<DateTime> timestamps;
  final String unit;

  const PerformanceMetric({
    required this.name,
    required this.values,
    required this.timestamps,
    required this.unit,
  });

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      name: json['name'] as String,
      values: (json['values'] as List).cast<double>(),
      timestamps: (json['timestamps'] as List)
          .map((ts) => DateTime.parse(ts as String))
          .toList(),
      unit: json['unit'] as String,
    );
  }
}

// Super admin state
class SuperAdminState {
  final bool isLoading;
  final String? error;
  final PlatformMetrics? metrics;
  final SystemHealth? systemHealth;
  final List<MerchantProfile> merchants;
  final List<SystemAlert> alerts;
  final DateTime? lastUpdated;

  const SuperAdminState({
    this.isLoading = false,
    this.error,
    this.metrics,
    this.systemHealth,
    this.merchants = const [],
    this.alerts = const [],
    this.lastUpdated,
  });

  SuperAdminState copyWith({
    bool? isLoading,
    String? error,
    PlatformMetrics? metrics,
    SystemHealth? systemHealth,
    List<MerchantProfile>? merchants,
    List<SystemAlert>? alerts,
    DateTime? lastUpdated,
  }) {
    return SuperAdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      metrics: metrics ?? this.metrics,
      systemHealth: systemHealth ?? this.systemHealth,
      merchants: merchants ?? this.merchants,
      alerts: alerts ?? this.alerts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class SuperAdminNotifier extends StateNotifier<SuperAdminState> {
  SuperAdminNotifier() : super(const SuperAdminState());

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load all super admin data in parallel
      final results = await Future.wait([
        _loadPlatformMetrics(),
        _loadSystemHealth(),
        _loadMerchantsData(),
        _loadSystemAlerts(),
      ]);

      state = state.copyWith(
        isLoading: false,
        metrics: results[0] as PlatformMetrics?,
        systemHealth: results[1] as SystemHealth?,
        merchants: results[2] as List<MerchantProfile>,
        alerts: results[3] as List<SystemAlert>,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data: $e',
      );
    }
  }

  Future<void> refreshAllData() async {
    await loadDashboardData();
  }

  Future<void> loadReportsData() async {
    // Implementation for loading reports data
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API call for reports data
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAuditLogs() async {
    // Implementation for loading audit logs
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API call for audit logs
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<PlatformMetrics?> _loadPlatformMetrics() async {
    try {
      final response = await ApiClient.getPlatformMetrics();
      return PlatformMetrics.fromJson(response);
    } catch (e) {
      // Return mock data if API fails
      return _getMockPlatformMetrics();
    }
  }

  Future<SystemHealth?> _loadSystemHealth() async {
    try {
      final response = await ApiClient.getSystemHealth();
      return SystemHealth.fromJson(response);
    } catch (e) {
      // Return mock data if API fails
      return _getMockSystemHealth();
    }
  }

  Future<List<MerchantProfile>> _loadMerchantsData() async {
    try {
      final response = await ApiClient.getAllMerchants();
      return (response['merchants'] as List)
          .map((merchant) => MerchantProfile.fromJson(merchant))
          .toList();
    } catch (e) {
      // Return mock data if API fails
      return _getMockMerchants();
    }
  }

  Future<List<SystemAlert>> _loadSystemAlerts() async {
    try {
      final response = await ApiClient.getSystemAlerts();
      return (response['alerts'] as List)
          .map((alert) => SystemAlert.fromJson(alert))
          .toList();
    } catch (e) {
      // Return mock data if API fails
      return _getMockAlerts();
    }
  }

  // Merchant management methods
  Future<void> approveMerchant(String merchantId) async {
    try {
      await ApiClient.updateMerchantStatus(merchantId, 'approved');
      await loadDashboardData(); // Refresh data
    } catch (e) {
      state = state.copyWith(error: 'Failed to approve merchant: $e');
    }
  }

  Future<void> suspendMerchant(String merchantId) async {
    try {
      await ApiClient.updateMerchantStatus(merchantId, 'suspended');
      await loadDashboardData(); // Refresh data
    } catch (e) {
      state = state.copyWith(error: 'Failed to suspend merchant: $e');
    }
  }

  Future<void> resolveAlert(String alertId) async {
    try {
      await ApiClient.resolveSystemAlert(alertId);
      final updatedAlerts = state.alerts.map((alert) {
        if (alert.id == alertId) {
          return SystemAlert(
            id: alert.id,
            type: alert.type,
            title: alert.title,
            message: alert.message,
            timestamp: alert.timestamp,
            merchantId: alert.merchantId,
            isResolved: true,
          );
        }
        return alert;
      }).toList();

      state = state.copyWith(alerts: updatedAlerts);
    } catch (e) {
      state = state.copyWith(error: 'Failed to resolve alert: $e');
    }
  }

  // Mock data methods
  PlatformMetrics _getMockPlatformMetrics() {
    return PlatformMetrics(
      totalUsers: 15847,
      totalMerchants: 23,
      totalAssetValue: 847500000.0,
      totalRevenue: 12540000.0,
      totalTransactions: 89234,
      monthlyGrowthRate: 8.7,
      usersByRole: {
        'Investor-Agents': 12450,
        'Professional Agents': 1820,
        'Verifiers': 967,
        'Bank Admins': 145,
        'Bank Partners': 23,
      },
      revenueByMerchant: {
        'Premier Bank': 3250000.0,
        'Global Investment': 2890000.0,
        'Capital Partners': 2150000.0,
        'Others': 4250000.0,
      },
      alerts: _getMockAlerts(),
    );
  }

  SystemHealth _getMockSystemHealth() {
    final now = DateTime.now();
    return SystemHealth(
      cpuUsage: 45.2,
      memoryUsage: 67.8,
      diskUsage: 23.4,
      activeConnections: 12847,
      responseTime: 89.5,
      uptime: 99.97,
      services: [
        ServiceStatus(
          name: 'API Gateway',
          status: 'healthy',
          version: '1.2.3',
          lastCheck: now.subtract(const Duration(minutes: 1)),
          responseTime: 45.2,
        ),
        ServiceStatus(
          name: 'Database',
          status: 'healthy',
          version: '14.2',
          lastCheck: now.subtract(const Duration(minutes: 2)),
          responseTime: 12.8,
        ),
        ServiceStatus(
          name: 'Redis Cache',
          status: 'warning',
          version: '6.2.7',
          lastCheck: now.subtract(const Duration(minutes: 1)),
          responseTime: 156.3,
          errorMessage: 'High memory usage detected',
        ),
        ServiceStatus(
          name: 'Message Queue',
          status: 'healthy',
          version: '3.9.1',
          lastCheck: now.subtract(const Duration(seconds: 45)),
          responseTime: 23.1,
        ),
      ],
      performanceMetrics: [
        PerformanceMetric(
          name: 'Response Time',
          values: [89.5, 92.1, 87.3, 85.6, 91.2, 88.9],
          timestamps: List.generate(6, (i) => now.subtract(Duration(hours: i))),
          unit: 'ms',
        ),
        PerformanceMetric(
          name: 'CPU Usage',
          values: [45.2, 43.8, 47.1, 44.9, 46.3, 42.7],
          timestamps: List.generate(6, (i) => now.subtract(Duration(hours: i))),
          unit: '%',
        ),
      ],
    );
  }

  List<MerchantProfile> _getMockMerchants() {
    final now = DateTime.now();
    return [
      MerchantProfile(
        id: 'merchant_1',
        name: 'Premier Investment Merchant',
        legalName: 'Premier Investment Merchant Limited',
        registrationNumber: 'PIB2023001',
        country: 'United States',
        domain: 'premier-merchant.com',
        subdomain: 'invest',
        status: 'active',
        commissionRateBps: 150,
        revenueShareBps: 3000,
        contractStartDate: now.subtract(const Duration(days: 365)),
        description: 'Leading provider of real-world asset investment opportunities',
        branding: const MerchantBranding(
          logoUrl: 'https://via.placeholder.com/120x40/2196F3/FFFFFF?text=PIB',
          primaryColor: '#2196F3',
          secondaryColor: '#1976D2',
        ),
        contactInfo: const MerchantContactInfo(
          primaryContact: 'John Smith',
          email: 'contact@premier-merchant.com',
          phone: '+1 (555) 123-4567',
          address: '123 Wall Street, New York, NY 10005',
        ),
        totalRevenue: 15847329.50,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        totalUsers: 2847,
      ),
      MerchantProfile(
        id: 'merchant_2',
        name: 'Global Investment Merchants',
        legalName: 'Global Investment Merchants Inc.',
        registrationNumber: 'GIP2023002',
        country: 'United Kingdom',
        domain: 'global-invest.co.uk',
        status: 'pending',
        commissionRateBps: 175,
        revenueShareBps: 2800,
        contractStartDate: now.subtract(const Duration(days: 90)),
        description: 'International asset management and investment services',
        branding: const MerchantBranding(
          logoUrl: 'https://via.placeholder.com/120x40/4CAF50/FFFFFF?text=GIP',
          primaryColor: '#4CAF50',
          secondaryColor: '#388E3C',
        ),
        contactInfo: const MerchantContactInfo(
          primaryContact: 'Sarah Johnson',
          email: 'info@global-invest.co.uk',
          phone: '+44 20 7123 4567',
          address: '456 Canary Wharf, London E14 5AB, UK',
        ),
        totalRevenue: 8923156.25,
        createdAt: now.subtract(const Duration(days: 95)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        totalUsers: 1923,
      ),
      MerchantProfile(
        id: 'merchant_3',
        name: 'Asia Pacific Merchants',
        legalName: 'Asia Pacific Merchants Pte Ltd',
        registrationNumber: 'APC2023003',
        country: 'Singapore',
        domain: 'apac-capital.sg',
        subdomain: 'invest',
        status: 'active',
        commissionRateBps: 125,
        revenueShareBps: 3200,
        contractStartDate: now.subtract(const Duration(days: 180)),
        description: 'Premier asset management firm specializing in APAC markets',
        branding: const MerchantBranding(
          logoUrl: 'https://via.placeholder.com/120x40/FF9800/FFFFFF?text=APC',
          primaryColor: '#FF9800',
          secondaryColor: '#F57C00',
        ),
        contactInfo: const MerchantContactInfo(
          primaryContact: 'Michael Wong',
          email: 'contact@apac-capital.sg',
          phone: '+65 6789 0123',
          address: '1 Marina Bay Sands, Singapore 018956',
        ),
        totalRevenue: 12456789.75,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        totalUsers: 3456,
      ),
    ];
  }

  List<SystemAlert> _getMockAlerts() {
    final now = DateTime.now();
    return [
      SystemAlert(
        id: 'alert_1',
        type: 'warning',
        title: 'High Memory Usage',
        message: 'Redis cache memory usage is above 80% threshold',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isResolved: false,
      ),
      SystemAlert(
        id: 'alert_2',
        type: 'info',
        title: 'New Bank Registration',
        message: 'Capital Partners Bank has submitted registration documents',
        timestamp: now.subtract(const Duration(hours: 2)),
        merchantId: 'merchant_3',
        isResolved: false,
      ),
      SystemAlert(
        id: 'alert_3',
        type: 'error',
        title: 'Payment Processing Failed',
        message: 'Multiple payment failures detected for Premier Bank customers',
        timestamp: now.subtract(const Duration(hours: 4)),
        merchantId: 'merchant_1',
        isResolved: true,
      ),
    ];
  }
}

// Providers
final superAdminProvider = StateNotifierProvider<SuperAdminNotifier, SuperAdminState>((ref) {
  return SuperAdminNotifier();
});

// Computed providers
final platformMetricsProvider = Provider<PlatformMetrics?>((ref) {
  return ref.watch(superAdminProvider).metrics;
});

final systemHealthProvider = Provider<SystemHealth?>((ref) {
  return ref.watch(superAdminProvider).systemHealth;
});

final activeMerchantsProvider = Provider<List<MerchantProfile>>((ref) {
  return ref.watch(superAdminProvider).merchants
      .where((merchant) => merchant.status == 'active')
      .toList();
});

final pendingMerchantsProvider = Provider<List<MerchantProfile>>((ref) {
  return ref.watch(superAdminProvider).merchants
      .where((merchant) => merchant.status == 'pending')
      .toList();
});

final unresolvedAlertsProvider = Provider<List<SystemAlert>>((ref) {
  return ref.watch(superAdminProvider).alerts
      .where((alert) => !alert.isResolved)
      .toList();
});