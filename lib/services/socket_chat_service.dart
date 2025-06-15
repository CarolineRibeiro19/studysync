import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/chat_image_model.dart';

class SocketChatService {
  ServerSocket? _server;
  Socket? _client;
  final List<Socket> _clients = [];
  final StreamController<ChatImageModel> _imageStreamController = StreamController.broadcast();

  Stream<ChatImageModel> get imageStream => _imageStreamController.stream;

  /// Inicia como servidor (host da reunião)
  Future<void> startServer(String userName) async {
    final address = InternetAddress.anyIPv4;
    _server = await ServerSocket.bind(address, 8080);
    _server!.listen((Socket socket) {
      _clients.add(socket);
      socket.listen(
            (data) {
          final decoded = utf8.decode(data);
          final Map<String, dynamic> json = jsonDecode(decoded);
          final image = ChatImageModel.fromJson(json);
          _imageStreamController.add(image);
          _broadcastImage(image, exclude: socket);
        },
        onDone: () => _clients.remove(socket),
        onError: (_) => _clients.remove(socket),
      );
    });
  }

  /// Inicia como cliente e conecta ao servidor
  Future<void> connectToServer(String serverIp) async {
    _client = await Socket.connect(serverIp, 8080);
    _client!.listen(
          (data) {
        final decoded = utf8.decode(data);
        final Map<String, dynamic> json = jsonDecode(decoded);
        final image = ChatImageModel.fromJson(json);
        _imageStreamController.add(image);
      },
      onDone: () => _client = null,
      onError: (_) => _client = null,
    );
  }

  /// Envia imagem para os demais conectados
  Future<void> sendImage(ChatImageModel imageModel) async {
    final jsonStr = jsonEncode(imageModel.toJson());

    if (_server != null) {
      // servidor envia para todos os clientes
      for (final client in _clients) {
        client.add(utf8.encode(jsonStr));
      }
    } else if (_client != null) {
      // cliente envia para servidor
      _client!.add(utf8.encode(jsonStr));
    }
  }

  /// Servidor transmite imagem recebida para os outros clientes
  void _broadcastImage(ChatImageModel image, {Socket? exclude}) {
    final jsonStr = jsonEncode(image.toJson());
    for (final client in _clients) {
      if (client != exclude) {
        client.add(utf8.encode(jsonStr));
      }
    }
  }

  void stop() async {
    for (final client in _clients) {
      await client.close();
    }
    _clients.clear();
    await _server?.close();
    await _client?.close();
    _server = null;
    _client = null;
  }

  void dispose() {
    _imageStreamController.close();
  }
}



