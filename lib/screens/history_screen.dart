import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meeting.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Meeting> meetingBox = Hive.box<Meeting>('meetings');
    final DateTime today = DateTime.now();

    final List<Meeting> pastMeetings = meetingBox.values
        .where((meeting) => meeting.date.isBefore(today))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // mais recente primeiro

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Reuniões')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pastMeetings.isEmpty
            ? const Center(child: Text('Nenhuma reunião passada encontrada.'))
            : ListView.builder(
          itemCount: pastMeetings.length,
          itemBuilder: (context, index) {
            final meeting = pastMeetings[index];
            final color = meeting.attended ? Colors.green[100] : Colors.red[100];
            final textColor = meeting.attended ? Colors.green[800] : Colors.red[800];
            final status = meeting.attended ? 'Compareceu' : 'Faltou';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: textColor!, width: 1),
              ),
              child: ListTile(
                title: Text(
                  meeting.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${meeting.date.day.toString().padLeft(2, '0')}/'
                      '${meeting.date.month.toString().padLeft(2, '0')}/'
                      '${meeting.date.year} - $status',
                  style: TextStyle(color: textColor),
                ),
                trailing: Icon(
                  meeting.attended ? Icons.check_circle : Icons.cancel,
                  color: textColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
