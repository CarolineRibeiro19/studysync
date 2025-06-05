import 'package:hive/hive.dart';

part 'meeting.g.dart';

@HiveType(typeId: 1)
class Meeting extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String location;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  String groupId;

  @HiveField(4)
  bool attended;

  Meeting({
    required this.title,
    required this.location,
    required this.dateTime,
    required this.groupId,
    this.attended = false,
  });
}
