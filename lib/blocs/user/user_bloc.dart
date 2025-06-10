import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../models/user.dart' as model;
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final supa.SupabaseClient supabase;

  UserBloc({required this.supabase}) : super(UserInitial()) {
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onLoadCurrentUser(
      LoadCurrentUser event,
      Emitter<UserState> emit,
      ) async {
    emit(UserLoading());

    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        emit(UserUnauthenticated());
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', int.parse(authUser.id))
          .single();

      final user = model.User(
        id: profile['id'],
        email: authUser.email ?? '',
        name: profile['name'] ?? '',
        groupId: profile['group_id'],
        points: profile['points'] ?? 0,
      );

      emit(UserAuthenticated(user));
    } catch (e) {
      emit(UserError('Erro ao carregar usuário: $e'));
    }
  }

  Future<void> _onLogoutUser(
      LogoutUser event,
      Emitter<UserState> emit,
      ) async {
    await supabase.auth.signOut();
    emit(UserUnauthenticated());
  }
}
