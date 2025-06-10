class Group {
  final int id;
  final String name;
  final List<int> members;
  final int createdBy;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.createdBy,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      members: List<int>.from(json['members'] ?? []),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'created_by': createdBy,
    };
  }
}
