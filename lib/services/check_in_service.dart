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
      // 1. Buscar a reunião para verificar end_time
      final response = await supabase
          .from('meetings')
          .select('end_time')
          .eq('id', meetingId)
          .single();

      final String? endTimeStr = response['end_time'];
      if (endTimeStr == null) {
        throw Exception('Reunião sem horário de término definido.');
      }

      final DateTime endTime = DateTime.parse(endTimeStr);
      final DateTime now = DateTime.now();

      if (now.isAfter(endTime)) {
        print('Tentativa de check-in após o fim da reunião.');
        throw Exception('O check-in não é mais permitido. A reunião já terminou.');
      }

      // 2. Upsert na tabela attendance
      await supabase.from('attendance').upsert(
        {
          'meeting_id': meetingId,
          'user_id': userId,
          'attended': attended,
          'checkin_at': now.toIso8601String(),
        },
        onConflict: 'meeting_id,user_id',
      );

      print('Check-in registrado com sucesso.');
      return true;
    } catch (e) {
      print('Erro ao registrar check-in: $e');
      rethrow;
    }
  }
}
