import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meeting.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserAuthenticated) {
          return const Center(child: Text('Você precisa estar logado.'));
        }

        final currentUser = state.user;
        final Box<Meeting> meetingBox = Hive.box<Meeting>('meetings');

        return Scaffold(
          appBar: AppBar(title: const Text('Marcar Presença')),
          body: ValueListenableBuilder(
            valueListenable: meetingBox.listenable(),
            builder: (context, Box<Meeting> box, _) {
              final now = DateTime.now();
              final todayMeetings = box.values
                  .where((m) =>
              m.dateTime.year == now.year &&
                  m.dateTime.month == now.month &&
                  m.dateTime.day == now.day &&
                  m.groupId == currentUser.id)
                  .toList()
                ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

              if (todayMeetings.isEmpty) {
                return const Center(
                    child: Text('Nenhuma reunião agendada para hoje.'));
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: todayMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = todayMeetings[index];
                    final meetingTime = meeting.dateTime;
                    final endCheckInTime =
                    meetingTime.add(const Duration(minutes: 30));
                    final now = DateTime.now();

                    final isCheckInOpen = now.isAfter(meetingTime) &&
                        now.isBefore(endCheckInTime);
                    final hasChecked = meeting.attended;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: hasChecked
                            ? Colors.green[100]
                            : isCheckInOpen
                            ? Colors.blue[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasChecked
                              ? Colors.green
                              : isCheckInOpen
                              ? Colors.blue
                              : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(meeting.title),
                        subtitle: Text(
                          '${meetingTime.hour.toString().padLeft(2, '0')}:${meetingTime.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: hasChecked
                            ? const Icon(Icons.check, color: Colors.green)
                            : isCheckInOpen
                            ? const Icon(Icons.login, color: Colors.blue)
                            : const Icon(Icons.lock_clock,
                            color: Colors.grey),
                        onTap: () {
                          if (hasChecked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Você já marcou presença.')),
                            );
                            return;
                          }

                          if (!isCheckInOpen) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Check-in só está disponível até 30 min após a hora.'),
                              ),
                            );
                            return;
                          }

                          // Marcar presença
                          meeting.attended = true;
                          meeting.save();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Presença confirmada!')),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
