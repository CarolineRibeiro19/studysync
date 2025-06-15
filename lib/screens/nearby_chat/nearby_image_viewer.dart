import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat_image_model.dart';

class NearbyImageViewer extends StatelessWidget {
  final ChatImageModel image;

  const NearbyImageViewer({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd/MM/yyyy HH:mm').format(image.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: Text('Imagem de ${image.senderName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(image.file.path),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enviado por ${image.senderName} em $dateFormatted',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


