import 'dart:io';

class ChatImageModel {
  final File file;
  final String senderName;
  final DateTime timestamp;

  ChatImageModel({
    required this.file,
    required this.senderName,
    required this.timestamp,
  });

  // Serialização para envio via socket (sem o arquivo)
  Map<String, dynamic> toJson() {
    return {
      'filePath': file.path, // vamos mandar só o path
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Desserialização ao receber dados
  factory ChatImageModel.fromJson(Map<String, dynamic> json) {
    return ChatImageModel(
      file: File(json['filePath']),
      senderName: json['senderName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}



