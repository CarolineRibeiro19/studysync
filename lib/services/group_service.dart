import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';

class GroupService {
  final SupabaseClient supabase;

  GroupService(this.supabase);

  Future<List<Group>> fetchGroups() async {
    final response = await supabase.from('groups').select();
    return (response as List).map((json) => Group.fromJson(json)).toList();
  }

  Future<void> createGroup(String name, int createdBy) async {
    await supabase.from('groups').insert({
      'name': name,
      'created_by': createdBy,
      'members': [createdBy],
    });
  }

  Future<void> joinGroup(int groupId, int userId) async {
    final groupData = await supabase
        .from('groups')
        .select()
        .eq('id', groupId)
        .single();

    final currentMembers = List<int>.from(groupData['members']);
    if (!currentMembers.contains(userId)) {
      currentMembers.add(userId);

      await supabase
          .from('groups')
          .update({'members': currentMembers})
          .eq('id', groupId);
    }

    await supabase
        .from('profiles')
        .update({'group_id': groupId})
        .eq('id', userId);
  }
}
