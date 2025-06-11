import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/meeting/meeting_bloc.dart';
import '../../blocs/meeting/meeting_event.dart';
import '../../blocs/meeting/meeting_state.dart';
import '../../models/meeting.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MeetingBloc>().add(LoadMeetings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: BlocBuilder<MeetingBloc, MeetingState>(
        builder: (context, state) {
          if (state is MeetingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MeetingLoaded) {
            final todayMeetings = state.meetings;
            if (todayMeetings.isEmpty) {
              return const Center(child: Text('Nenhuma reunião hoje.'));
            }

            return ListView.builder(
              itemCount: todayMeetings.length,
              itemBuilder: (context, index) {
                final meeting = todayMeetings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(meeting.title),
                    subtitle: Text(
                      'Hora: ${meeting.dateTime.hour.toString().padLeft(2, '0')}:${meeting.dateTime.minute.toString().padLeft(2, '0')} | Local: ${meeting.location}',
                    ),
                    trailing: meeting.attended
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    onTap: () {
                      // Aqui será implementada lógica futura de check-in por GPS/acelerômetro
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Check-in será ativado em breve!')),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is MeetingError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Carregando...'));
          }
        },
      ),
    );
  }
}
