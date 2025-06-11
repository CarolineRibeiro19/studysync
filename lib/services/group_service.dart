import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';

class GroupService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Busca todos os grupos do usuário atual
  Future<List<Group>> fetchUserGroups() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // 1. Buscar os grupos do usuário
    final memberResponse = await supabase
        .from('group_members')
        .select('group_id, groups(id, name, subject)')
        .eq('user_id', userId);

    // 2. Para cada grupo, buscar os membros
    List<Group> result = [];

    for (var entry in memberResponse as List) {
      final groupData = entry['groups'];
      final groupId = groupData['id'];

      // Buscar os membros desse grupo
      final membersRes = await supabase
          .from('group_members')
          .select('profiles(name)')
          .eq('group_id', groupId);

      final members = (membersRes as List)
          .map((e) => e['profiles']?['name'] ?? 'Sem nome')
          .cast<String>()
          .toList();

      result.add(Group(
        id: groupId,
        name: groupData['name'],
        subject: groupData['subject'],
        members: members,
      ));
    }

    return result;
  }

  /// Gera código aleatório de convite
  String _generateCode(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Cria um novo grupo e gera um código de convite
  Future<bool> createGroup({
    required String name,
    required String subject,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final insertResponse = await supabase
        .from('groups')
        .insert({'name': name, 'subject': subject, 'created_by': userId})
        .select()
        .single();

    final groupId = insertResponse['id'];

    final user = await supabase
      .from('profiles')
      .select('group_id')
      .eq('id', userId)
      .single();

    final List<dynamic> currentGroupIds = user['group_id'] ?? [];
    final updatedGroupIds = {...currentGroupIds, groupId}.toList(); // ensures uniqueness

    await supabase
        .from('profiles')
        .update({'group_id': updatedGroupIds})
        .eq('id', userId);

    // Adiciona criador como membro
    await supabase.from('group_members').insert({
      'user_id': userId,
      'group_id': groupId,
    });

    // Cria código de convite
    final inviteCode = _generateCode(6);

    await supabase.from('group_invites').insert({
      'group_id': groupId,
      'code': inviteCode,
    });

    return true;
  }

  /// Entra em grupo usando ID diretamente (não recomendado se for usar código)
  Future<bool> joinGroupById(String groupId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || groupId.isEmpty) return false;

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

  /// Entra em grupo usando código de convite
  Future<bool> joinGroupByInviteCode(String code) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || code.isEmpty) return false;

    final invite = await supabase
        .from('group_invites')
        .select('group_id')
        .eq('code', code)
        .maybeSingle();

    if (invite == null) return false;

    final groupId = invite['group_id'];

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
  /// Busca o código de convite de um grupo
  Future<String?> fetchInviteCode(String groupId) async {
    final response = await supabase
        .from('group_invites')
        .select('code')
        .eq('group_id', groupId)
        .maybeSingle();

    return response != null ? response['code'] as String : null;
  }
  Future<Group?> fetchGroupById(String groupId) async {
    final groupRes = await supabase
        .from('groups')
        .select()
        .eq('id', groupId)
        .maybeSingle();

    if (groupRes == null) return null;

    final membersRes = await supabase
        .from('group_members')
        .select('profiles(name)')
        .eq('group_id', groupId);

    final members = (membersRes as List)
        .map((e) => e['profiles']['name'] ?? 'Sem nome')
        .cast<String>()
        .toList();

    return Group(
      id: groupRes['id'],
      name: groupRes['name'],
      subject: groupRes['subject'],
      members: members,
    );
  }


}
