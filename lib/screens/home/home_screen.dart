import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../blocs/meeting/meeting_bloc.dart';
import '../../blocs/meeting/meeting_state.dart';
import '../../models/meeting.dart';
import '../../widgets/custom_buttom.dart';
import '../checkin/checkin_screen.dart';
import '../groups/group_screen.dart';
import '../profile/profile_screen.dart';
import '../ranking/ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupScreen()));
        break;
      case 1:
      // já está na home
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is! UserAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = userState.user;

        return Scaffold(
          backgroundColor: Colors.blue[50],
          appBar: AppBar(
            title: const Text('StudySync'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.star),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RankingScreen()),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<MeetingBloc, MeetingState>(
            builder: (context, meetingState) {
              if (meetingState is! MeetingLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final today = DateTime.now();
              final todayMeetings = meetingState.meetings.where((meeting) {
                return meeting.dateTime.year == today.year &&
                    meeting.dateTime.month == today.month &&
                    meeting.dateTime.day == today.day &&
                    meeting.groupId == currentUser.groupId;
              }).toList()
                ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: todayMeetings.isEmpty
                    ? const Center(child: Text('Nenhuma reunião para hoje.'))
                    : ListView.builder(
                  itemCount: todayMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = todayMeetings[index];
                    return Card(
                      child: ListTile(
                        title: Text(meeting.title),
                        subtitle: Text(
                          DateFormat('HH:mm').format(meeting.dateTime),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
