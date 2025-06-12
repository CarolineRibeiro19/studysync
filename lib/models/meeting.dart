import 'package:equatable/equatable.dart';

class Meeting extends Equatable {
  final String id;
  final String title;
  final DateTime dateTime;
  final String groupId;
  final String location;
  final double? lat; // Added lat field
  final double? long; // Added long field

  const Meeting({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.groupId,
    required this.location,
    this.lat, // Added lat to constructor
    this.long, // Added long to constructor
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      dateTime: DateTime.parse(json['date_time']),
      groupId: json['group_id'].toString(),
      location: json['location'] ?? '',
      lat: (json['lat'] as num?)?.toDouble(), 
      long: (json['long'] as num?)?.toDouble(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'group_id': groupId,
      'location': location,
      'lat': lat,
      'long': long,
    };
  }

  Meeting copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? groupId,
    String? location,
    double? lat, 
    double? long,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      groupId: groupId ?? this.groupId,
      location: location ?? this.location,
      lat: lat ?? this.lat,
      long: long ?? this.long, 
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        dateTime,
        groupId,
        location,
        lat, // Add lat to props
        long, // Add long to props
      ];
}