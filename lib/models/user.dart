import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isLoggedIn;

  @HiveField(6)
  int points;

  User({required this.name, required this.email, required this.password})
      : id = const Uuid().v4(),
        createdAt = DateTime.now(),
        isLoggedIn = false,
        points = 0;
}