import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/checkin/checkin_screen.dart';
import 'screens/groups/group_screen.dart';
import 'screens/meetings/history_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/ranking/ranking_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/checkin': (context) => const CheckInScreen(),
  '/group': (context) => const GroupScreen(),
  '/history': (context) => const HistoryScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/ranking': (context) => const RankingScreen(),
};
