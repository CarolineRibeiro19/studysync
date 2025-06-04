import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'meeting.g.dart';

@HiveType(typeId: 1)
class Meeting extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  String location;

  @HiveField(4)
  String groupId;

  Meeting({
    required this.title,
    required this.dateTime,
    required this.location,
    required this.groupId,
  }) : id = const Uuid().v4();
}
