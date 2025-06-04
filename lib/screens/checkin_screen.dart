import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meeting.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Meeting> meetingBox = Hive.box<Meeting>('meetings');
    final now = DateTime.now();

    // Apenas reuniões do mesmo dia
    final todayMeetings = meetingBox.values
        .where((m) =>
    m.date.year == now.year &&
        m.date.month == now.month &&
        m.date.day == now.day)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Marcar Presença')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: todayMeetings.isEmpty
            ? const Center(child: Text('Nenhuma reunião agendada para hoje.'))
            : ListView.builder(
          itemCount: todayMeetings.length,
          itemBuilder: (context, index) {
            final meeting = todayMeetings[index];
            final meetingTime = meeting.date;
            final endCheckInTime = meetingTime.add(const Duration(minutes: 30));
            final now = DateTime.now();

            final isCheckInOpen = now.isAfter(meetingTime) && now.isBefore(endCheckInTime);
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
                    : const Icon(Icons.lock_clock, color: Colors.grey),
                onTap: () {
                  if (hasChecked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Você já marcou presença.')),
                    );
                    return;
                  }

                  if (!isCheckInOpen) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Check-in só está disponível até 30 min após a hora.'),
                      ),
                    );
                    return;
                  }

                  // Marcar presença
                  meeting.attended = true;
                  meeting.save();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Presença confirmada!')),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
