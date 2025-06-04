import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> futureMeetings = [
    {'title': 'Reunião de Cálculo', 'date': '04/06 - 18h00'},
    {'title': 'Grupo de IA', 'date': '05/06 - 15h30'},
    {'title': 'Estudos para Compiladores', 'date': '06/06 - 10h00'},
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/groups');
        break;
      case 2:
        Navigator.pushNamed(context, '/checkin');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const int userPoints = 120;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('StudySync'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text('$userPoints'),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Próximas Reuniões',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: futureMeetings.isEmpty
                  ? const Text('Nenhuma reunião agendada.')
                  : ListView.builder(
                itemCount: futureMeetings.length,
                itemBuilder: (context, index) {
                  final meeting = futureMeetings[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(meeting['title']!),
                      subtitle: Text(meeting['date']!),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Em breve: detalhes da reunião
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Ver histórico de reuniões'),
                onPressed: () => Navigator.pushNamed(context, '/history'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grupos',
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
