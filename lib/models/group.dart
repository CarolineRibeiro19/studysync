import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'group.g.dart';

@HiveType(typeId: 0)
class Group extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String subject;

  @HiveField(3)
  int memberCount;

  @HiveField(5)
  List<String> members;

  @HiveField(6)
  String createdBy; // novo campo

  Group({
    required this.name,
    required this.subject,
    required this.memberCount,
    required this.createdBy,
    List<String>? members,
  })  : id = const Uuid().v4(),
        members = members ?? [];
}
