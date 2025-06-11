import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';

class GroupService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Busca todos os grupos do usuário atual
  Future<List<Group>> fetchUserGroups() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('group_members')
        .select('groups(id, name, subject), profiles(name)')
        .eq('user_id', userId);

    return (response as List)
        .map((e) => Group(
      id: e['groups']['id'],
      name: e['groups']['name'],
      subject: e['groups']['subject'],
      members: [e['profiles']['name'] ?? 'Sem nome'],
    ))
        .toList();
  }


  /// Cria um novo grupo e adiciona o usuário como membro
  Future<bool> createGroup({required String name, required String subject}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final insertResponse = await supabase
        .from('groups')
        .insert({
      'name': name,
      'subject': subject,
      'created_by': userId,
    })
        .select()
        .single();

    final groupId = insertResponse['id'] as String;

    await supabase.from('group_members').insert({
      'user_id': userId,
      'group_id': groupId,
    });

    return true;
  }

  /// Entrar em grupo existente
  Future<bool> joinGroupById(String groupIdText) async {
    final userId = supabase.auth.currentUser?.id;
    final groupId = groupIdText;
    if (userId == null || groupId == null) return false;

    final existing = await supabase
        .from('group_members')
        .select()
        .eq('user_id', userId)
        .eq('group_id', groupId)
        .maybeSingle();

    if (existing != null) return false;

    await supabase.from('group_members').insert({
      'user_id': userId,
      'group_id': groupId,
    });

    return true;
  }
}
