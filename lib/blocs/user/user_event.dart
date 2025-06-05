import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class RegisterUser extends UserEvent {
  final String name;
  final String email;
  final String password;

  const RegisterUser({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class LoginUser extends UserEvent {
  final String email;
  final String password;

  const LoginUser({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutUser extends UserEvent {}

class LoadCurrentUser extends UserEvent {}