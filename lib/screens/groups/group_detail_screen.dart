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
import 'package:flutter/services.dart'; // Import for Clipboard

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  String? inviteCode; // Stores the group's invite code.

  @override
  void initState() {
    super.initState();
    // Load meetings for the current group using the MeetingBloc.
    context.read<MeetingBloc>().add(LoadGroupMeetings(widget.group.id));
    _loadInviteCode(); // Load the invite code for the group.
  }

  // Fetches the invite code for the current group from Supabase.
  Future<void> _loadInviteCode() async {
    try {
      final response = await Supabase.instance.client
          .from('group_invites')
          .select('code')
          .eq('group_id', widget.group.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          inviteCode = response['code']; // Update the invite code.
        });
      }
    } catch (e) {
      // Handle potential errors during invite code loading.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar código de convite: $e')),
        );
      }
    }
  }

  // Copies the invite code to the clipboard and shows a confirmation.
  void _copyInviteCode() {
    if (inviteCode != null) {
      Clipboard.setData(ClipboardData(text: inviteCode!)); // Copy to clipboard.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de convite copiado!')), // Confirmation message.
      );
    }
  }

  // Shows a dialog to schedule a new meeting.
  Future<void> _marcarReuniao(BuildContext context) async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController(); // New controller for time input
    TimeOfDay? selectedTime; // To store the selected time.

    // Try to get current location automatically.
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permissão de localização negada.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Permissão de localização permanentemente negada. Habilite nas configurações do app.';
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      final place = placemarks.first;
      locationController.text =
          '${place.street}, ${place.subLocality}, ${place.locality} - ${place.administrativeArea}';
    } catch (e) {
      locationController.text = 'Localização indisponível';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao obter localização: $e')),
        );
      }
    }

    // Show the dialog for new meeting.
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Nova Reunião', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Título da Reunião',
                  hintText: 'Ex: Estudo para a prova',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  // Show time picker when tapping on the time field.
                  final pickedTime = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() { // setState on the parent widget to trigger rebuild of this dialog part
                      selectedTime = pickedTime; // Update selected time.
                      timeController.text = selectedTime!.format(context); // Update the text field
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: timeController, // Use the new timeController
                    decoration: InputDecoration(
                      labelText: 'Horário',
                      hintText: 'Selecione o horário',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Localização',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                readOnly: false, // Allow manual editing if auto-detection fails.
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty || selectedTime == null || locationController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, preencha todos os campos e selecione um horário.')),
                );
                return;
              }

              Navigator.pop(dialogContext); // Close dialog.

              final now = DateTime.now();
              final dateTime = DateTime(
                  now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute);

              final newMeeting = Meeting(
                id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID.
                title: titleController.text.trim(),
                dateTime: dateTime,
                location: locationController.text.trim(),
                groupId: widget.group.id,
              );

              context.read<MeetingBloc>().add(AddMeeting(newMeeting)); // Dispatch add meeting event.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reunião agendada com sucesso!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor.withOpacity(0.05),
      appBar: AppBar(
        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Refresh button to reload meetings
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            tooltip: 'Atualizar Reuniões',
            onPressed: () => context.read<MeetingBloc>().add(LoadGroupMeetings(widget.group.id)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Subject Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matéria:',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.subject,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Invite Code Card (conditionally displayed)
            if (inviteCode != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: _copyInviteCode, // Tap to copy invite code.
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Código de Convite:',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              inviteCode!,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Icon(Icons.copy, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            if (inviteCode != null) const SizedBox(height: 20),

            // Members List Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membros (${group.members.length}):',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Display members in a wrapped flow layout for better readability.
                    Wrap(
                      spacing: 8.0, // horizontal space between items
                      runSpacing: 8.0, // vertical space between lines
                      children: group.members.map((member) => Chip(
                            label: Text(member, style: const TextStyle(color: Colors.white)),
                            backgroundColor: theme.colorScheme.primary,
                            avatar: const Icon(Icons.person, color: Colors.white, size: 18),
                          )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Meetings Section
            Text(
              'Próximas Reuniões:',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 15),
            Container(
              constraints: const BoxConstraints(minHeight: 150), // Minimum height for the meeting list.
              child: BlocBuilder<MeetingBloc, MeetingState>(
                builder: (context, state) {
                  if (state is MeetingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MeetingLoaded) {
                    final groupMeetings = state.meetings
                        .where((m) => m.groupId == group.id)
                        .toList()
                        ..sort((a, b) => a.dateTime.compareTo(b.dateTime)); // Sort meetings by date/time.

                    if (groupMeetings.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text(
                              'Nenhuma reunião agendada ainda.',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Toque no botão abaixo para criar uma!',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true, // Use shrinkWrap to prevent unbounded height errors inside SingleChildScrollView.
                      physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling.
                      itemCount: groupMeetings.length,
                      itemBuilder: (_, index) {
                        final m = groupMeetings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.tertiary,
                              child: Icon(Icons.event, color: Colors.white),
                            ),
                            title: Text(
                              m.title,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${DateFormat('dd/MM/yyyy – HH:mm').format(m.dateTime)}\n${m.location}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                            ),
                            isThreeLine: true, // Allow subtitle to take more than one line.
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                            onTap: () {
                              // TODO: Implement meeting detail screen navigation.
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Detalhes da reunião: ${m.title}')),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        'Erro ao carregar reuniões.',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.redAccent),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30),

            // "Marcar Reunião" Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _marcarReuniao(context),
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text('Agendar Nova Reunião'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
