import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting.dart';

class MeetingService {
  final SupabaseClient supabase;
  MeetingService(this.supabase);

  Future<List<Meeting>> fetchTodaysMeetings(String userId) async {
    try {
      // Busca os IDs dos grupos que o usuário participa
      final groupResponse = await supabase
          .from('group_members')
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = groupResponse.map((g) => g['group_id'] as String).toList();

      if (groupIds.isEmpty) {
        print('Usuário não está em nenhum grupo.');
        return [];
      }

      // Define o intervalo de hoje
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay =
      startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

      // Busca reuniões de hoje dos grupos que o usuário participa
      final response = await supabase
          .from('meetings')
          .select('*')
          .inFilter('group_id', groupIds)
          .gte('date_time', startOfDay.toIso8601String())
          .lte('date_time', endOfDay.toIso8601String())
          .order('date_time', ascending: true);

      // Certifique-se de que o retorno seja assim:
      return (response as List<dynamic>).map((json) => Meeting.fromMap(json)).toList();
    } catch (e) {
      print('Erro ao buscar reuniões do dia: $e');
      return [];
    }
  }


  Future<List<Meeting>> fetchGroupMeetings(String groupId) async {
    try {
      final List<dynamic> response = await supabase
          .from('meetings')
          .select('*')
          .eq('group_id', groupId)
          .order('date_time', ascending: true);

      // Certifique-se de que o retorno seja assim:
      return (response as List<dynamic>).map((json) => Meeting.fromMap(json)).toList();
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
        'end_time': meeting.endTime.toIso8601String(), // Adicionado
        'group_id': meeting.groupId,
        'location': meeting.location,
        'lat': meeting.lat, // Adicionado
        'long': meeting.long, // Adicionado
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