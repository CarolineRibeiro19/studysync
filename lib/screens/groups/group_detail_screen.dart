import 'package:flutter/material.dart';
import 'package:studysync/models/group.dart';
import 'package:studysync/services/group_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late Group group;
  bool isLoading = true;
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    final updatedGroup = await _groupService.fetchGroupById(widget.group.id);
    if (updatedGroup != null) {
      setState(() {
        group = updatedGroup;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matéria: ${group.subject}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Membros:', style: const TextStyle(fontWeight: FontWeight.bold)),
            ...group.members.map((m) => Text('- $m')),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aqui você pode chamar a função de marcar reunião
                },
                child: const Text('Marcar reunião'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
