import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupRankingScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupRankingScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchGroupRanking() async {
    final supabase = Supabase.instance.client;

    final membersRes = await supabase
        .from('group_members')
        .select('user_id, profiles(name, group_points)')
        .eq('group_id', groupId);

    final List<Map<String, dynamic>> members = (membersRes as List).map((e) {
      final profile = e['profiles'];
      final name = profile?['name'] ?? 'Usuário';
      final pointsMap = profile?['group_points'] ?? {};
      final points = pointsMap[groupId]?.toInt() ?? 0;

      return {
        'name': name,
        'points': points,
        'user_id': e['user_id'],
      };
    }).toList();

    members.sort((a, b) => b['points'].compareTo(a['points']));
    return members;
  }

  Widget _buildMedalIcon(int index) {
    const medalTextStyle = TextStyle(fontSize: 22);

    switch (index) {
      case 0:
        return const CircleAvatar(child: Text('🥇', style: medalTextStyle));
      case 1:
        return const CircleAvatar(child: Text('🥈', style: medalTextStyle));
      case 2:
        return const CircleAvatar(child: Text('🥉', style: medalTextStyle));
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey.withOpacity(0.2),
          child: Text('${index + 1}'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking - $groupName'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchGroupRanking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar ranking: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('Nenhum membro com pontos ainda.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = data[index];
              final isCurrentUser = user['user_id'] == currentUserId;

              return ListTile(
                tileColor: isCurrentUser
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: _buildMedalIcon(index),
                title: Text(
                  user['name'],
                  style: TextStyle(
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  '${user['points']} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Theme.of(context).primaryColor : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
