import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/meeting_service.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  final MeetingService meetingService;

  MeetingBloc({required this.meetingService}) : super(MeetingInitial()) {
    on<LoadMeetings>(_onLoadMeetings);
    on<AddMeeting>(_onAddMeeting);
    on<MarkAttendance>(_onMarkAttendance);
  }

  Future<void> _onLoadMeetings(
    LoadMeetings event,
    Emitter<MeetingState> emit,
  ) async {
    emit(MeetingLoading());
    try {
      final meetings = await meetingService.fetchMeetings(event.groupIds);
      emit(MeetingLoaded(meetings));
    } catch (e) {
      emit(MeetingError('Erro ao carregar reuniões: $e'));
    }
  }

  Future<void> _onAddMeeting(
    AddMeeting event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      await meetingService.addMeeting(event.meeting);

      // Fetch again using groupId from added meeting
      final meetings = await meetingService.fetchMeetings([event.meeting.groupId]);
      emit(MeetingLoaded(meetings));
    } catch (e) {
      emit(MeetingError('Erro ao adicionar reunião: $e'));
    }
  }

  Future<void> _onMarkAttendance(
    MarkAttendance event,
    Emitter<MeetingState> emit,
  ) async {
    if (state is! MeetingLoaded) return;

    try {
      await meetingService.updateAttendance(event.meetingId, true);

      // Get groupIds from current loaded meetings
      final currentState = state as MeetingLoaded;
      final groupIds = currentState.meetings.map((m) => m.groupId).toSet().toList();
      final meetings = await meetingService.fetchMeetings(groupIds);

      emit(MeetingLoaded(meetings));
    } catch (e) {
      emit(MeetingError('Erro ao marcar presença: $e'));
    }
  }
}
