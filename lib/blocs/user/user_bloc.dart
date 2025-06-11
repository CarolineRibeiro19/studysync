import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/user_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc({required this.userService}) : super(UserInitial()) {
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<LoginUser>(_onLoginUser);
    on<RegisterUser>(_onRegisterUser);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final user = await userService.getCurrentUserProfile();
    if (user != null) {
      emit(UserAuthenticated(user));
    } else {
      emit(UserUnauthenticated());
    }
  }

  Future<void> _onLoginUser(LoginUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    final success = await userService.loginUser(event.email, event.password);
    if (success) {
      final user = await userService.getCurrentUserProfile();
      if (user != null) {
        emit(UserAuthenticated(user));
        return;
      }
    }
    emit(UserError('Invalid login credentials.'));
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final success = await userService.registerUser(
      event.name,
      event.email,
      event.password,
    );
    if (success) {
      final user = await userService.getCurrentUserProfile();
      if (user != null) {
        emit(UserAuthenticated(user));
        return;
      }
    }
    emit(UserError('Registration failed.'));
  }

  Future<void> _onLogoutUser(LogoutUser event, Emitter<UserState> emit) async {
    await userService.signOutUser();
    emit(UserUnauthenticated());
  }
}
