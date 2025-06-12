// lib/models/meeting_attendance.dart (Proposed new file for clarity)
import 'package:equatable/equatable.dart';

class MeetingAttendance extends Equatable {
  final String meetingId;
  final String userId;
  final bool attended; 
  final DateTime checkedInAt; 

  const MeetingAttendance({
    required this.meetingId,
    required this.userId,
    required this.attended,
    required this.checkedInAt,
  });

  // Factory constructor to create a MeetingAttendance object from a JSON map (e.g., from Supabase)
  factory MeetingAttendance.fromJson(Map<String, dynamic> json) {
    return MeetingAttendance(
      meetingId: json['meeting_id'] as String,
      userId: json['user_id'] as String,
      attended: json['attended'] as bool,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meeting_id': meetingId,
      'user_id': userId,
      'attended': attended,
      'checkin_at': checkedInAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [meetingId, userId, attended, checkedInAt];
}