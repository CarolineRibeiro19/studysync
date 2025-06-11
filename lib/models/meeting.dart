class Meeting {
  final String id;
  final String title;
  final DateTime dateTime;
  final String groupId;
  final bool attended;
  final String location;

  Meeting({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.groupId,
    this.attended = false,
    required this.location,
  });

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      dateTime: DateTime.parse(map['date_time']),
      groupId: map['group_id'].toString(),
      attended: map['attended'] ?? false,
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'group_id': groupId,
      'attended': attended,
      'location': location,
    };
  }

  Meeting copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? groupId,
    bool? attended,
    String? location,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      groupId: groupId ?? this.groupId,
      attended: attended ?? this.attended,
      location: location ?? this.location,
    );
  }
}
