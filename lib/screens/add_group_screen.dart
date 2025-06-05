import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studysync/models/group.dart';
import 'package:studysync/models/user.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _memberCountController = TextEditingController();

  void _saveGroup() {
    if (_formKey.currentState!.validate()) {
      final groupBox = Hive.box<Group>('groups');
      final userBox = Hive.box<User>('users');
      final currentUser = userBox.values.firstWhere((u) => u.isLoggedIn);

      final newGroup = Group(
        name: _nameController.text.trim(),
        subject: _subjectController.text.trim(),
        memberCount: int.parse(_memberCountController.text),
        createdBy: currentUser.id,
        members: [currentUser.id], // ✅ Adiciona o criador como membro
      );

      groupBox.add(newGroup);
      Navigator.pop(context); // Volta para GroupScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Novo Grupo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Grupo'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Matéria'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _memberCountController,
                decoration: const InputDecoration(labelText: 'Nº de Participantes'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || int.tryParse(value) == null
                    ? 'Número inválido'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGroup,
                child: const Text('Criar Grupo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
