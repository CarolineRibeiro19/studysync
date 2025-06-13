import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/meeting/meeting_bloc.dart';
import '../../blocs/meeting/meeting_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../widgets/custom_buttom.dart';
import '../../themes/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
      appBar: AppBar(title: const Text('Histórico')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is! UserAuthenticated) {
            return const Center(child: Text('Usuário não autenticado.'));
          }

          return BlocBuilder<MeetingBloc, MeetingState>(
            builder: (context, meetingState) {
              if (meetingState is MeetingLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (meetingState is MeetingLoaded) {
                final now = DateTime.now();
                final pastMeetings = meetingState.meetings
                    .where((m) => m.dateTime.isBefore(now))
                    .toList();

                if (pastMeetings.isEmpty) {
                  return const Center(child: Text('Nenhuma reunião passada.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pastMeetings.length,
                  itemBuilder: (context, index) {
                    final m = pastMeetings[index];
                    final status = false ? 'Compareceu' : 'Faltou';
                    final color = false ? Colors.green[50] : Colors.red[50];

                    return Card(
                      color: color,
                      child: ListTile(
                        title: Text(m.title),
                        subtitle: Text(
                          '${DateFormat('dd/MM/yyyy – HH:mm').format(m.dateTime)} até ${DateFormat('HH:mm').format(m.endTime)}\n'
                              '${m.location}'
                              '${(m.lat != null && m.long != null) ? '\nLat: ${m.lat!.toStringAsFixed(4)}, Long: ${m.long!.toStringAsFixed(4)}' : ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('Erro ao carregar reuniões.'));
              }
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 4,
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
