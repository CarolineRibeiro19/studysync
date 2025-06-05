import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';
import '../models/user.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is UserAuthenticated) {
          final currentUser = state.user;
          final userBox = Hive.box<User>('users');

          // Obter todos os usuários e ordená-los por pontos (decrescente)
          final allUsers = userBox.values.toList()
            ..sort((a, b) => b.points.compareTo(a.points));

          return Scaffold(
            appBar: AppBar(title: const Text('Ranking')),
            body: ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                final isCurrentUser = user.id == currentUser.id;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text('#${index + 1}'),
                  ),
                  title: Text(
                    user.name,
                    style: isCurrentUser
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  ),
                  trailing: Text('${user.points} pts'),
                  tileColor: isCurrentUser ? Colors.deepPurple[50] : null,
                );
              },
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Você precisa estar logado para ver o ranking.'),
            ),
          );
        }
      },
    );
  }
}
