import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/user.dart' as app_model;

class UserService {
  final supa.SupabaseClient supabase;

  UserService(this.supabase);

  Future<app_model.User?> getCurrentUserProfile() async {
    final supaUser = supabase.auth.currentUser;
    if (supaUser == null) return null;

    final response =
        await supabase.from('profiles').select().eq('id', supaUser.id).single();

    return app_model.User(
      id: response['id'],
      email: supaUser.email ?? '',
      name: response['name'] ?? '',
      groupId: response['group_id'],
      points: response['points'] ?? 0,
    );
  }

  Future<void> updateUserProfile({
    required String id,
    required String name,
    required int? groupId,
  }) async {
    await supabase
        .from('profiles')
        .update({'name': name, 'group_id': groupId})
        .eq('id', id);
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return false;
    }
  }

  Future<bool> registerUser(String name, String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return false;

      await supabase.from('profiles').insert({
        'id': user.id,
        'name': name,
        'email': email,
        'points': 0,
        'group_id': null,
      });

      return true;
    } catch (e) {
      print('Erro ao registrar: $e');
      return false;
    }
  }

  Future<void> signOutUser() async {
    await supabase.auth.signOut();
  }
}
