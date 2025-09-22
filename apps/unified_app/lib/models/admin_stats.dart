class AdminStats {
  final int totalUsers;
  final int totalAssets;
  final int activeAssets;
  final int pendingAssets;
  final double totalNAV;
  final int recentActivity;

  AdminStats({
    required this.totalUsers,
    required this.totalAssets,
    required this.activeAssets,
    required this.pendingAssets,
    required this.totalNAV,
    required this.recentActivity,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalAssets: json['totalAssets'] ?? 0,
      activeAssets: json['activeAssets'] ?? 0,
      pendingAssets: json['pendingAssets'] ?? 0,
      totalNAV: (json['totalNAV'] ?? 0.0).toDouble(),
      recentActivity: json['recentActivity'] ?? 0,
    );
  }

  String get formattedTotalNAV {
    if (totalNAV >= 1000000000) {
      return '\$${(totalNAV / 1000000000).toStringAsFixed(1)}B';
    } else if (totalNAV >= 1000000) {
      return '\$${(totalNAV / 1000000).toStringAsFixed(1)}M';
    } else if (totalNAV >= 1000) {
      return '\$${(totalNAV / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${totalNAV.toStringAsFixed(0)}';
    }
  }
}

class AdminUser {
  final int id;
  final String email;
  final String role;
  final String status;
  final bool kycVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.kycVerified,
    required this.createdAt,
    this.lastLogin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      role: json['role'] ?? 'investor',
      status: json['status'] ?? 'active',
      kycVerified: json['kycVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }

  String get statusColor {
    switch (status) {
      case 'active':
        return 'success';
      case 'suspended':
        return 'error';
      case 'pending':
        return 'warning';
      default:
        return 'secondary';
    }
  }
}

class AdminActivity {
  final int id;
  final String type;
  final String description;
  final String user;
  final DateTime timestamp;

  AdminActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.user,
    required this.timestamp,
  });

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    return AdminActivity(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      user: json['user'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String get typeIcon {
    switch (type) {
      case 'user_registration':
        return 'person_add';
      case 'asset_creation':
        return 'add_business';
      case 'verification':
        return 'verified';
      case 'transaction':
        return 'attach_money';
      default:
        return 'info';
    }
  }
}