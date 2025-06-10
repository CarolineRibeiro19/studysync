import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../themes/app_theme.dart';
import '../../widgets/custom_buttom.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dados de exemplo — você pode substituir por dados reais do backend futuramente
    final List<Map<String, dynamic>> rankingData = [
      {'name': 'Alice', 'points': 120},
      {'name': 'Bruno', 'points': 110},
      {'name': 'Carlos', 'points': 95},
      {'name': 'Você', 'points': 80},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
      appBar: AppBar(
        title: const Text('Ranking'),
        centerTitle: true,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserAuthenticated) {
            return ListView.builder(
              itemCount: rankingData.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final entry = rankingData[index];
                final isCurrentUser = entry['name'] == 'Você';

                return Card(
                  color: isCurrentUser
                      ? Theme.of(context).primaryColor.withOpacity(0.10)
                      : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
                      child: Text('${index + 1}'),
                    ),
                    title: Text(entry['name']),
                    trailing: Text('${entry['points']} pts'),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Usuário não autenticado.'));
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 5,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/group');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/checkin');
              break;
          }
        },
      ),

    );
  }
}
