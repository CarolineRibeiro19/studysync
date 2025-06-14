import 'dart:async';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyServiceManager {
  static final NearbyServiceManager _instance = NearbyServiceManager._internal();
  factory NearbyServiceManager() => _instance;
  NearbyServiceManager._internal();

  final NearbyService _nearbyService = NearbyService();
  late StreamSubscription _stateSubscription;
  late StreamSubscription _dataSubscription;

  final List<Device> _connectedDevices = [];

  bool _isInitialized = false;

  Future<void> init({
    required String serviceType,
    required Strategy strategy,
    String? deviceName,
    required Function(List<Device>) onStateChanged,
    required Function(dynamic) onDataReceived,
  }) async {
    if (_isInitialized) return;

    // Solicitar permissões necessárias
    await _requestPermissions();

    await _nearbyService.init(
      serviceType: serviceType,
      strategy: strategy,
      deviceName: deviceName,
      callback: () {
        print('[Nearby] Service initialized.');
      },
    );

    _stateSubscription = _nearbyService.stateChangedSubscription(
      callback: (devicesList) {
        print('[Nearby] State changed: $devicesList');
        _updateConnectedDevices(devicesList);
        onStateChanged(devicesList);
      },
    );

    _dataSubscription = _nearbyService.dataReceivedSubscription(
      callback: (data) {
        print('[Nearby] Data received: $data');
        onDataReceived(data);
      },
    );

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];

    for (var permission in permissions) {
      if (!await permission.isGranted) {
        final status = await permission.request();
        if (!status.isGranted) {
          throw Exception('Permissão ${permission.value} negada.');
        }
      }
    }
  }

  void _updateConnectedDevices(List<Device> updatedDevices) {
    _connectedDevices
      ..clear()
      ..addAll(updatedDevices.where((d) => d.state == SessionState.connected));
  }

  List<Device> get connectedDevices => List.unmodifiable(_connectedDevices);

  Future<void> startAdvertising() async {
    print('[Nearby] Start advertising...');
    await _nearbyService.startAdvertisingPeer();
  }

  Future<void> startDiscovery() async {
    print('[Nearby] Start discovering...');
    await _nearbyService.startBrowsingForPeers();
  }

  Future<void> stopAdvertising() async {
    print('[Nearby] Stop advertising.');
    await _nearbyService.stopAdvertisingPeer();
  }

  Future<void> stopDiscovery() async {
    print('[Nearby] Stop discovery.');
    await _nearbyService.stopBrowsingForPeers();
  }

  Future<void> invite(Device device) async {
    print('[Nearby] Invite: ${device.deviceName}');
    await _nearbyService.invitePeer(
      deviceID: device.deviceId,
      deviceName: device.deviceName,
    );
  }

  Future<void> disconnect(Device device) async {
    print('[Nearby] Disconnect: ${device.deviceName}');
    await _nearbyService.disconnectPeer(deviceID: device.deviceId);
  }

  Future<void> sendMessage(Device device, String message) async {
    print('[Nearby] Sending message to ${device.deviceName}: $message');
    await _nearbyService.sendMessage(device.deviceId, message);
  }

  Future<void> dispose() async {
    print('[Nearby] Disposing nearby service...');
    await _stateSubscription.cancel();
    await _dataSubscription.cancel();
    _isInitialized = false;
  }
}