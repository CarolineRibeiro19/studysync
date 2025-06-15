import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:studysync/models/group.dart';
import 'package:studysync/screens/groups/group_detail_screen.dart';
import 'package:studysync/screens/groups/nearby_devices_screen.dart';
import 'package:studysync/services/group_service.dart';
import 'package:studysync/blocs/user/user_bloc.dart'; 
import 'package:studysync/blocs/user/user_event.dart'; 

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
    _loadGroups(); 
  }

  
  Future<void> _loadGroups() async {
    setState(() {
      isLoading = true; 
    });
    try {
      final loadedGroups = await _groupService.fetchUserGroups();
      setState(() {
        groups = loadedGroups; 
        isLoading = false; 
      });
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar grupos: $e')),
      );
      setState(() {
        isLoading = false; 
      });
    }
  }

  
  void _enterGroupById(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
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
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); 
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, insira o ID do grupo.')),
                );
                return;
              }
              final joined = await _groupService.joinGroupByInviteCode(controller.text.trim());
              if (joined) {
                _loadGroups(); 
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
            const SizedBox(height: 15), 
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
                
                final currentGroups = await _groupService.fetchUserGroups();
                final newGroup = currentGroups.firstWhere(
                  (group) => group.name == nameController.text.trim() && group.subject == subjectController.text.trim(),
                  orElse: () => throw Exception('Newly created group not found!'), 
                );

                
                context.read<UserBloc>().add(
                      UpdateUserGroupPoints(groupId: newGroup.id, pointsToAdd: 100), 
                    );

                _loadGroups(); 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Grupo criado com sucesso! Você ganhou 100 pontos.')),
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
      backgroundColor: theme.primaryColor.withOpacity(0.05),
      appBar: AppBar(
        title: const Text('Meus Grupos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Botão para receber código de grupo (disponível para todos)
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            tooltip: 'Receber Código de Grupo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NearbyDevicesScreen(isReceiving: true)),
              );
            },
          ),
          // Botão para compartilhar código de grupo (apenas para quem tem grupos)
          if (groups.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Compartilhar Código de Grupo',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NearbyDevicesScreen(isReceiving: false)),
                );
              },
            ),
          // Botão para criar novo grupo
          IconButton(
            icon: const Icon(Icons.group_add_outlined, size: 28),
            tooltip: 'Criar Novo Grupo',
            onPressed: () => _createGroup(context),
          ),
          // Botão para entrar em grupo
          IconButton(
            icon: const Icon(Icons.login, size: 28),
            tooltip: 'Entrar em Grupo',
            onPressed: () => _enterGroupById(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupDetailScreen(group: group),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
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