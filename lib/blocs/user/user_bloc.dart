import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:studysync/blocs/user/user_event.dart';
import 'package:studysync/blocs/user/user_state.dart';
import '../../models/user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Box<User> userBox;

  UserBloc({required this.userBox}) : super(UserInitial()) {
    on<RegisterUser>(_onRegisterUser);
    on<LoginUser>(_onLoginUser);
    on<LogoutUser>(_onLogoutUser);
    on<LoadCurrentUser>(_onLoadCurrentUser);
  }

  void _onRegisterUser(RegisterUser event, Emitter<UserState> emit) async {
    emit(UserLoading());

    final exists = userBox.values.any((u) => u.email == event.email);
    if (exists) {
      emit(const UserError("Email Already Exists"));
      return;
    }

    final user = User(
      email: event.email,
      name: event.name,
      password: event.password,
    );

    user.isLoggedIn = true;
    await userBox.put(user.id, user);

    emit(UserAuthenticated(user));
  }

  void _onLoginUser(LoginUser event, Emitter<UserState> emit) async {
    emit(UserLoading());

    try {
      final user = userBox.values.firstWhere(
        (u) => u.email == event.email && u.password == event.password,
      );

      user.isLoggedIn = true;
      await user.save();

      emit(UserAuthenticated(user));
    } catch (_) {
      emit(const UserError('Email or password incorrect'));
    }
  }

  void _onLogoutUser(LogoutUser event, Emitter<UserState> emit) async {
    final currentUser =
        userBox.values.where((u) => u.isLoggedIn == true).firstOrNull;

    if (currentUser != null) {
      currentUser.isLoggedIn = false;
      await currentUser.save();
    }

    emit(UserUnauthenticated());
  }

  void _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    User? currentUser =
        userBox.values.where((u) => u.isLoggedIn == true).firstOrNull;

    if (currentUser != null) {
      emit(UserAuthenticated(currentUser));
    } else {
      emit(UserUnauthenticated());
    }
  }
}
