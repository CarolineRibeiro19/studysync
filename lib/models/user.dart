

class User {
  final String id;
  final String email;
  final String name;
  final List<dynamic>? groupId; 
  final int points; 
  final Map<String, int> groupPoints; 

  User({
    required this.id,
    required this.email,
    required this.name,
    this.groupId,
    this.points = 0, 
    this.groupPoints = const {}, 
  });

  factory User.fromJson(Map<String, dynamic> json) {
    
    final List<dynamic>? rawGroupIds = json['group_id'] as List?;
    final List<dynamic>? parsedGroupIds = rawGroupIds?.map((e) => e).toList();

    
    final Map<String, dynamic>? rawGroupPoints = json['group_points'] as Map<String, dynamic>?;
    final Map<String, int> parsedGroupPoints = rawGroupPoints?.map(
      (key, value) => MapEntry(key, value as int),
    ) ?? {}; 

    return User(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      groupId: parsedGroupIds,
      points: json['points'] ?? 0, 
      groupPoints: parsedGroupPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'group_id': groupId,
      'points': points, 
      'group_points': groupPoints, 
    };
  }

  
  int getPointsForGroup(String groupId) {
    return groupPoints[groupId] ?? 0;
  }

  
  User copyWith({
    String? id,
    String? email,
    String? name,
    List<dynamic>? groupId,
    int? points,
    Map<String, int>? groupPoints,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      points: points ?? this.points,
      groupPoints: groupPoints ?? this.groupPoints,
    );
  }
}