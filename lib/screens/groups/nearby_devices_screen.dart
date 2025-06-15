import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:hive/hive.dart';
import '../../models/hive_group_model.dart';
import '../../services/nearby_service.dart';
import '../../services/group_service.dart';

class NearbyDevicesScreen extends StatefulWidget {
  final bool isReceiving;

  const NearbyDevicesScreen({Key? key, required this.isReceiving}) : super(key: key);

  @override
  State<NearbyDevicesScreen> createState() => _NearbyDevicesScreenState();
}

class _NearbyDevicesScreenState extends State<NearbyDevicesScreen> {
  final NearbyServiceManager _service = NearbyServiceManager();
  List<Device> _devices = [];
  String? _selectedGroupCode;

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
        print('[Nearby] Dispositivos detectados: ${devices.map((d) => d.deviceName).toList()}');
        setState(() {
          _devices = devices;
        });

        for (var device in devices) {
          if (device.state == SessionState.notConnected) {
            try {
              print('[Nearby] Convidando dispositivo: ${device.deviceName}');
              _service.invite(device);
            } catch (e) {
              print('[Nearby] Erro ao convidar dispositivo: $e');
            }
          }
        }
      },
      onDataReceived: (dynamic data) async {
        if (widget.isReceiving && data is Message) {
          final receivedCode = data.message;
          final success = await _joinGroupByCode(receivedCode);
          _showConfirmationDialog(success, receivedCode);
        }
      },
    );

    if (widget.isReceiving) {
      _service.startAdvertising();
    } else {
      _service.startDiscovery();
    }
  }

  Future<bool> _joinGroupByCode(String code) async {
    final groupService = GroupService();
    return await groupService.joinGroupByInviteCode(code);
  }

  void _shareGroupCode(Device device) async {
    if (device.state == SessionState.connected) {
      if (_selectedGroupCode != null) {
        try {
          await _service.sendMessage(device, jsonEncode({'message': _selectedGroupCode!}));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código enviado com sucesso!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao enviar código: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um grupo para compartilhar.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo não está conectado.')),
      );
    }
  }

  void _showConfirmationDialog(bool success, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convite Recebido'),
        content: Text('Você deseja entrar no grupo com o código: $code?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Recusar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _joinGroupByCode(code);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(success ? 'Você entrou no grupo!' : 'Erro ao entrar no grupo.')),
              );
            },
            child: const Text('Aceitar'),
          ),
        ],
      ),
    );
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
                  child: Text('${group['name']} (${group['code']})'),
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
    final groupBox = Hive.box<HiveGroup>('groups');
    if (!groupBox.isOpen) {
      print('[Hive] A HiveBox não está aberta.');
      return [];
    }

    return groupBox.values.map((group) {
      return {
        'name': group.name,
        'code': group.inviteCode,
      };
    }).toList();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}