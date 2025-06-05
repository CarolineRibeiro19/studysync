import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupIdController = TextEditingController();

  String? _errorMessage;

  void _joinGroup(BuildContext context, User user) {
    final groupBox = Hive.box<Group>('groups');
    final enteredId = _groupIdController.text.trim();

    final groups = groupBox.values.where((g) => g.id == enteredId).toList();

    if (groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo não encontrado.')),
      );
      return;
    }

    final group = groups.first;


    if (group.members.contains(user.id)) {
      setState(() {
        _errorMessage = 'Você já está neste grupo.';
      });
      return;
    }

    group.members.add(user.id);
    group.save();

    Navigator.pop(context); // Volta para tela de grupos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar em Grupo')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is! UserAuthenticated) {
            return const Center(child: Text("Usuário não autenticado."));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _groupIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID do Grupo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Digite o ID do grupo' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _joinGroup(context, state.user);
                      }
                    },
                    child: const Text('Entrar no Grupo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
