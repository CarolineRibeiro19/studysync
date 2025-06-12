import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../blocs/meeting/meeting_bloc.dart';
import '../../blocs/meeting/meeting_event.dart';
import '../../blocs/meeting/meeting_state.dart';
import '../../blocs/checkin/check_in_bloc.dart';
import '../../blocs/checkin/check_in_event.dart';
import '../../blocs/checkin/check_in_state.dart';
import '../../models/meeting.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  Meeting? _selectedMeeting;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<MeetingBloc>().add(LoadMeetings(userId));
    }
    context.read<CheckInBloc>().add(ResetCheckIn());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in de Reunião',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MeetingBloc, MeetingState>(
            listener: (context, state) {
              if (state is MeetingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao carregar reuniões: ${state.message}')),
                );
              }
            },
          ),
          BlocListener<CheckInBloc, CheckInState>(
            listener: (context, state) {
              if (state is CheckInSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is CheckInFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecione a Reunião:',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                BlocBuilder<MeetingBloc, MeetingState>(
                  builder: (context, state) {
                    if (state is MeetingLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MeetingLoaded) {
                      final relevantMeetings = state.meetings
                          .where((m) => m.dateTime.isAfter(DateTime.now().subtract(const Duration(hours: 2))))
                          .toList();

                      if (relevantMeetings.isEmpty) {
                        return const Center(
                          child: Text('Nenhuma reunião recente ou futura disponível para check-in.'),
                        );
                      }

                      return DropdownButtonFormField<Meeting>(
                        decoration: InputDecoration(
                          labelText: 'Reunião',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.event_note),
                        ),
                        value: _selectedMeeting,
                        onChanged: (Meeting? newValue) {
                          setState(() {
                            _selectedMeeting = newValue;
                            context.read<CheckInBloc>().add(ResetCheckIn());
                          });
                        },
                        items: relevantMeetings.map((Meeting meeting) {
                          return DropdownMenuItem<Meeting>(
                            value: meeting,
                            child: Text(
                              '${meeting.title} - ${DateFormat('dd/MM HH:mm').format(meeting.dateTime)} - ${meeting.location}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      );
                    } else if (state is MeetingError) {
                      return Center(child: Text('Erro ao carregar reuniões: ${state.message}'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 30),
                BlocBuilder<CheckInBloc, CheckInState>(
                  builder: (context, checkInState) {
                    String statusMessage = 'Selecione uma reunião para começar.';
                    Icon statusIcon = const Icon(Icons.info_outline, size: 40, color: Colors.blueGrey);
                    bool enableActionButton = false;
                    Color actionButtonColor = theme.primaryColor;
                    String actionButtonText = 'Iniciar Check-in';

                    if (_selectedMeeting == null) {
                      statusMessage = 'Selecione uma reunião na lista acima.';
                      enableActionButton = false;
                    } else if (_selectedMeeting!.lat == null || _selectedMeeting!.long == null) {
                      statusMessage = 'A reunião selecionada não possui coordenadas de localização.';
                      statusIcon = const Icon(Icons.warning_amber, size: 40, color: Colors.orange);
                      enableActionButton = false;
                    } else if (checkInState is CheckInInitial) {
                      statusMessage = 'Pressione "Iniciar Check-in" para começar.';
                      statusIcon = const Icon(Icons.touch_app, size: 40, color: Colors.grey);
                      enableActionButton = true;
                    } else if (checkInState is CheckInLoading) {
                      statusMessage = checkInState.message;
                      statusIcon = const Icon(Icons.cached, size: 40, color: Colors.amber);
                      enableActionButton = false;
                      actionButtonText = 'Carregando...';
                    } else if (checkInState is CheckInReadyForShake) {
                      statusMessage = checkInState.message;
                      statusIcon = const Icon(Icons.screen_rotation_alt, size: 40, color: Colors.lightGreen);
                      enableActionButton = false;
                      actionButtonText = 'Aguardando movimento...';
                      actionButtonColor = Colors.lightGreen;
                    } else if (checkInState is CheckInProcessing) {
                      statusMessage = checkInState.message;
                      statusIcon = const Icon(Icons.hourglass_empty, size: 40, color: Colors.deepOrange);
                      enableActionButton = false;
                      actionButtonText = 'Processando...';
                      actionButtonColor = Colors.deepOrange;
                    } else if (checkInState is CheckInSuccess) {
                      statusMessage = checkInState.message;
                      statusIcon = const Icon(Icons.task_alt, size: 40, color: Colors.green);
                      enableActionButton = false;
                      actionButtonText = 'Check-in Realizado!';
                      actionButtonColor = Colors.green;
                    } else if (checkInState is CheckInFailure) {
                      statusMessage = checkInState.message;
                      statusIcon = const Icon(Icons.error_outline, size: 40, color: Colors.red);
                      enableActionButton = true;
                      actionButtonText = 'Tentar Novamente';
                      actionButtonColor = Colors.red;
                    }

                    return Column(
                      children: [
                        Center(child: statusIcon),
                        const SizedBox(height: 10),
                        Text(
                          statusMessage,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: enableActionButton
                                ? () {
                              if (_selectedMeeting != null) {
                                context.read<CheckInBloc>().add(StartCheckIn(_selectedMeeting!));
                              }
                            }
                                : null,
                            icon: (checkInState is CheckInLoading || checkInState is CheckInProcessing)
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.check_circle_outline, size: 28),
                            label: Text(actionButtonText),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: actionButtonColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (checkInState is! CheckInInitial &&
                            checkInState is! CheckInLoading &&
                            checkInState is! CheckInReadyForShake &&
                            checkInState is! CheckInProcessing)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.read<CheckInBloc>().add(ResetCheckIn());
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text(
                                'Reiniciar Processo',
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.primaryColor,
                                side: BorderSide(color: theme.primaryColor),
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
