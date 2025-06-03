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
  List<Uuid> members = [];

  @HiveField(3)
  Uuid createdBy;

  @HiveField(4)
  DateTime createdAt;

  Group({required this.name, required this.createdBy})
    : id = const Uuid().v4(),
      createdAt = DateTime.now();
}
