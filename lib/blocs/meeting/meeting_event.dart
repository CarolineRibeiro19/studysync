import '../../models/meeting.dart';
import 'package:equatable/equatable.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupMeetings extends MeetingEvent {
  final String groupId;

  const LoadGroupMeetings(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class AddMeeting extends MeetingEvent {
  final Meeting meeting;

  const AddMeeting(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

class LoadMeetings extends MeetingEvent {}