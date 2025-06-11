import 'package:equatable/equatable.dart';
import '../../models/meeting.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeetings extends MeetingEvent {}

class AddMeeting extends MeetingEvent {
  final Meeting meeting;

  const AddMeeting(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

class LoadGroupMeetings extends MeetingEvent {
  final String groupId;

  const LoadGroupMeetings(this.groupId);

  @override
  List<Object?> get props => [groupId];
}
