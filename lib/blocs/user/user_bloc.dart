import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc({required this.userService}) : super(UserInitial()) {
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<LoginUser>(_onLoginUser);
    on<RegisterUser>(_onRegisterUser);
    on<UpdateUserProfile>(_onUpdateUser);
    on<UpdateUserGroupPoints>(_onUpdateUserGroupPoints);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await userService.getCurrentUserProfile();
      if (user != null) {
        emit(UserAuthenticated(user));
      } else {
        emit(UserUnauthenticated());
      }
    } catch (e) {
      emit(UserError('Failed to load user: $e'));
      emit(UserUnauthenticated());
    }
  }

  Future<void> _onLoginUser(LoginUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final success = await userService.loginUser(event.email, event.password);
      if (success) {
        final user = await userService.getCurrentUserProfile();
        if (user != null) {
          emit(UserAuthenticated(user));
          return;
        }
      }
      emit(UserError('Invalid login credentials.'));
    } catch (e) {
      emit(UserError('Login failed: $e'));
    }
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
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
    } catch (e) {
      emit(UserError('Registration failed: $e'));
    }
  }

  Future<void> _onUpdateUser(UpdateUserProfile event, Emitter<UserState> emit) async {
    if (state is! UserAuthenticated) {
      emit(UserError('User not authenticated for profile update.'));
      return;
    }

    final currentUser = (state as UserAuthenticated).user;
    emit(UserLoading());

    try {
      final updatedUser = await userService.updateUserProfile(
        id: currentUser.id,
        name: event.name,
      );
      if (updatedUser != null) {
        emit(UserAuthenticated(updatedUser));
      } else {
        emit(UserError('Failed to update profile.'));
        emit(UserAuthenticated(currentUser));
      }
    } catch (e) {
      emit(UserError('Error updating profile: $e'));
      emit(UserAuthenticated(currentUser));
    }
  }

  
  Future<void> _onUpdateUserGroupPoints(
    UpdateUserGroupPoints event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserAuthenticated) {
      emit(UserError('User not authenticated to update points.'));
      return;
    }

    final currentUser = (state as UserAuthenticated).user;
    emit(UserLoading()); 

    try {
      
      final User? newUserData = await userService.updateUserGroupPoints(
        userId: currentUser.id,
        groupId: event.groupId,
        pointsToAdd: event.pointsToAdd,
      );

      if (newUserData != null) {
        emit(UserAuthenticated(newUserData)); 
      } else {
        emit(UserError('Failed to update group points.'));
        emit(UserAuthenticated(currentUser)); 
      }
    } catch (e) {
      emit(UserError('Error updating group points: $e'));
      emit(UserAuthenticated(currentUser)); 
    }
  }

  Future<void> _onLogoutUser(LogoutUser event, Emitter<UserState> emit) async {
    try {
      await userService.signOutUser();
      emit(UserUnauthenticated());
    } catch (e) {
      emit(UserError('Logout failed: $e'));
    }
  }
}