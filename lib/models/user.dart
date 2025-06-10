class User {
  final int id; // ID do Supabase (int8)
  final String email;
  final String name;
  final int? groupId;
  final int points;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.groupId,
    this.points = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      groupId: json['group_id'],
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'group_id': groupId,
      'points': points,
    };
  }
}
