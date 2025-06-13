import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../blocs/meeting/meeting_event.dart';
import '../../blocs/meeting/meeting_bloc.dart';
import '../../blocs/meeting/meeting_state.dart';
import '../../models/group.dart';
import '../../models/meeting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'meeting_map_picker.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String? locationDescription;
  LatLng? selectedPosition;

  String? inviteCode;

  @override
  void initState() {
    super.initState();

    context.read<MeetingBloc>().add(LoadGroupMeetings(widget.group.id));
    _loadInviteCode();
  }

  Future<void> _loadInviteCode() async {
    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar código de convite: $e')),
        );
      }
    }
  }

  void _copyInviteCode() {
    if (inviteCode != null) {
      Clipboard.setData(ClipboardData(text: inviteCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de convite copiado!')),
      );
    }
  }

  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.subLocality ?? place.locality ?? place.administrativeArea ?? ''} - ${place.administrativeArea ?? ''}';
      }
      return 'Localização desconhecida';
    } catch (e) {
      print('Error in _getAddressFromLatLng: $e');
      return 'Localização não disponível';
    }
  }

  Future<void> _marcarReuniao(BuildContext context) async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController();
    LatLng? initialMapLocation;

    // Obter localização inicial (opcional)
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        initialMapLocation = LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      initialMapLocation = null;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Nova Reunião',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título da Reunião',
                    hintText: 'Ex: Estudo para a prova',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 15),

                GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Data da Reunião',
                        hintText: selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                            : 'Selecione a data',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                GestureDetector(
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedStartTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedStartTime = pickedTime;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Horário de Início',
                        hintText: selectedStartTime != null
                            ? selectedStartTime!.format(context)
                            : 'Selecione o horário de início',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                GestureDetector(
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedEndTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedEndTime = pickedTime;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Horário de Fim',
                        hintText: selectedEndTime != null
                            ? selectedEndTime!.format(context)
                            : 'Selecione o horário de fim',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Localização (Descrição)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final LatLng? pickedLatLng = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              MeetingMapPicker(initialLocation: initialMapLocation),
                        ),
                      );
                      if (pickedLatLng != null) {
                        final address = await _getAddressFromLatLng(
                          pickedLatLng.latitude,
                          pickedLatLng.longitude,
                        );
                        setState(() {
                          selectedPosition = pickedLatLng;
                          locationController.text = address;
                        });
                      }
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Selecionar no Mapa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
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
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    selectedDate == null ||
                    selectedStartTime == null ||
                    selectedEndTime == null ||
                    locationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Por favor, preencha todos os campos obrigatórios.')),
                  );
                  return;
                }

                final startDateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedStartTime!.hour,
                  selectedStartTime!.minute,
                );

                final endDateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedEndTime!.hour,
                  selectedEndTime!.minute,
                );

                if (startDateTime.isAfter(endDateTime) || startDateTime.isAtSameMomentAs(endDateTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'O horário de início deve ser antes do horário de fim.')),
                  );
                  return;
                }

                final newMeeting = Meeting(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  dateTime: startDateTime,
                  endTime: endDateTime,
                  location: locationController.text.trim(),
                  groupId: widget.group.id,
                  lat: selectedPosition?.latitude,
                  long: selectedPosition?.longitude,
                );

                context.read<MeetingBloc>().add(AddMeeting(newMeeting));
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reunião criada com sucesso!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Criar'),
            ),
          ],
        ),
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
        title:
        Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            tooltip: 'Atualizar Reuniões',
            onPressed: () =>
                context.read<MeetingBloc>().add(LoadGroupMeetings(widget.group.id)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.subject,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (inviteCode != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: _copyInviteCode,
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
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              inviteCode!,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold),
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
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: group.members
                          .map((member) => Chip(
                        label: Text(member,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: theme.colorScheme.primary,
                        avatar: const Icon(Icons.person,
                            color: Colors.white, size: 18),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Próximas Reuniões:',
              style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 15),
            Container(
              constraints: const BoxConstraints(minHeight: 150),
              child: BlocBuilder<MeetingBloc, MeetingState>(
                builder: (context, state) {
                  if (state is MeetingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MeetingLoaded) {
                    final groupMeetings = state.meetings
                        .where((m) => m.groupId == group.id)
                        .toList()
                      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

                    if (groupMeetings.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text(
                              'Nenhuma reunião agendada ainda.',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Toque no botão abaixo para criar uma!',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: groupMeetings.length,
                      itemBuilder: (_, index) {
                        final m = groupMeetings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.tertiary,
                              child: const Icon(Icons.event, color: Colors.white),
                            ),
                            title: Text(
                              m.title,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${DateFormat('dd/MM/yyyy – HH:mm').format(m.dateTime)} até ${DateFormat('HH:mm').format(m.endTime)}\n'
                                  '${m.location}'
                                  '${(m.lat != null && m.long != null) ? '\nLat: ${m.lat!.toStringAsFixed(4)}, Long: ${m.long!.toStringAsFixed(4)}' : ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                            onTap: () {
                              // TODO: Implement meeting detail screen navigation.
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Detalhes da reunião: ${m.title}')),
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
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.redAccent),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _marcarReuniao(context),
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text('Agendar Nova Reunião'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedStartTime = picked;
      });
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedEndTime = picked;
      });
    }
  }
}
