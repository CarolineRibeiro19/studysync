class Meeting {
  final int id;
  final String title;
  final DateTime dateTime;
  final int groupId;
  final bool attended;

  Meeting({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.groupId,
    required this.attended,
  });

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'] as int,
      title: map['title'],
      dateTime: DateTime.parse(map['date_time']),
      groupId: map['group_id'],
      attended: map['attended'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'group_id': groupId,
      'attended': attended,
    };
  }

  Meeting copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    int? groupId,
    bool? attended,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      groupId: groupId ?? this.groupId,
      attended: attended ?? this.attended,
    );
  }
}
