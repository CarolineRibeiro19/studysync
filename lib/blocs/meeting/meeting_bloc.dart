import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/meeting_service.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  final MeetingService meetingService;

  MeetingBloc({required this.meetingService}) : super(MeetingInitial()) {
    on<LoadMeetings>(_onLoadMeetings);
    on<AddMeeting>(_onAddMeeting);
    on<LoadGroupMeetings>(_onLoadGroupMeetings);
  }

  Future<void> _onLoadMeetings(
      LoadMeetings event, Emitter<MeetingState> emit) async {
    emit(MeetingLoading());
    try {
      final meetings = await meetingService.fetchTodaysMeetings();
      emit(MeetingLoaded(meetings));
    } catch (e) {
      emit(MeetingError('Falha ao carregar reuniões: $e'));
    }
  }

  Future<void> _onAddMeeting(
      AddMeeting event, Emitter<MeetingState> emit) async {
    emit(MeetingLoading());
    try {
      await meetingService.addMeeting(event.meeting);
      final updatedMeetings = await meetingService.fetchGroupMeetings(event.meeting.groupId);
      emit(MeetingLoaded(updatedMeetings));
    } catch (e) {
      emit(MeetingError('Falha ao adicionar reunião: $e'));
    }
  }

  Future<void> _onLoadGroupMeetings(
      LoadGroupMeetings event, Emitter<MeetingState> emit) async {
    emit(MeetingLoading());
    try {
      final meetings = await meetingService.fetchGroupMeetings(event.groupId);
      emit(MeetingLoaded(meetings));
    } catch (e) {
      emit(MeetingError('Falha ao carregar reuniões do grupo: $e'));
    }
  }
}