import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../../services/nearby_service.dart';

class NearbyDevicesScreen extends StatefulWidget {
  const NearbyDevicesScreen({Key? key}) : super(key: key);

  @override
  State<NearbyDevicesScreen> createState() => _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends State<NearbyDevicesScreen> {
  final NearbyServiceManager _service = NearbyServiceManager();
  List<Device> _devices = [];

  @override
  void initState() {
    super.initState();
    _initNearbyService();
  }

  Future<void> _initNearbyService() async {
    await _service.init(
      serviceType: 'studysyncshare',
      strategy: Strategy.P2P_CLUSTER,
      deviceName: 'StudySyncDevice',
      onStateChanged: (List<Device> devices) {
        setState(() {
          _devices = devices;
        });
      },
      onDataReceived: (dynamic data) {
        if (data is Map && data.containsKey('message')) {
          final msg = data['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mensagem recebida: $msg')),
          );
        }
      },
    );
  }

  void _startAdvertising() => _service.startAdvertising();
  void _startDiscovery() => _service.startDiscovery();
  void _stopAdvertising() => _service.stopAdvertising();
  void _stopDiscovery() => _service.stopDiscovery();

  void _connect(Device device) => _service.invite(device);
  void _disconnect(Device device) => _service.disconnect(device);
  void _send(Device device) => _service.sendMessage(device, 'Olá do StudySync!');

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos por Perto'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _startAdvertising, child: const Text('Anunciar')),
              ElevatedButton(onPressed: _startDiscovery, child: const Text('Procurar')),
              ElevatedButton(onPressed: _stopAdvertising, child: const Text('Parar Anúncio')),
              ElevatedButton(onPressed: _stopDiscovery, child: const Text('Parar Busca')),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return Card(
                  child: ListTile(
                    title: Text(device.deviceName),
                    subtitle: Text('Estado: ${device.state.name}'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        if (device.state == SessionState.connected)
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () => _send(device),
                          ),
                        IconButton(
                          icon: Icon(
                            device.state == SessionState.connected
                                ? Icons.link_off
                                : Icons.link,
                          ),
                          onPressed: () {
                            device.state == SessionState.connected
                                ? _disconnect(device)
                                : _connect(device);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
