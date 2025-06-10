import '../../models/meeting.dart';

abstract class MeetingState {}

class MeetingInitial extends MeetingState {}

class MeetingLoading extends MeetingState {}

class MeetingLoaded extends MeetingState {
  final List<Meeting> meetings;

  MeetingLoaded(this.meetings);
}

class MeetingError extends MeetingState {
  final String message;

  MeetingError(this.message);
}
