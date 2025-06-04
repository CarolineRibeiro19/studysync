import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/group.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _subject = '';
  int _memberCount = 1;

  void _saveGroup() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newGroup = Group(
        name: _name,
        subject: _subject,
        memberCount: _memberCount,
      );

      final box = Hive.box<Group>('groups');
      box.add(newGroup);

      Navigator.pop(context); // volta para GroupScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Grupo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do grupo'),
                validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Matéria'),
                validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                onSaved: (value) => _subject = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Número de pessoas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final intValue = int.tryParse(value ?? '');
                  if (intValue == null || intValue <= 0) {
                    return 'Número inválido';
                  }
                  return null;
                },
                onSaved: (value) => _memberCount = int.parse(value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveGroup,
                icon: const Icon(Icons.check),
                label: const Text('Criar Grupo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
