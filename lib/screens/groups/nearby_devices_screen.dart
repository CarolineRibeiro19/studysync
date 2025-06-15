import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../../services/nearby_service.dart';
import '../../services/group_service.dart';

class NearbyDevicesScreen extends StatefulWidget {
  final bool isReceiving; // Define se o usuário está recebendo ou compartilhando

  const NearbyDevicesScreen({Key? key, required this.isReceiving}) : super(key: key);

  @override
  State<NearbyDevicesScreen> createState() => _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends State<NearbyDevicesScreen> {
  final NearbyServiceManager _service = NearbyServiceManager();
  List<Device> _devices = [];
  String? _selectedGroupCode; // Código do grupo selecionado para compartilhar

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
      onDataReceived: (dynamic data) async {
        if (widget.isReceiving && data is Map && data.containsKey('message')) {
          final receivedCode = data['message'];
          final success = await _joinGroupByCode(receivedCode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? 'Grupo adicionado com sucesso!' : 'Código inválido.')),
          );
        }
      },
    );

    if (widget.isReceiving) {
      _service.startDiscovery();
    } else {
      _service.startAdvertising();
    }
  }

  Future<bool> _joinGroupByCode(String code) async {
    final groupService = GroupService();
    return await groupService.joinGroupByInviteCode(code);
  }

  void _shareGroupCode(Device device) {
    if (_selectedGroupCode != null) {
      _service.sendMessage(device, _selectedGroupCode!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código enviado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um grupo para compartilhar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReceiving ? 'Receber Código' : 'Compartilhar Código'),
      ),
      body: Column(
        children: [
          if (!widget.isReceiving)
            DropdownButton<String>(
              hint: const Text('Selecione um grupo'),
              value: _selectedGroupCode,
              items: _getUserGroups().map((group) {
                return DropdownMenuItem(
                  value: group['code'],
                  child: Text(group['name'] ?? 'Nome não disponível'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGroupCode = value;
                });
              },
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  title: Text(device.deviceName),
                  subtitle: Text('Estado: ${device.state.name}'),
                  trailing: IconButton(
                    icon: Icon(widget.isReceiving ? Icons.download : Icons.upload),
                    onPressed: () {
                      if (widget.isReceiving) {
                        _service.invite(device);
                      } else {
                        _shareGroupCode(device);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getUserGroups() {
    // Simula a obtenção de grupos do usuário
    return [
      {'name': 'Grupo 1', 'code': 'ABC123'},
      {'name': 'Grupo 2', 'code': 'DEF456'},
    ];
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
