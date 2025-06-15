
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studysync/blocs/user/user_bloc.dart'; 
import 'package:studysync/blocs/user/user_state.dart'; 
import 'package:studysync/services/group_service.dart'; 
import 'package:studysync/models/group.dart';

import '../../models/hive_group_model.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final GroupService groupService = context.read<GroupService>();

    return Scaffold(
      backgroundColor: theme.primaryColor.withOpacity(0.05),
      appBar: AppBar(
        title: const Text('Meus Pontos por Grupo', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (userState is UserAuthenticated) {
            final userGroupPoints = userState.user.groupPoints;

            if (userGroupPoints.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 100, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text(
                        'Você ainda não tem pontos em nenhum grupo.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Crie um grupo ou participe de reuniões para começar a ganhar pontos!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }


            return FutureBuilder<List<HiveGroup>>(
              future: groupService.fetchUserGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar nomes dos grupos: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum grupo encontrado.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  );
                }

                final List<Group> allUserGroups = snapshot.data!
                    .map((hiveGroup) => hiveGroup.toGroup())
                    .toList();

                final Map<String, String> groupNames = {
                  for (var group in allUserGroups) group.id: group.name,
                };

                
                final List<MapEntry<String, int>> sortedGroupPoints = userGroupPoints.entries
                    .where((entry) => groupNames.containsKey(entry.key)) 
                    .toList()
                    ..sort((a, b) => b.value.compareTo(a.value)); 

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedGroupPoints.length,
                  itemBuilder: (context, index) {
                    final entry = sortedGroupPoints[index];
                    final groupId = entry.key;
                    final points = entry.value;
                    final groupName = groupNames[groupId] ?? 'Grupo Desconhecido'; 

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                              child: Text(
                                groupName.isNotEmpty ? groupName[0].toUpperCase() : '?',
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                groupName,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stars, color: theme.colorScheme.secondary, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$points pts',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (userState is UserError) {
            return Center(child: Text('Erro ao carregar dados do usuário: ${userState.message}'));
          }
          return const Center(child: Text('Nenhum dado de usuário disponível.'));
        },
      ),
    );
  }
}