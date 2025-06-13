import 'package:supabase_flutter/supabase_flutter.dart';

class CheckInService {
  final SupabaseClient supabase;

  CheckInService(this.supabase);

  Future<bool> updateMeetingAttendance({
    required String meetingId,
    required bool attended,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('CheckInService: User not authenticated. Cannot update attendance.');
      throw Exception('Usuário não autenticado para realizar o check-in.');
    }

    try {
      await supabase.from('attendance').upsert(
        {
          'meeting_id': meetingId,
          'user_id': userId,
          'attended': true,
          'checkin_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'meeting_id,user_id',
      );
      print('Attendance updated successfully for meeting $meetingId by user $userId');
      return true;
    } catch (e) {
      print('Error updating attendance for meeting $meetingId: $e');
      rethrow;
    }
  }
}
