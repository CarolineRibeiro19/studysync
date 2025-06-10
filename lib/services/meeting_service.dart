import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting.dart';

class MeetingService {
  final SupabaseClient supabase;

  MeetingService(this.supabase);

  Future<List<Meeting>> fetchMeetings() async {
    final response = await supabase.from('meetings').select();

    return (response as List).map((e) => Meeting.fromMap(e)).toList();
  }

  Future<void> addMeeting(Meeting meeting) async {
    await supabase.from('meetings').insert({
      'title': meeting.title,
      'date_time': meeting.dateTime.toIso8601String(),
      'group_id': meeting.groupId,
      'attended': meeting.attended,
    });
  }

  Future<void> updateAttendance(int meetingId, bool attended) async {
    await supabase
        .from('meetings')
        .update({'attended': attended})
        .eq('id', meetingId);
  }
}
