import 'package:hive/hive.dart';

part 'meeting.g.dart';

@HiveType(typeId: 1)
class Meeting extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  bool attended;

  Meeting({
    required this.title,
    required this.date,
    this.attended = false,
  });
}