import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/group.dart';
import 'add_group_screen.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus Grupos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddGroupScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Group>('groups').listenable(),
        builder: (context, Box<Group> box, _) {
          final groups = box.values.toList();

          if (groups.isEmpty) {
            return const Center(child: Text('Você ainda não tem grupos.'));
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: groups.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final group = groups[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        group.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(group.subject),
                      Text('${group.memberCount} pessoas'),
                      const SizedBox(height: 6),
                      Text('ID: ${group.id.substring(0, 6)}'),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
