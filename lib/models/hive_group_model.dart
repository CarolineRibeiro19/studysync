import 'package:hive/hive.dart';

part 'hive_group_model.g.dart';

@HiveType(typeId: 0)
class HiveGroup extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String subject;

  @HiveField(3)
  final String inviteCode;

  @HiveField(4)
  final bool isSynced; // Indica se o grupo foi sincronizado com o Supabase

  HiveGroup({
    required this.id,
    required this.name,
    required this.subject,
    required this.inviteCode,
    this.isSynced = true, // Por padrão, assume que o grupo está sincronizado
  });

  HiveGroup copyWith({
    String? id,
    String? name,
    String? subject,
    String? inviteCode,
    bool? isSynced,
  }) {
    return HiveGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      inviteCode: inviteCode ?? this.inviteCode,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}