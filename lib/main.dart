import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/user/user_event.dart';
import 'blocs/meeting/meeting_bloc.dart';
import 'routes.dart';
import 'themes//app_theme.dart';
import 'services/meeting_service.dart';
import 'services/user_service.dart';
import 'app_entry_point.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gxsjhocypdxvatgfgckf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4c2pob2N5cGR4dmF0Z2ZnY2tmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1NzgwODgsImV4cCI6MjA2NTE1NDA4OH0.nGJ9K226qwP9kRMMpByKzoEhwvcuDq-CzL_HE4ybRL4',
  );

  runApp(const StudySyncApp());
}

class StudySyncApp extends StatelessWidget {
  const StudySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userService = UserService(supabase);
    final meetingService = MeetingService(supabase);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => UserBloc(userService: userService)..add(LoadCurrentUser()),
        ),
        BlocProvider(
          create: (_) => MeetingBloc(meetingService: meetingService),
        ),
      ],
      child: MaterialApp(
        title: 'StudySync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: appRoutes,
        builder: (context, child) {
          return AppEntryPoint(child: child!);
        },
      ),
    );
  }
}
