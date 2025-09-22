import 'package:flutter/foundation.dart';

enum DeviceType {
  sensor,
  camera,
  tracker,
  meter,
  gateway;

  String get displayName {
    switch (this) {
      case DeviceType.sensor:
        return 'Sensor';
      case DeviceType.camera:
        return 'Camera';
      case DeviceType.tracker:
        return 'Tracker';
      case DeviceType.meter:
        return 'Smart Meter';
      case DeviceType.gateway:
        return 'Gateway';
    }
  }
}

enum DeviceStatus {
  online,
  offline,
  maintenance,
  error;

  String get displayName {
    switch (this) {
      case DeviceStatus.online:
        return 'Online';
      case DeviceStatus.offline:
        return 'Offline';
      case DeviceStatus.maintenance:
        return 'Maintenance';
      case DeviceStatus.error:
        return 'Error';
    }
  }
}

@immutable
class IoTDevice {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final String assetId;
  final Map<String, dynamic> location;
  final double batteryLevel;
  final DateTime lastPing;
  final Map<String, dynamic> sensorData;
  final List<String> alerts;
  final DateTime installedAt;
  final String firmware;

  const IoTDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.assetId,
    required this.location,
    required this.batteryLevel,
    required this.lastPing,
    required this.sensorData,
    required this.alerts,
    required this.installedAt,
    required this.firmware,
  });

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id'].toString(),
      name: json['name'] as String,
      type: DeviceType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => DeviceType.sensor,
      ),
      status: DeviceStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => DeviceStatus.offline,
      ),
      assetId: json['assetId'].toString(),
      location: json['location'] as Map<String, dynamic>? ?? {},
      batteryLevel: (json['batteryLevel'] as num?)?.toDouble() ?? 0.0,
      lastPing: DateTime.parse(json['lastPing'] as String),
      sensorData: json['sensorData'] as Map<String, dynamic>? ?? {},
      alerts: List<String>.from(json['alerts'] ?? []),
      installedAt: DateTime.parse(json['installedAt'] as String),
      firmware: json['firmware'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'assetId': assetId,
      'location': location,
      'batteryLevel': batteryLevel,
      'lastPing': lastPing.toIso8601String(),
      'sensorData': sensorData,
      'alerts': alerts,
      'installedAt': installedAt.toIso8601String(),
      'firmware': firmware,
    };
  }

  bool get isOnline => status == DeviceStatus.online;

  bool get hasAlerts => alerts.isNotEmpty;

  bool get needsMaintenance =>
      batteryLevel < 20 ||
      DateTime.now().difference(lastPing).inHours > 24 ||
      status == DeviceStatus.maintenance;

  String get statusDisplayName => status.displayName;

  String get typeDisplayName => type.displayName;
}

@immutable
class IoTMetrics {
  final int totalDevices;
  final int onlineDevices;
  final int offlineDevices;
  final int alertCount;
  final double averageBattery;
  final List<String> recentAlerts;
  final Map<String, int> devicesByType;
  final DateTime lastUpdated;

  const IoTMetrics({
    required this.totalDevices,
    required this.onlineDevices,
    required this.offlineDevices,
    required this.alertCount,
    required this.averageBattery,
    required this.recentAlerts,
    required this.devicesByType,
    required this.lastUpdated,
  });

  factory IoTMetrics.fromJson(Map<String, dynamic> json) {
    return IoTMetrics(
      totalDevices: json['totalDevices'] as int? ?? 0,
      onlineDevices: json['onlineDevices'] as int? ?? 0,
      offlineDevices: json['offlineDevices'] as int? ?? 0,
      alertCount: json['alertCount'] as int? ?? 0,
      averageBattery: (json['averageBattery'] as num?)?.toDouble() ?? 0.0,
      recentAlerts: List<String>.from(json['recentAlerts'] ?? []),
      devicesByType: Map<String, int>.from(json['devicesByType'] ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  double get onlinePercentage =>
      totalDevices > 0 ? (onlineDevices / totalDevices) * 100 : 0.0;
}