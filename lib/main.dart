import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/group.dart';
import 'models/meeting.dart';
import 'models/user.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/user/user_event.dart';
import 'blocs/user/user_state.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/group_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ranking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(GroupAdapter());
  Hive.registerAdapter(MeetingAdapter());
  Hive.registerAdapter(UserAdapter());

  final groupBox = await Hive.openBox<Group>('groups');
  final meetingBox = await Hive.openBox<Meeting>('meetings');
  final userBox = await Hive.openBox<User>('users');

  runApp(StudySyncApp(userBox: userBox));
}

class StudySyncApp extends StatelessWidget {
  final Box<User> userBox;

  const StudySyncApp({super.key, required this.userBox});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc(userBox: userBox)..add(LoadCurrentUser()),
      child: MaterialApp(
        title: 'StudySync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const AppEntryPoint(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/groups': (_) => const GroupScreen(),
          '/checkin': (_) => const CheckInScreen(),
          '/history': (_) => const HistoryScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/ranking': (_) => const RankingScreen(),
        },
      ),
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is UserAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
