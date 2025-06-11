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
    // Initialize the name controller with the current user's name if authenticated, otherwise empty.
    final state = context.read<UserBloc>().state;
    if (state is UserAuthenticated) {
      _nameController = TextEditingController(text: state.user.name);
    } else {
      _nameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose the controller to prevent memory leaks.
    _nameController.dispose();
    super.dispose();
  }

  // Toggles between edit and view mode, or saves the profile if in edit mode.
  void _toggleEditOrSave(UserAuthenticated userState) {
    if (_isEditing) {
      // If currently editing, validate the form and save.
      if (_formKey.currentState?.validate() ?? false) {
        // Dispatch an event to the UserBloc to update the user profile.
        context
            .read<UserBloc>()
            .add(UpdateUserProfile(_nameController.text.trim()));
        // Show a snackbar to confirm the update.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        // Exit edit mode.
        setState(() {
          _isEditing = false;
        });
      }
    } else {
      // If not editing, enter edit mode.
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme for consistent styling.

    return Scaffold(
      backgroundColor: theme.primaryColor.withOpacity(0.05), // Light background for contrast.
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true, // Center the app bar title.
        elevation: 0, // Remove shadow for a flatter look.
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          // Listen for state changes to update the name controller if the user data refreshes
          // and we are not currently editing. This prevents overwriting user input during editing.
          if (state is UserAuthenticated && !_isEditing) {
            _nameController.text = state.user.name;
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            // Show a loading indicator when user data is being fetched.
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserAuthenticated) {
            final user = state.user; // Get the authenticated user data.

            return SingleChildScrollView( // Allows scrolling if content overflows on smaller screens.
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Profile picture / avatar section.
                  Center(
                    child: CircleAvatar(
                      radius: 60, // Large avatar size.
                      backgroundColor: theme.primaryColor,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', // Display first letter of name.
                        style: const TextStyle(fontSize: 48, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Spacing after avatar.

                  // User information card.
                  Card(
                    elevation: 5, // Adds a subtle shadow for depth.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners for the card.
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name display or input field.
                            _isEditing
                                ? TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nome Completo',
                                      hintText: 'Digite seu nome',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Icon(Icons.person),
                                    ),
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                            ? 'O nome não pode ser vazio'
                                            : null,
                                  )
                                : ListTile(
                                    leading: const Icon(Icons.person, color: Colors.blueGrey),
                                    title: Text(
                                      'Nome',
                                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey[700]),
                                    ),
                                    subtitle: Text(
                                      user.name,
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            const SizedBox(height: 16),

                            // Email display.
                            ListTile(
                              leading: const Icon(Icons.email, color: Colors.blueGrey),
                              title: Text(
                                'Email',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey[700]),
                              ),
                              subtitle: Text(
                                user.email,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Points display.
                            ListTile(
                              leading: const Icon(Icons.star, color: Colors.amber),
                              title: Text(
                                'Pontos',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey[700]),
                              ),
                              subtitle: Text(
                                '${user.points}',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Spacing after the card.

                  // Action buttons.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Edit/Save button.
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleEditOrSave(state),
                          icon: Icon(_isEditing ? Icons.save : Icons.edit),
                          label: Text(_isEditing ? 'Salvar' : 'Editar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor, // Use primary color for main action.
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15), // Spacing between buttons.

                      // Logout button.
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<UserBloc>().add(LogoutUser()); // Dispatch logout event.
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (_) => false); // Navigate to root and remove all routes.
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sair'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent, // Distinct color for logout.
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // Display message if user is not authenticated.
            return const Center(child: Text('Usuário não autenticado.'));
          }
        },
      ),
    );
  }
}
