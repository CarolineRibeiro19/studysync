import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/user.dart' as app_model;

class UserService {
  final supa.SupabaseClient supabase;

  UserService(this.supabase);

  Future<app_model.User?> getCurrentUserProfile() async {
    final supaUser = supabase.auth.currentUser;
    if (supaUser == null) return null;

    try {
      final response =
          await supabase.from('profiles').select().eq('id', supaUser.id).single();

      return app_model.User.fromJson(response); 
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  Future<app_model.User?> updateUserProfile({
    required String id,
    String? name,
    List<dynamic>? groupId, 
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) {
      updates['name'] = name;
    }
    if (groupId != null) {
      updates['group_id'] = groupId;
    }

    if (updates.isEmpty) {
      return getCurrentUserProfile(); 
    }

    try {
      final response = await supabase
          .from('profiles')
          .update(updates)
          .eq('id', id)
          .select() 
          .single();

      return app_model.User.fromJson(response);
    } catch (e) {
      print('Error updating user profile: $e');
      return getCurrentUserProfile(); 
    }
  }

  
  Future<app_model.User?> updateUserGroupPoints({
    required String userId,
    required String groupId,
    required int pointsToAdd,
  }) async {
    try {
      
      final currentUserData = await supabase.from('profiles').select('points, group_points').eq('id', userId).single();

      final currentGroupPoints = (currentUserData['group_points'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ) ?? {};
      final currentTotalPoints = currentUserData['points'] as int? ?? 0;

      
      final Map<String, int> updatedGroupPoints = Map.from(currentGroupPoints); 
      updatedGroupPoints[groupId] = (updatedGroupPoints[groupId] ?? 0) + pointsToAdd;

      
      
      final newTotalPoints = updatedGroupPoints.values.fold(currentTotalPoints, (sum, element) => sum + element);


      
      final response = await supabase
          .from('profiles')
          .update({
            'points': newTotalPoints,
            'group_points': updatedGroupPoints, 
          })
          .eq('id', userId)
          .select() 
          .single();

      return app_model.User.fromJson(response);
    } catch (e) {
      print('Error updating user group points: $e');
      return null;
    }
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

      if (user == null) {
        if (response.session == null) {
            print('Sign-up failed, no session created.');
        }
        return false;
      }
      final userId = user.id;
      print('New user registered with ID: $userId');

      await supabase.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'group_id': [], 
        'points': 0, 
        'group_points': {}, 
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