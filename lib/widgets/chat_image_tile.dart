import 'package:flutter/material.dart';
import '../models/chat_image_model.dart';
import 'package:intl/intl.dart';

class ChatImageTile extends StatelessWidget {
  final ChatImageModel imageModel;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const ChatImageTile({
    Key? key,
    required this.imageModel,
    this.isCurrentUser = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat.Hm().format(imageModel.timestamp);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(
                imageModel.file,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 5),
              Text(
                isCurrentUser ? "Você" : imageModel.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                timeFormatted,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


