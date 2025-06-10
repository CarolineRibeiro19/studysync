import '../../models/meeting.dart';

abstract class MeetingEvent {}

class LoadMeetings extends MeetingEvent {}

class AddMeeting extends MeetingEvent {
  final Meeting meeting;

  AddMeeting(this.meeting);
}

class MarkAttendance extends MeetingEvent {
  final int meetingId;

  MarkAttendance(this.meetingId);
}
