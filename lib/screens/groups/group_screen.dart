import 'package:flutter/material.dart';
import 'package:studysync/models/group.dart';
import 'package:studysync/screens/groups/group_detail_screen.dart';
import 'package:studysync/services/group_service.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GroupService _groupService = GroupService();
  List<Group> groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final loadedGroups = await _groupService.fetchUserGroups();
    setState(() {
      groups = loadedGroups;
      isLoading = false;
    });
  }

  void _enterGroupById(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Entrar em grupo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'ID do grupo'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final joined = await _groupService.joinGroupById(controller.text.trim());
              if (joined) {
                _loadGroups();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao entrar no grupo')),
                );
              }
            },
            child: const Text('Entrar'),
          )
        ],
      ),
    );
  }

  void _createGroup(BuildContext context) {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Criar novo grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do grupo'),
            ),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Matéria'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final created = await _groupService.createGroup(
                name: nameController.text.trim(),
                subject: subjectController.text.trim(),
              );
              if (created) {
                _loadGroups();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao criar grupo')),
                );
              }
            },
            child: const Text('Criar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Grupos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createGroup(context),
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => _enterGroupById(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
          ? const Center(child: Text('Você ainda não participa de nenhum grupo.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (_, index) {
          final group = groups[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(group: group),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(group.name),
                subtitle: Text('Matéria: ${group.subject}'),
                trailing: Text('${group.members.length} membros'),
              ),
            ),
          );
        },
      ),
    );
  }
}
