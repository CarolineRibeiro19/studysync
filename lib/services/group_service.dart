import 'dart:math';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';
import '../models/hive_group_model.dart';

class GroupService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<HiveGroup>> fetchUserGroups() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final memberResponse = await supabase
        .from('group_members')
        .select('group_id, groups(id, name, subject)')
        .eq('user_id', userId);

    List<HiveGroup> result = [];

    for (var entry in memberResponse as List) {
      final groupData = entry['groups'];
      final groupId = groupData['id'];

      // Buscar o código de convite do grupo
      final inviteCode = await fetchInviteCode(groupId);

      // Buscar os membros do grupo
      final membersRes = await supabase
          .from('group_members')
          .select('profiles(name)')
          .eq('group_id', groupId);

      final members = (membersRes as List)
          .map((e) => e['profiles']['name'] ?? 'Sem nome')
          .cast<String>()
          .toList();

      result.add(HiveGroup(
        id: groupId,
        name: groupData['name'],
        subject: groupData['subject'],
        inviteCode: inviteCode ?? 'N/A',
        isSynced: true, // Assume que os grupos carregados do Supabase estão sincronizados
      ));
    }

    // Salvar no Hive
    final groupBox = Hive.box<HiveGroup>('groups');
    groupBox.clear(); // Limpa os grupos antigos
    for (var group in result) {
      groupBox.put(group.id, group);
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchGroupMembers(String groupId) async {
    final membersRes = await supabase
        .from('group_members')
        .select('profiles(name)')
        .eq('group_id', groupId);

    return (membersRes as List).map((e) => e['profiles'] as Map<String, dynamic>).toList();
  }


  String _generateCode(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void debugHiveBox() {
    final groupBox = Hive.box<HiveGroup>('groups');
    print('Grupos na HiveBox:');
    for (var group in groupBox.values) {
      print('ID: ${group.id}, Nome: ${group.name}, Código: ${group.inviteCode}, Sincronizado: ${group.isSynced}');
    }
  }

  Future<bool> createGroup({
    required String name,
    required String subject,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final groupBox = Hive.box<HiveGroup>('groups');

    try {
      // Tenta criar o grupo no Supabase
      final insertResponse = await supabase
          .from('groups')
          .insert({'name': name, 'subject': subject, 'created_by': userId})
          .select()
          .single();

      final groupId = insertResponse['id'];
      final inviteCode = _generateCode(6);

      await supabase.from('group_invites').insert({
        'group_id': groupId,
        'code': inviteCode,
      });

      // Salva no Hive como sincronizado
      groupBox.put(
        groupId,
        HiveGroup(
          id: groupId,
          name: name,
          subject: subject,
          inviteCode: inviteCode,
          isSynced: true,
        ),
      );
      debugHiveBox();
      return true;
    } catch (e) {
      // Se falhar, salva no Hive como não sincronizado
      final tempId = DateTime.now().millisecondsSinceEpoch.toString(); // ID temporário
      groupBox.put(
        tempId,
        HiveGroup(
          id: tempId,
          name: name,
          subject: subject,
          inviteCode: 'N/A', // Código de convite será gerado após sincronização
          isSynced: false,
        ),
      );
      debugHiveBox();
      return true; // Retorna true porque o grupo foi salvo localmente
    }
  }


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

    await supabase.from('group_members').insert({
      'user_id': userId,
      'group_id': groupId,
    });

    // Buscar detalhes do grupo
    final group = await fetchGroupById(groupId);
    if (group != null) {
      // Salvar no Hive
      final groupBox = Hive.box<HiveGroup>('groups');
      groupBox.put(
        group.id,
        HiveGroup(
          id: group.id,
          name: group.name,
          subject: group.subject,
          inviteCode: await fetchInviteCode(group.id) ?? 'N/A',
        ),
      );
    }

    return true;
  }

  Future<void> syncOfflineGroups() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final groupBox = Hive.box<HiveGroup>('groups');
    final offlineGroups = groupBox.values.where((group) => !group.isSynced).toList();

    for (var group in offlineGroups) {
      try {
        // Cria o grupo no Supabase
        final insertResponse = await supabase
            .from('groups')
            .insert({'name': group.name, 'subject': group.subject, 'created_by': userId})
            .select()
            .single();

        final groupId = insertResponse['id'];
        final inviteCode = _generateCode(6);

        await supabase.from('group_invites').insert({
          'group_id': groupId,
          'code': inviteCode,
        });

        // Atualiza o grupo no Hive como sincronizado
        groupBox.put(
          groupId,
          group.copyWith(
            id: groupId,
            inviteCode: inviteCode,
            isSynced: true,
          ),
        );

        // Remove o grupo com ID temporário
        groupBox.delete(group.id);
      } catch (e) {
        // Log de erro (opcional)
        print('Erro ao sincronizar grupo offline: $e');
      }
    }
  }

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
