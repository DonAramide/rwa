import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/iot_device.dart';
import '../../../core/api_client.dart';

class IoTDevicesState {
  final bool isLoading;
  final List<IoTDevice> devices;
  final IoTMetrics? metrics;
  final String? error;
  final String? selectedAssetId;

  const IoTDevicesState({
    this.isLoading = false,
    this.devices = const [],
    this.metrics,
    this.error,
    this.selectedAssetId,
  });

  IoTDevicesState copyWith({
    bool? isLoading,
    List<IoTDevice>? devices,
    IoTMetrics? metrics,
    String? error,
    String? selectedAssetId,
  }) {
    return IoTDevicesState(
      isLoading: isLoading ?? this.isLoading,
      devices: devices ?? this.devices,
      metrics: metrics ?? this.metrics,
      error: error ?? this.error,
      selectedAssetId: selectedAssetId ?? this.selectedAssetId,
    );
  }
}

class IoTDevicesNotifier extends StateNotifier<IoTDevicesState> {
  IoTDevicesNotifier() : super(const IoTDevicesState());

  Future<void> loadDevices({String? assetId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final devices = await _getMockDevices(assetId: assetId);
      final metrics = await _getMockMetrics();

      state = state.copyWith(
        isLoading: false,
        devices: devices,
        metrics: metrics,
        selectedAssetId: assetId,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshDevice(String deviceId) async {
    try {
      final deviceIndex = state.devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex == -1) return;

      final updatedDevices = List<IoTDevice>.from(state.devices);
      final device = updatedDevices[deviceIndex];

      updatedDevices[deviceIndex] = IoTDevice(
        id: device.id,
        name: device.name,
        type: device.type,
        status: DeviceStatus.online,
        assetId: device.assetId,
        location: device.location,
        batteryLevel: device.batteryLevel,
        lastPing: DateTime.now(),
        sensorData: {
          ...device.sensorData,
          'temperature': 22.5 + (DateTime.now().millisecond % 10),
          'humidity': 45.0 + (DateTime.now().millisecond % 20),
        },
        alerts: device.alerts,
        installedAt: device.installedAt,
        firmware: device.firmware,
      );

      state = state.copyWith(devices: updatedDevices);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDeviceStatus(String deviceId, DeviceStatus status) async {
    try {
      final deviceIndex = state.devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex == -1) return;

      final updatedDevices = List<IoTDevice>.from(state.devices);
      final device = updatedDevices[deviceIndex];

      updatedDevices[deviceIndex] = IoTDevice(
        id: device.id,
        name: device.name,
        type: device.type,
        status: status,
        assetId: device.assetId,
        location: device.location,
        batteryLevel: device.batteryLevel,
        lastPing: device.lastPing,
        sensorData: device.sensorData,
        alerts: device.alerts,
        installedAt: device.installedAt,
        firmware: device.firmware,
      );

      state = state.copyWith(devices: updatedDevices);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void filterByAsset(String? assetId) {
    state = state.copyWith(selectedAssetId: assetId);
    loadDevices(assetId: assetId);
  }

  static Future<List<IoTDevice>> _getMockDevices({String? assetId}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allDevices = [
      IoTDevice(
        id: 'device_001',
        name: 'Temperature Sensor #1',
        type: DeviceType.sensor,
        status: DeviceStatus.online,
        assetId: 'asset_001',
        location: {'lat': 40.7128, 'lng': -74.0060, 'floor': '2'},
        batteryLevel: 85.5,
        lastPing: DateTime.now().subtract(const Duration(minutes: 2)),
        sensorData: {
          'temperature': 22.5,
          'humidity': 45.2,
          'pressure': 1013.25,
        },
        alerts: [],
        installedAt: DateTime.now().subtract(const Duration(days: 30)),
        firmware: 'v2.1.4',
      ),
      IoTDevice(
        id: 'device_002',
        name: 'Security Camera #1',
        type: DeviceType.camera,
        status: DeviceStatus.online,
        assetId: 'asset_001',
        location: {'lat': 40.7128, 'lng': -74.0060, 'position': 'entrance'},
        batteryLevel: 92.3,
        lastPing: DateTime.now().subtract(const Duration(minutes: 1)),
        sensorData: {
          'motion_detected': false,
          'recording': true,
          'resolution': '1080p',
        },
        alerts: [],
        installedAt: DateTime.now().subtract(const Duration(days: 15)),
        firmware: 'v3.0.1',
      ),
      IoTDevice(
        id: 'device_003',
        name: 'Asset Tracker #1',
        type: DeviceType.tracker,
        status: DeviceStatus.offline,
        assetId: 'asset_002',
        location: {'lat': 40.7589, 'lng': -73.9851},
        batteryLevel: 15.2,
        lastPing: DateTime.now().subtract(const Duration(hours: 6)),
        sensorData: {
          'speed': 0.0,
          'heading': 180.0,
          'altitude': 10.5,
        },
        alerts: ['Low battery', 'Device offline'],
        installedAt: DateTime.now().subtract(const Duration(days: 45)),
        firmware: 'v1.8.2',
      ),
      IoTDevice(
        id: 'device_004',
        name: 'Smart Meter #1',
        type: DeviceType.meter,
        status: DeviceStatus.online,
        assetId: 'asset_001',
        location: {'lat': 40.7128, 'lng': -74.0060, 'utility': 'electricity'},
        batteryLevel: 100.0,
        lastPing: DateTime.now().subtract(const Duration(seconds: 30)),
        sensorData: {
          'power_consumption': 2.4,
          'voltage': 220.5,
          'current': 10.9,
          'total_energy': 1245.6,
        },
        alerts: [],
        installedAt: DateTime.now().subtract(const Duration(days: 60)),
        firmware: 'v4.2.0',
      ),
      IoTDevice(
        id: 'device_005',
        name: 'Environmental Sensor #2',
        type: DeviceType.sensor,
        status: DeviceStatus.maintenance,
        assetId: 'asset_003',
        location: {'lat': 40.7505, 'lng': -73.9934, 'floor': '1'},
        batteryLevel: 67.8,
        lastPing: DateTime.now().subtract(const Duration(minutes: 30)),
        sensorData: {
          'temperature': 19.8,
          'humidity': 52.1,
          'air_quality': 85,
          'noise_level': 45.2,
        },
        alerts: ['Scheduled maintenance'],
        installedAt: DateTime.now().subtract(const Duration(days: 20)),
        firmware: 'v2.3.1',
      ),
      IoTDevice(
        id: 'device_006',
        name: 'Gateway Device #1',
        type: DeviceType.gateway,
        status: DeviceStatus.error,
        assetId: 'asset_002',
        location: {'lat': 40.7589, 'lng': -73.9851, 'floor': 'basement'},
        batteryLevel: 0.0,
        lastPing: DateTime.now().subtract(const Duration(hours: 12)),
        sensorData: {
          'connected_devices': 0,
          'signal_strength': -85,
          'data_throughput': 0.0,
        },
        alerts: ['Gateway offline', 'Power failure'],
        installedAt: DateTime.now().subtract(const Duration(days: 90)),
        firmware: 'v1.5.3',
      ),
    ];

    if (assetId != null) {
      return allDevices.where((device) => device.assetId == assetId).toList();
    }

    return allDevices;
  }

  static Future<IoTMetrics> _getMockMetrics() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return IoTMetrics(
      totalDevices: 6,
      onlineDevices: 3,
      offlineDevices: 1,
      alertCount: 5,
      averageBattery: 73.5,
      recentAlerts: [
        'Low battery on Asset Tracker #1',
        'Gateway Device #1 offline',
        'Scheduled maintenance on Environmental Sensor #2',
        'Power failure detected',
        'Device offline for 6+ hours',
      ],
      devicesByType: {
        'sensor': 2,
        'camera': 1,
        'tracker': 1,
        'meter': 1,
        'gateway': 1,
      },
      lastUpdated: DateTime.now(),
    );
  }
}

final iotDevicesProvider = StateNotifierProvider<IoTDevicesNotifier, IoTDevicesState>((ref) {
  return IoTDevicesNotifier();
});

final iotDevicesByStatusProvider = Provider<Map<DeviceStatus, List<IoTDevice>>>((ref) {
  final devices = ref.watch(iotDevicesProvider).devices;
  final devicesByStatus = <DeviceStatus, List<IoTDevice>>{};

  for (final status in DeviceStatus.values) {
    devicesByStatus[status] = devices.where((device) => device.status == status).toList();
  }

  return devicesByStatus;
});

final iotAlertsProvider = Provider<List<String>>((ref) {
  final devices = ref.watch(iotDevicesProvider).devices;
  final alerts = <String>[];

  for (final device in devices) {
    for (final alert in device.alerts) {
      alerts.add('${device.name}: $alert');
    }
  }

  return alerts;
});