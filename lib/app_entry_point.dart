import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studysync/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/user/user_event.dart';
import 'blocs/meeting/meeting_bloc.dart';
import 'blocs/meeting/meeting_event.dart';
import 'services/meeting_service.dart';

class AppEntryPoint extends StatelessWidget {
  final Widget child;

  const AppEntryPoint({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
          UserBloc(userService: UserService(supabase))..add(LoadCurrentUser()),
        ),
        BlocProvider(
          create: (_) => MeetingBloc(
              meetingService: MeetingService(supabase)),
        ),
      ],
      child: child,
    );
  }
}
