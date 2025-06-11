import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:studysync/blocs/meeting/meeting_bloc.dart';
import 'package:studysync/blocs/meeting/meeting_event.dart';
import 'package:studysync/blocs/meeting/meeting_state.dart';
import 'package:studysync/models/group.dart';
import 'package:studysync/models/meeting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  String? inviteCode;

  @override
  void initState() {
    super.initState();
    context.read<MeetingBloc>().add(LoadGroupMeetings(widget.group.id));
    _loadInviteCode();
  }

  Future<void> _loadInviteCode() async {
    final response = await Supabase.instance.client
        .from('group_invites')
        .select('code')
        .eq('group_id', widget.group.id)
        .maybeSingle();

    if (response != null && mounted) {
      setState(() {
        inviteCode = response['code'];
      });
    }
  }

  Future<void> _marcarReuniao(BuildContext context) async {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      final place = placemarks.first;
      locationController.text =
      '${place.street}, ${place.subLocality}, ${place.locality} - ${place.administrativeArea}';
    } catch (e) {
      locationController.text = 'Localização indisponível';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova Reunião'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Horário (HH:mm)'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Localização'),
              readOnly: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final now = DateTime.now();
              final parts = timeController.text.split(':');
              final hour = int.tryParse(parts[0]) ?? 0;
              final minute = int.tryParse(parts[1]) ?? 0;
              final dateTime =
              DateTime(now.year, now.month, now.day, hour, minute);

              final newMeeting = Meeting(
                id: "0",
                title: titleController.text,
                dateTime: dateTime,
                location: locationController.text,
                groupId: widget.group.id,
              );

              context.read<MeetingBloc>().add(AddMeeting(newMeeting));
              Navigator.pop(context);
            },
            child: const Text('Criar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matéria: ${group.subject}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            if (inviteCode != null)
              Text('Código de convite: $inviteCode',
                  style: const TextStyle(fontSize: 16, color: Colors.blue)),
            const SizedBox(height: 12),
            const Text('Membros:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...group.members.map((m) => Text('- $m')),
            const SizedBox(height: 24),
            const Text('Reuniões:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: BlocBuilder<MeetingBloc, MeetingState>(
                builder: (context, state) {
                  if (state is MeetingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MeetingLoaded) {
                    final groupMeetings = state.meetings
                        .where((m) => m.groupId == group.id)
                        .toList();
                    if (groupMeetings.isEmpty) {
                      return const Text('Nenhuma reunião marcada.');
                    }
                    return ListView.builder(
                      itemCount: groupMeetings.length,
                      itemBuilder: (_, index) {
                        final m = groupMeetings[index];
                        return ListTile(
                          title: Text(m.title),
                          subtitle: Text(
                            '${DateFormat('dd/MM/yyyy – HH:mm').format(m.dateTime)}\n${m.location}',
                          ),
                        );
                      },
                    );
                  } else {
                    return const Text('Erro ao carregar reuniões.');
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => _marcarReuniao(context),
                child: const Text('Marcar reunião'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
