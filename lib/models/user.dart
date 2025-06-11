class User {
  final String id;
  final String email;
  final String name;
  final List<dynamic>? groupId;
  final int points;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.groupId = null,
    this.points = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'],
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    groupId: (json['group_id'] as List?)?.map((e) => e ).toList(),
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
