import 'package:flutter/material.dart';

class Meeting {
  final String id;
  final String title;
  final DateTime dateTime;
  final DateTime endTime; // ⬅️ Novo campo
  final String location;
  final String groupId;
  final double? lat;
  final double? long;

  Meeting({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.endTime, // ⬅️ Novo campo requerido
    required this.location,
    required this.groupId,
    this.lat,
    this.long,
  });

  // Método para converter Meeting em Map (para salvar no Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'end_time': endTime.toIso8601String(), // ⬅️ Novo campo
      'location': location,
      'group_id': groupId,
      'lat': lat,
      'long': long,
    };
  }

  // Método para criar um Meeting a partir de um Map (vindo do Supabase)
  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'],
      title: map['title'],
      dateTime: DateTime.parse(map['date_time']),
      endTime: DateTime.parse(map['end_time']), // ⬅️ Novo campo
      location: map['location'],
      groupId: map['group_id'],
      lat: map['lat']?.toDouble(),
      long: map['long']?.toDouble(),
    );
  }

  // Método auxiliar opcional
  Meeting copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    DateTime? endTime,
    String? location,
    String? groupId,
    double? lat,
    double? long,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      groupId: groupId ?? this.groupId,
      lat: lat ?? this.lat,
      long: long ?? this.long,
    );
  }
}
