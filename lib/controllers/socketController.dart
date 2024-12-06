import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketController extends GetxController {
  late IO.Socket socket;

  @override
  void onInit() {
    super.onInit();
    _initializeSocket();
  }

  void _initializeSocket() {
    if (Get.isRegistered<IO.Socket>()) {
      socket = Get.find<IO.Socket>();
    } else {
      socket = IO.io(
        'http://localhost:3000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .build(),
      );
      Get.put(socket);
    }

    if (!socket.connected) {
      socket.connect();
    }

    socket.onConnect((_) {
      print('Conectado al servidor WebSocket');
    });

    socket.onDisconnect((_) {
      print('Desconectado del servidor WebSocket');
    });

    socket.onError((error) {
      print('Error en el socket: $error');
    });
  }

  void joinChat(String senderId, String receiverId) {
    socket.emit('join-chat', {'senderId': senderId, 'receiverId': receiverId});
  }

  void sendMessage(String senderId, String receiverId, String messageContent) {
    socket.emit('private-message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'messageContent': messageContent,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
