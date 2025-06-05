import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../models/group.dart';
import '../models/meeting.dart';
import '../screens/add_group_screen.dart';
import '../screens/meeting_screen.dart';
import '../screens/join_group_screen.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late Box<Group> groupBox;

  @override
  void initState() {
    super.initState();
    groupBox = Hive.box<Group>('groups');
  }

  void _navigateToAddGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddGroupScreen()),
    ).then((_) => setState(() {}));
  }

  void _navigateToJoinGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Grupos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddGroup(context),
          )
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is! UserAuthenticated) {
            return const Center(child: Text("Usuário não autenticado."));
          }

          final userId = state.user.id;
          final userGroups = groupBox.values
              .where((group) => group.members.contains(userId))
              .toList();

          if (userGroups.isEmpty) {
            return const Center(child: Text("Você ainda não participa de nenhum grupo."));
          }

          return ListView.builder(
            itemCount: userGroups.length,
            itemBuilder: (context, index) {
              final group = userGroups[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(group.name),
                  subtitle: Text('Matéria: ${group.subject}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeetingScreen(group: group),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          onPressed: () => _navigateToJoinGroup(context),
          icon: const Icon(Icons.login),
          label: const Text('Entrar em Grupo Existente'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
