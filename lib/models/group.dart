import "../models/hive_group_model.dart";

class Group {
  final String id;
  final String name;
  final String subject;
  final List<String> members;

  Group({
    required this.id,
    required this.name,
    required this.subject,
    this.members = const [],
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      subject: map['subject'],
      members: [], // será preenchido depois se necessário
    );
  }

  Group copyWith({
    String? id,
    String? name,
    String? subject,
    List<String>? members,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
    };
  }
}

extension HiveGroupToGroup on HiveGroup {
  Group toGroup({List<String>? members}) {
    return Group(
      id: id,
      name: name,
      subject: subject,
      members: members ?? [], // Preenche com os membros fornecidos ou mantém vazio
    );
  }
}
