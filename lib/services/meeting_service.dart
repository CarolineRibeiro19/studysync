import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting.dart';

class MeetingService {
  final SupabaseClient supabase;
  MeetingService(this.supabase);

  Future<List<Meeting>> fetchTodaysMeetings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('User not authenticated. Cannot fetch today\'s meetings.');
      return [];
    }

    List<dynamic>? userGroupIds;
    try {
      final userProfile = await supabase
          .from('profiles')
          .select('group_id')
          .eq('id', userId)
          .single();
      userGroupIds = userProfile['group_id'] as List<dynamic>?;

      if (userGroupIds == null || userGroupIds.isEmpty) {
        print('User $userId is not part of any groups. No meetings to fetch.');
        return [];
      }
    } catch (e) {
      print('Error fetching user groups for meetings: $e');
      return [];
    }

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

    try {
      final List<dynamic> response = await supabase
          .from('meetings')
          .select('*')
          .gte('date_time', startOfDay.toIso8601String())
          .lte('date_time', endOfDay.toIso8601String())
          .contains('group_id', userGroupIds) // Supabase 'in' filter
          .order('date_time', ascending: true);

      return response.map((json) => Meeting.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching today\'s meetings: $e');
      rethrow;
    }
  }

  Future<List<Meeting>> fetchGroupMeetings(String groupId) async {
    try {
      final List<dynamic> response = await supabase
          .from('meetings')
          .select('*')
          .eq('group_id', groupId)
          .order('date_time', ascending: true);

      return response.map((json) => Meeting.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching group meetings: $e');
      rethrow;
    }
  }

  Future<void> addMeeting(Meeting meeting) async {
    try {
      await supabase.from('meetings').insert({
        'title': meeting.title,
        'date_time': meeting.dateTime.toIso8601String(),
        'group_id': meeting.groupId,
        'location': meeting.location,
        'lat': meeting.lat, // Added lat
        'long': meeting.long, // Added long
      });
    } catch (e) {
      print('Error adding meeting: $e');
      rethrow;
    }
  }

  Future<void> updateAttendance(String meetingId, bool attended) async {
    try {
      await supabase
          .from('meetings')
          .update({'attended': attended})
          .eq('id', meetingId);
    } catch (e) {
      print('Error updating attendance: $e');
      rethrow;
    }
  }
}