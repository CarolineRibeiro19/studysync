import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/chat_image_model.dart';
import '../../services/socket_chat_service.dart';
import '../../widgets/chat_image_tile.dart';
import 'nearby_image_viewer.dart';

class NearbyChatScreen extends StatefulWidget {
  final String userName;
  final String meetingId;
  final bool isHost;      // novo: define se é servidor ou cliente
  final String? serverIp; // novo: IP do host (usado por cliente)

  const NearbyChatScreen({
    Key? key,
    required this.userName,
    required this.meetingId,
    required this.isHost,
    this.serverIp,
  }) : super(key: key);

  @override
  State<NearbyChatScreen> createState() => _NearbyChatScreenState();
}

class _NearbyChatScreenState extends State<NearbyChatScreen> {
  final List<ChatImageModel> _images = [];
  final ImagePicker _picker = ImagePicker();
  final SocketChatService _chatService = SocketChatService();

  @override
  void initState() {
    super.initState();
    _chatService.imageStream.listen((image) {
      setState(() => _images.add(image));
    });

    if (widget.isHost) {
      _chatService.startServer(widget.userName);
    } else if (widget.serverIp != null) {
      _chatService.connectToServer(widget.serverIp!);
    }
  }

  @override
  void dispose() {
    _chatService.stop();
    _chatService.dispose();
    super.dispose();
  }

  Future<void> _sendImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final imageModel = ChatImageModel(
        file: file,
        senderName: widget.userName,
        timestamp: DateTime.now(),
      );
      setState(() => _images.add(imageModel));
      _chatService.sendImage(imageModel);
    }
  }

  void _viewImage(ChatImageModel image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NearbyImageViewer(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat da Reunião'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _sendImage,
            tooltip: 'Enviar imagem',
          ),
        ],
      ),
      body: _images.isEmpty
          ? const Center(child: Text('Nenhuma imagem compartilhada ainda.'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final img = _images[index];
          return GestureDetector(
            onTap: () => _viewImage(img),
            child: ChatImageTile(imageModel: img),
          );
        },
      ),
    );
  }
}



