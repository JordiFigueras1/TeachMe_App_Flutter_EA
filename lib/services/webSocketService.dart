import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  late WebSocketChannel channel;
  bool isConnected = false;
  late Stream<dynamic> _stream;

  void connect(String userId, String token) {
    if (isConnected) return;

  channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:3000?auth-token=$token'),
  );


    isConnected = true;

    // Emitir evento para informar al servidor que este usuario está conectado
    channel.sink.add(jsonEncode({
      "event": "user-connected",
      "data": {"userId": userId}
    }));

    // Convertir el stream en broadcast para permitir múltiples listeners
    _stream = channel.stream.asBroadcastStream();

    _stream.listen(
      (message) {
        print('Mensaje del WebSocket: $message');
      },
      onDone: () {
        print('WebSocket desconectado.');
        isConnected = false;
      },
      onError: (error) {
        print('Error en WebSocket: $error');
        isConnected = false;
      },
    );
  }

  void reconnect(String userId, String token) {
    if (!isConnected) {
      connect(userId, token);
    }
  }

  void disconnect(String userId) {
    if (isConnected) {
      channel.sink.add(jsonEncode({
        "event": "user-disconnected",
        "data": {"userId": userId}
      }));
      channel.sink.close();
    }
    isConnected = false;
  }

  Stream<dynamic> get stream {
    if (!_stream.isBroadcast) {
      throw Exception("WebSocket no está conectado o el stream no está configurado.");
    }
    return _stream;
  }

  void listenToConnectedUsers(Function(List<String>) onUpdate) {
    if (!_stream.isBroadcast) {
      throw Exception("WebSocket no está conectado o el stream no está configurado.");
    }

    stream.listen((message) {
      try {
        final parsedMessage = jsonDecode(message);
        if (parsedMessage['event'] == 'update-user-status') {
          final users = List<String>.from(parsedMessage['data']);
          onUpdate(users);
        }
      } catch (e) {
        print('Error al procesar mensaje WebSocket: $e');
      }
    });
  }
}
