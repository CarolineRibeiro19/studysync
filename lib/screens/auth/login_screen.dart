import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/user/user_state.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor.withOpacity(0.05),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is UserLoading;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('StudySync', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 32),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Senha'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<UserBloc>().add(
                                    LoginUser(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    ),
                                  );
                            },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Entrar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Criar conta'),
                    ),
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
