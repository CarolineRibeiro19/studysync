abstract class UserEvent {}

class LoadCurrentUser extends UserEvent {}

class LoginUser extends UserEvent {
  final String email;
  final String password;

  LoginUser({required this.email, required this.password});
}

class RegisterUser extends UserEvent {
  final String name;
  final String email;
  final String password;

  RegisterUser({
    required this.name,
    required this.email,
    required this.password,
  });
}

class UpdateUserProfile extends UserEvent {
  final String name; 
  UpdateUserProfile(this.name);
}


class UpdateUserGroupPoints extends UserEvent {
  final String groupId;
  final int pointsToAdd; 

  UpdateUserGroupPoints({required this.groupId, required this.pointsToAdd});
}


class LogoutUser extends UserEvent {}