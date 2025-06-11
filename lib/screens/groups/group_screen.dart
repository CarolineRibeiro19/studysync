import 'package:flutter/material.dart';
import 'package:studysync/models/group.dart';
import 'package:studysync/screens/groups/group_detail_screen.dart';
import 'package:studysync/services/group_service.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GroupService _groupService = GroupService();
  List<Group> groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups(); // Load groups when the screen initializes.
  }

  // Fetches the user's groups from the service.
  Future<void> _loadGroups() async {
    setState(() {
      isLoading = true; // Set loading to true while fetching.
    });
    try {
      final loadedGroups = await _groupService.fetchUserGroups();
      setState(() {
        groups = loadedGroups; // Update the groups list.
        isLoading = false; // Set loading to false after data is loaded.
      });
    } catch (e) {
      // Handle error during group loading.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar grupos: $e')),
      );
      setState(() {
        isLoading = false; // Stop loading even if there's an error.
      });
    }
  }

  // Shows a dialog for joining an existing group by its ID.
  void _enterGroupById(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners for dialog.
        title: const Text('Entrar em Grupo', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'ID do Grupo',
            hintText: 'Ex: 12345',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.vpn_key),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Close dialog.
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog before performing action.
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, insira o ID do grupo.')),
                );
                return;
              }
              final joined = await _groupService.joinGroupByInviteCode(controller.text.trim());
              if (joined) {
                _loadGroups(); // Reload groups after successful join.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Você entrou no grupo com sucesso!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao entrar no grupo. Verifique o ID.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  // Shows a dialog for creating a new group.
  void _createGroup(BuildContext context) {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Criar Novo Grupo', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Grupo',
                hintText: 'Ex: Estudo de Cálculo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 15), // Spacing between text fields.
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Matéria',
                hintText: 'Ex: Matemática',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.book),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (nameController.text.trim().isEmpty || subjectController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, preencha todos os campos.')),
                );
                return;
              }
              final created = await _groupService.createGroup(
                name: nameController.text.trim(),
                subject: subjectController.text.trim(),
              );
              if (created) {
                _loadGroups(); // Reload groups after successful creation.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Grupo criado com sucesso!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao criar grupo. Tente novamente.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor.withOpacity(0.05), // Light background.
      appBar: AppBar(
        title: const Text('Meus Grupos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0, // No shadow for a modern flat look.
        actions: [
          // Button to create a new group.
          IconButton(
            icon: const Icon(Icons.group_add_outlined, size: 28), // Larger icon for better tap target.
            tooltip: 'Criar Novo Grupo',
            onPressed: () => _createGroup(context),
          ),
          // Button to join an existing group.
          IconButton(
            icon: const Icon(Icons.login, size: 28), // Larger icon for better tap target.
            tooltip: 'Entrar em Grupo',
            onPressed: () => _enterGroupById(context),
          ),
          const SizedBox(width: 8), // Padding at the end of actions.
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator.
          : groups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined, // Icon for empty state.
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Você ainda não participa de nenhum grupo.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Crie um novo grupo ou entre em um existente para começar a estudar!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () => _createGroup(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Criar Meu Primeiro Grupo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groups.length,
                  itemBuilder: (_, index) {
                    final group = groups[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4, // Subtle shadow for cards.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // More rounded corners.
                      ),
                      child: InkWell( // Use InkWell for better visual feedback on tap.
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(group: group),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(15), // Match card border radius.
                        child: Padding(
                          padding: const EdgeInsets.all(12.0), // Inner padding for ListTile content.
                          child: Row(
                            children: [
                              // Group icon or initial avatar.
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.secondary,
                                child: Text(
                                  group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.name,
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Matéria: ${group.subject}',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.people_alt, color: Colors.grey[600], size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${group.members.length} membros',
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}