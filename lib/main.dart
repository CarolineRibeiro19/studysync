import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/group.dart';
import 'models/meeting.dart';

import 'screens/home_screen.dart';
import 'screens/group_screen.dart';
import 'screens/add_group_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(GroupAdapter());
  Hive.registerAdapter(MeetingAdapter());

  await Hive.openBox<Group>('groups');
  await Hive.openBox<Meeting>('meetings');

  // 👇 Adiciona reunião manualmente (só se ainda não existir)
  final meetingBox = Hive.box<Meeting>('meetings');
  if (meetingBox.isEmpty) {
    meetingBox.add(
      Meeting(
        title: 'Revisão de IA',
        date: DateTime.now().subtract(const Duration(days: 2)),
        attended: false,
      ),
    );
  }
  Hive.box<Meeting>('meetings').add(
    Meeting(
      title: 'Reunião de Projeto',
      date: DateTime.now().add(const Duration(minutes: 10)),
      attended: false,
    ),
  );

  runApp(const StudySyncApp());
}


class StudySyncApp extends StatelessWidget {
  const StudySyncApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySync',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/groups': (context) => const GroupScreen(),
        '/add_group': (context) => const AddGroupScreen(),
        '/checkin': (context) => const CheckInScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
