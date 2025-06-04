import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studysync/blocs/user/user_bloc.dart';
import 'package:studysync/blocs/user/user_event.dart';
import 'package:studysync/models/user.dart';
import 'package:studysync/screens/login_screen.dart';
import 'models/group.dart';
import 'models/meeting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GroupAdapter());
  Hive.registerAdapter(MeetingAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<Group>('groups');
  await Hive.openBox<Meeting>('meetings');
  final userBox = await Hive.openBox<User>('users');

  runApp(
    BlocProvider(
      create: (context) => UserBloc(userBox: userBox)..add(LoadCurrentUser()),
    child: const StudySyncApp(),)
  );
}

class StudySyncApp extends StatelessWidget {
  const StudySyncApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySync',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const LoginScreen(),
    );
  }
}
