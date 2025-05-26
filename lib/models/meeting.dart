import 'package:hive/hive.dart';

part 'meeting.g.dart';

@HiveType(typeId: 1)
class Meeting extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime dateTime;

  @HiveField(2)
  String location;

  Meeting({
    required this.title,
    required this.dateTime,
    required this.location,
  });
}
