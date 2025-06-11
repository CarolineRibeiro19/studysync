import 'package:flutter/material.dart';
import 'package:studysync/models/group.dart';

class GroupDetailScreen extends StatelessWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: Padding(
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
                  // Chamar função para marcar uma reunião
                },
                child: const Text('Marcar reunião'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
