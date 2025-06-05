import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/group.dart';
import '../models/meeting.dart';
import '../models/user.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';
import 'group_screen.dart';
import 'checkin_screen.dart';
import 'ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  late final Box<Group> groupBox = Hive.box<Group>('groups');
  late final Box<Meeting> meetingBox = Hive.box<Meeting>('meetings');

  final List<Widget> _screens = [
    const GroupScreen(),
    const _MainHomeTab(),
    const CheckInScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openRanking() {
    Navigator.pushNamed(context, '/ranking');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudySync'),
        centerTitle: true,
        leading: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserAuthenticated) {
              return GestureDetector(
                onTap: _openRanking,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.star, color: Colors.amber, size: 20),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        TextSpan(
                          text: '${state.user.points}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Presença',
          ),
        ],
      ),
    );
  }
}

class _MainHomeTab extends StatelessWidget {
  const _MainHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Meeting> meetingBox = Hive.box<Meeting>('meetings');
    final now = DateTime.now();

    final todayMeetings = meetingBox.values
        .where((m) =>
    m.dateTime.year == now.year &&
        m.dateTime.month == now.month &&
        m.dateTime.day == now.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reuniões de Hoje',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          todayMeetings.isEmpty
              ? const Text('Nenhuma reunião marcada para hoje.')
              : Expanded(
            child: ListView.builder(
              itemCount: todayMeetings.length,
              itemBuilder: (context, index) {
                final meeting = todayMeetings[index];
                return Card(
                  child: ListTile(
                    title: Text(meeting.title),
                    subtitle:
                    Text(DateFormat('HH:mm').format(meeting.dateTime)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
