import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../screens/meeting_screen.dart'; // <--- Adicione isso ao topo

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Group> groupBox;

  @override
  void initState() {
    super.initState();
    groupBox = Hive.box<Group>('groups');
  }

  void _showCreateGroupDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Novo Grupo'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do grupo'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final String name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final newGroup = Group(name: name, createdBy: Uuid());
                    groupBox.add(newGroup);
                    setState(() {});
                  }
                  Navigator.pop(context);
                },
                child: const Text('Criar'),
              ),
            ],
          ),
    );
  }

  Widget _buildGroupList() {
    if (groupBox.isEmpty) {
      return const Center(child: Text('Nenhum grupo criado ainda.'));
    }

    return ListView.builder(
      itemCount: groupBox.length,
      itemBuilder: (context, index) {
        final group = groupBox.getAt(index);
        return ListTile(
          title: Text(group!.name),
          subtitle: Text(
            'Criado em: ${DateFormat('dd/MM/yyyy – HH:mm').format(group.createdAt)}',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MeetingScreen(group: group)),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Grupos')),
      body: _buildGroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
