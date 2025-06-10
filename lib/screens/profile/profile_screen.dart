import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../../themes/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
      appBar: AppBar(title: const Text('Perfil')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserAuthenticated) {
            final user = state.user;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: ${user.name}', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Email: ${user.email}', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text('Grupo: ${user.groupId}', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text('Pontos: ${user.points}', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(LogoutUser());
                      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                    },
                    child: const Text('Sair'),
                  )
                ],
              ),
            );
          } else {
            return const Center(child: Text('Usuário não autenticado.'));
          }
        },
      ),
    );
  }
}
