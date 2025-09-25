import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_stats.dart';
import '../models/asset.dart';

class AdminService {
  static const String baseUrl = 'http://localhost:3000/v1';

  // Mock data for now since the real admin endpoints need authentication
  static Future<AdminStats> getDashboardStats() async {
    // For now, return mock data. In real app, this would call:
    // final response = await http.get(Uri.parse('$baseUrl/admin/dashboard/stats'));

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return AdminStats(
      totalUsers: 156,
      totalAssets: 8,
      activeAssets: 6,
      pendingAssets: 1,
      totalNAV: 32485000.0,
      recentActivity: 23,
    );
  }

  static Future<List<AdminUser>> getUsers({
    int limit = 20,
    int offset = 0,
    Map<String, dynamic>? filters,
  }) async {
    // Mock data for now
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      AdminUser(
        id: 1,
        email: 'admin@rwa-platform.com',
        role: 'admin',
        status: 'active',
        kycVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AdminUser(
        id: 2,
        email: 'investor1@example.com',
        role: 'investor',
        status: 'active',
        kycVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AdminUser(
        id: 3,
        email: 'investor2@example.com',
        role: 'investor',
        status: 'pending',
        kycVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      AdminUser(
        id: 4,
        email: 'agent@example.com',
        role: 'agent',
        status: 'active',
        kycVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      AdminUser(
        id: 5,
        email: 'verifier@example.com',
        role: 'verifier',
        status: 'active',
        kycVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ];
  }

  static Future<List<AdminActivity>> getRecentActivity({
    int limit = 10,
  }) async {
    // Mock data for now
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      AdminActivity(
        id: 1,
        type: 'user_registration',
        description: 'New user registered: investor2@example.com',
        user: 'System',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AdminActivity(
        id: 2,
        type: 'asset_creation',
        description: 'New asset added: Historic Brownstone - Brooklyn, NY',
        user: 'admin@rwa-platform.com',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      AdminActivity(
        id: 3,
        type: 'verification',
        description: 'Asset verification completed: SPV-007',
        user: 'verifier@example.com',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      AdminActivity(
        id: 4,
        type: 'transaction',
        description: 'Investment order placed: \$50,000 in SPV-003',
        user: 'investor1@example.com',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      AdminActivity(
        id: 5,
        type: 'verification',
        description: 'KYC verification approved: agent@example.com',
        user: 'admin@rwa-platform.com',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  static Future<void> verifyAsset(int assetId) async {
    // In real app, this would call:
    // await http.post(Uri.parse('$baseUrl/admin/assets/$assetId/verify'));

    await Future.delayed(const Duration(milliseconds: 500));
    // Mock success
  }

  static Future<void> updateUserStatus(int userId, String status) async {
    // In real app, this would call:
    // await http.patch(Uri.parse('$baseUrl/admin/users/$userId/status'), body: {'status': status});

    await Future.delayed(const Duration(milliseconds: 300));
    // Mock success
  }

  static Future<void> approveKyc(int userId) async {
    // In real app, this would call:
    // await http.patch(Uri.parse('$baseUrl/admin/users/$userId/kyc'), body: {'approved': true});

    await Future.delayed(const Duration(milliseconds: 400));
    // Mock success
  }
}