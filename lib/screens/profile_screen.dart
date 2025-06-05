import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final state = context.read<UserBloc>().state;
    if (state is UserAuthenticated) {
      _nameController = TextEditingController(text: state.user.name);
      _passwordController = TextEditingController(text: state.user.password);
    } else {
      _nameController = TextEditingController();
      _passwordController = TextEditingController();
    }
  }

  void _saveChanges(User user) async {
    user.name = _nameController.text.trim();
    user.password = _passwordController.text.trim();
    await user.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados atualizados com sucesso!')),
    );

    context.read<UserBloc>().add(LoadCurrentUser());
  }

  void _logout() {
    context.read<UserBloc>().add(LogoutUser());
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _deleteAccount(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text('Tem certeza de que deseja excluir sua conta permanentemente?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await user.delete();
      context.read<UserBloc>().add(LogoutUser());
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserAuthenticated) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  TextFormField(
                    controller: TextEditingController(text: user.email),
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Pontos: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${user.points}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Desde: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('dd/MM/yyyy').format(user.createdAt)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Alterações'),
                    onPressed: () => _saveChanges(user),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair da Conta'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: _logout,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Excluir Conta'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _deleteAccount(user),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
