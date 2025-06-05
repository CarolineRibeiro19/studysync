import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/group.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';
import 'meeting_screen.dart';

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
            Text('Matéria: ${group.subject}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Membros: ${group.memberCount}', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserAuthenticated) {
                  return Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MeetingScreen(group: group),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Marcar Reunião'),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Você precisa estar logado para marcar uma reunião.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
