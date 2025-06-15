import 'dart:async';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyServiceManager {
  static final NearbyServiceManager _instance = NearbyServiceManager._internal();
  factory NearbyServiceManager() => _instance;
  NearbyServiceManager._internal();

  final NearbyService _nearbyService = NearbyService();
  StreamSubscription? _stateSubscription;
  StreamSubscription? _dataSubscription;

  final List<Device> _connectedDevices = [];
  bool _isInitialized = false;

  Future<void> init({
    required String serviceType,
    required Strategy strategy,
    String? deviceName,
    required Function(List<Device>) onStateChanged,
    required Function(dynamic) onDataReceived,
  }) async {
    if (_isInitialized) {
      print('[Nearby] Serviço já inicializado.');
      return;
    }

    try {
      print('[Nearby] Solicitando permissões...');
      final granted = await _requestPermissions();
      if (!granted) {
        throw Exception('Permissões necessárias não foram concedidas.');
      }

      print('[Nearby] Inicializando serviço...');
      await _nearbyService.init(
        serviceType: serviceType,
        strategy: strategy,
        deviceName: deviceName,
        callback: () {
          print('[Nearby] Serviço inicializado com sucesso.');
        },
      );

      _stateSubscription = _nearbyService.stateChangedSubscription(
        callback: (devicesList) {
          print('[Nearby] Estado alterado: $devicesList');
          _updateConnectedDevices(devicesList);
          onStateChanged(devicesList);
        },
      );

      _dataSubscription = _nearbyService.dataReceivedSubscription(
        callback: (data) {
          print('[Nearby] Dados recebidos: $data');
          onDataReceived(data);
        },
      );

      _isInitialized = true;
    } catch (e) {
      print('[Nearby] Erro ao inicializar o serviço: $e');
      rethrow;
    }
  }

  Future<bool> _requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
    ];

    for (var permission in permissions) {
      if (!await permission.isGranted) {
        print('[Nearby] Solicitando permissão: $permission');
        final status = await permission.request();
        if (!status.isGranted) {
          print('[Nearby] Permissão negada: $permission');
          return false;
        }
      } else {
        print('[Nearby] Permissão já concedida: $permission');
      }
    }

    print('[Nearby] Todas as permissões concedidas.');
    return true;
  }

  void _updateConnectedDevices(List<Device> updatedDevices) {
    print('[Nearby] Atualizando dispositivos conectados: $updatedDevices');
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
    await _stateSubscription?.cancel();
    await _dataSubscription?.cancel();
    _isInitialized = false;
  }
}