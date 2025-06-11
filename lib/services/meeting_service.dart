import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting.dart';

class MeetingService {
  final SupabaseClient supabase;

  MeetingService(this.supabase);

  Future<List<Meeting>> fetchTodaysMeetings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

    final response = await supabase
        .from('meetings')
        .select()
        .gte('date_time', startOfDay.toIso8601String())
        .lte('date_time', endOfDay.toIso8601String());

    return (response as List).map((e) => Meeting.fromMap(e)).toList();
  }

  Future<List<Meeting>> fetchGroupMeetings(String groupId) async {
    final response = await supabase
        .from('meetings')
        .select()
        .eq('group_id', groupId)
        .order('date_time', ascending: true);

    return (response as List).map((e) => Meeting.fromMap(e)).toList();
  }

  Future<void> addMeeting(Meeting meeting) async {
    await supabase.from('meetings').insert({
      'title': meeting.title,
      'date_time': meeting.dateTime.toIso8601String(),
      'group_id': meeting.groupId,
      'attended': meeting.attended,
      'location': meeting.location,
    });
  }

  Future<void> updateAttendance(String meetingId, bool attended) async {
    await supabase
        .from('meetings')
        .update({'attended': attended})
        .eq('id', meetingId);
  }
}
