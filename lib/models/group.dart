import 'package:hive/hive.dart';

part 'group.g.dart'; // Será gerado automaticamente

@HiveType(typeId: 0)
class Group extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime createdAt;

  Group({
    required this.name,
    required this.createdAt,
  });
}
