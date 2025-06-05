import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/group.dart';
import '../models/meeting.dart';
import '../models/user.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';

class MeetingScreen extends StatefulWidget {
  final Group group;
  const MeetingScreen({super.key, required this.group});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late final Box<Meeting> meetingBox;

  @override
  void initState() {
    super.initState();
    meetingBox = Hive.box<Meeting>('meetings');
  }

  void _createMeetingDialog(User user) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  groupId: widget.group.id,
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

  List<Meeting> _getGroupMeetings() {
    return meetingBox.values
        .where((m) => m.groupId == widget.group.id)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  @override
  Widget build(BuildContext context) {
    final meetings = _getGroupMeetings();

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: Text('Reuniões - ${widget.group.name}')),
            body: meetings.isEmpty
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
              onPressed: () => _createMeetingDialog(state.user),
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
