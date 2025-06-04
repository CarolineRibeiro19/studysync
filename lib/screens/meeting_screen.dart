import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/group.dart';
import '../models/meeting.dart';

class MeetingScreen extends StatefulWidget {
  final Group group;
  const MeetingScreen({super.key, required this.group});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late Box<Meeting> meetingBox;

  @override
  void initState() {
    super.initState();
    meetingBox = Hive.box<Meeting>('meetings');
  }

  void _createMeetingDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nova Reunião'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Local'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                      );
                      if (time != null) {
                        selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  },
                  child: const Text('Selecionar Data e Hora'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final location = locationController.text.trim();
                  if (title.isNotEmpty && location.isNotEmpty) {
                    final meeting = Meeting(
                      title: title,
                      location: location,
                      dateTime: selectedDateTime,
                      groupId: "",
                    );
                    meetingBox.add(meeting);
                    setState(() {});
                  }
                  Navigator.pop(context);
                },
                child: const Text('Criar'),
              ),
            ],
          ),
    );
  }

  List<Meeting> _getMeetings() {
    return meetingBox.values
        .where((m) => m.title.startsWith(widget.group.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final meetings = _getMeetings();
    return Scaffold(
      appBar: AppBar(title: Text('Reuniões - ${widget.group.name}')),
      body:
          meetings.isEmpty
              ? const Center(child: Text('Nenhuma reunião marcada.'))
              : ListView.builder(
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final m = meetings[index];
                  return ListTile(
                    title: Text(m.title),
                    subtitle: Text(
                      '${m.location}\n${DateFormat('dd/MM/yyyy – HH:mm').format(m.dateTime)}',
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMeetingDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
