import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../controllers/authController.dart';
import '../models/messageModel.dart';

class SocketController extends GetxController {
  late IO.Socket socket;
  final AuthController authController = Get.find<AuthController>();

  // Lista reactiva de mensajes
  var messages = <MessageModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'auth-token': authController.getToken})
          .build(),
    );
    socket.connect();

    // Listeners para eventos de WebSocket
    socket.onConnect((_) {
      print('Conectado al servidor WebSocket');
      connectSocket(authController.getUserId);
    });
    socket.onDisconnect((_) => print('Desconectado del servidor WebSocket'));
    socket.onError((error) => print('Error en WebSocket: $error'));

    _listenForMessages();
    _listenForUserEvents();
  }

  void joinRoom(String roomId) {
    socket.emit('join-chat', {
      'roomId': roomId,
      'userId': authController.getUserId,
    });
    print('Intentando unirse a la sala: $roomId');
  }

  void leaveRoom(String roomId) {
    socket.emit('leave-chat', {
      'roomId': roomId,
      'userId': authController.getUserId,
    });
    print('Salió de la sala: $roomId');
  }

  void connectSocket(String userId) {
    socket.emit('user-connected', {'userId': userId});
    print('Usuario conectado: $userId');
  }

  void disconnectUser(String userId) {
    socket.emit('user-disconnected', {'userId': userId});
    print('Usuario desconectado: $userId');
  }

  void sendMessage(String roomId, String messageContent) {
    final message = MessageModel(
      senderId: authController.getUserId,
      senderName: authController.getUserName,
      roomId: roomId,
      messageContent: messageContent,
      timestamp: DateTime.now(),
    );

    socket.emit('room-message', message.toJson());
    print('Mensaje enviado: $messageContent');
    // No agregar el mensaje localmente aquí; será gestionado en `receive-message`.
  }

  void _listenForMessages() {
    socket.on('receive-message', (data) {
      final message = MessageModel.fromJson(data);

      // Prevenir duplicados: Solo agregar si no existe ya en la lista
      if (!messages.any((msg) =>
          msg.senderId == message.senderId &&
          msg.timestamp == message.timestamp &&
          msg.roomId == message.roomId)) {
        messages.add(message);
        print('Mensaje recibido: ${message.messageContent}');
      }
    });
  }

  void _listenForUserEvents() {
    socket.on('user-joined', (data) {
      print('Usuario se unió a la sala: ${data['userId']} en la sala ${data['roomId']}');
    });

    socket.on('user-left', (data) {
      print('Usuario salió de la sala: ${data['userId']} en la sala ${data['roomId']}');
    });
  }

  @override
  void onClose() {
    disconnectUser(authController.getUserId);
    socket.disconnect();
    super.onClose();
  }
}
