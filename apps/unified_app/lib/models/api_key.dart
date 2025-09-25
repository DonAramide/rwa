enum ApiKeyType { master, read, write, readWrite }
enum ApiKeyStatus { active, inactive, expired, revoked }
enum ApiKeyScope { superAdmin, bankAdmin, verifier, public }

class ApiKey {
  final String id;
  final String name;
  final String service;
  final String key;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final List<String> permissions;
  final ApiKeyType? type;
  final ApiKeyStatus? status;
  final ApiKeyScope? scope;
  final DateTime? expiresAt;
  final String? createdBy;
  final String? revokedBy;
  final DateTime? revokedAt;
  final int? usageCount;
  final int? rateLimitPerHour;

  const ApiKey({
    required this.id,
    required this.name,
    required this.service,
    required this.key,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.lastUsed,
    required this.permissions,
    this.type,
    this.status,
    this.scope,
    this.expiresAt,
    this.createdBy,
    this.revokedBy,
    this.revokedAt,
    this.usageCount,
    this.rateLimitPerHour,
  });

  factory ApiKey.fromJson(Map<String, dynamic> json) {
    return ApiKey(
      id: json['id'] as String,
      name: json['name'] as String,
      service: json['service'] as String,
      key: json['key'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
      permissions: List<String>.from(json['permissions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service': service,
      'key': key,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'permissions': permissions,
    };
  }

  ApiKey copyWith({
    String? id,
    String? name,
    String? service,
    String? key,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsed,
    List<String>? permissions,
  }) {
    return ApiKey(
      id: id ?? this.id,
      name: name ?? this.name,
      service: service ?? this.service,
      key: key ?? this.key,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      permissions: permissions ?? this.permissions,
    );
  }

  String get maskedKey {
    if (key.length <= 8) return '••••••••';
    return '${key.substring(0, 4)}••••••••${key.substring(key.length - 4)}';
  }
}

enum ApiKeyService {
  googleMaps,
  stripe,
  twillio,
  sendGrid,
  firebase,
  aws,
  custom,
}

extension ApiKeyServiceExtension on ApiKeyService {
  String get displayName {
    switch (this) {
      case ApiKeyService.googleMaps:
        return 'Google Maps';
      case ApiKeyService.stripe:
        return 'Stripe';
      case ApiKeyService.twillio:
        return 'Twilio';
      case ApiKeyService.sendGrid:
        return 'SendGrid';
      case ApiKeyService.firebase:
        return 'Firebase';
      case ApiKeyService.aws:
        return 'AWS';
      case ApiKeyService.custom:
        return 'Custom Service';
    }
  }

  String get value {
    switch (this) {
      case ApiKeyService.googleMaps:
        return 'google_maps';
      case ApiKeyService.stripe:
        return 'stripe';
      case ApiKeyService.twillio:
        return 'twilio';
      case ApiKeyService.sendGrid:
        return 'sendgrid';
      case ApiKeyService.firebase:
        return 'firebase';
      case ApiKeyService.aws:
        return 'aws';
      case ApiKeyService.custom:
        return 'custom';
    }
  }
}

class ApiCallLog {
  final String id;
  final String apiKeyId;
  final String endpoint;
  final String method;
  final int statusCode;
  final DateTime timestamp;
  final double responseTime;
  final String? errorMessage;

  const ApiCallLog({
    required this.id,
    required this.apiKeyId,
    required this.endpoint,
    required this.method,
    required this.statusCode,
    required this.timestamp,
    required this.responseTime,
    this.errorMessage,
  });

  factory ApiCallLog.fromJson(Map<String, dynamic> json) {
    return ApiCallLog(
      id: json['id'] as String,
      apiKeyId: json['apiKeyId'] as String,
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      statusCode: json['statusCode'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      responseTime: (json['responseTime'] as num).toDouble(),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}