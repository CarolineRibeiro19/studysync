import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<UserBloc>().state;
    if (state is UserAuthenticated) {
      _nameController = TextEditingController(text: state.user.name);
    } else {
      _nameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditOrSave(UserAuthenticated userState) {
    if (_isEditing) {
      if (_formKey.currentState?.validate() ?? false) {
        // Save and update via Bloc
        context
            .read<UserBloc>()
            .add(UpdateUserProfile(_nameController.text.trim()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
      appBar: AppBar(title: const Text('Perfil')),
      body: BlocBuilder<UserBloc, UserState>(
  builder: (context, state) {
    if (state is UserLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is UserAuthenticated) {
      final user = state.user;

      // Update nameController if not editing
      if (!_isEditing) {
        _nameController.text = user.name;
      }

      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditing
                  ? TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) =>
                          (value == null || value.isEmpty)
                              ? 'Nome não pode ser vazio'
                              : null,
                    )
                  : Text('Nome: ${user.name}',
                      style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Email: ${user.email}',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text('Grupo: ${user.groupId}',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text('Pontos: ${user.points}',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _toggleEditOrSave(state),
                    child: Text(_isEditing ? 'Salvar' : 'Editar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(LogoutUser());
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (_) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Sair'),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return const Center(child: Text('Usuário não autenticado.'));
    }
  },
),

    );
  }
}
