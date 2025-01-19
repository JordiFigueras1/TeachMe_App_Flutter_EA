import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../controllers/authController.dart';
import '../services/notificacionService.dart'; // Importa el servicio de notificaciones

class SocketController extends GetxController {
  late IO.Socket socket;
  final AuthController authController = Get.find<AuthController>();
  final NotificacionService notificacionService = NotificacionService();

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
            .disableAutoConnect() // No conectar automáticamente
            .setExtraHeaders({'auth-token': authController.getToken}) // Añade el token en las cabeceras
            .build(),
      );
      Get.put(socket);
    }
  }

  void connectSocket(String userId) {
    if (!socket.connected) {
      socket.connect();
    }

    socket.onConnect((_) {
      print('Conectado al servidor WebSocket');
      if (userId.isNotEmpty) {
        socket.emit('user-connected', {
          'userId': userId,
          'auth-token': authController.getToken,
        });
      }
    });

    // Listeners para mensajes privados
    socket.on('private-message', (data) {
      _handlePrivateMessage(data);
    });

    // Listeners para el chat general
    socket.on('message-general-chat', (data) {
      _handleGeneralMessage(data);
    });

    socket.on('update-user-status', (data) {
      print('Actualización del estado de usuarios: $data');
    });

    socket.onDisconnect((_) {
      print('Desconectado del servidor WebSocket');
    });

    socket.onError((error) {
      print('Error en el socket: $error');
    });
  }

  // Manejar mensajes privados
  void _handlePrivateMessage(Map<String, dynamic> data) {
    if (data == null) {
      print('Evento private-message recibido sin datos válidos.');
      return;
    }

    print('Mensaje privado recibido: $data');

    final senderId = data['senderId'] ?? '';
    final receiverId = data['receiverId'] ?? '';
    final senderName = data['senderName'] ?? 'Desconocido';
    final messageContent = data['messageContent'] ?? 'Sin contenido';

    if (receiverId == authController.getUserId) {
      print('Mensaje recibido por el usuario actual de $senderName');
    } else {
      print('Mensaje no destinado a este usuario.');
    }
  }

  // Manejar mensajes del chat general
  void _handleGeneralMessage(Map<String, dynamic> data) {
    if (data == null) {
      print('Evento message-general-chat recibido sin datos válidos.');
      return;
    }

    print('Mensaje del chat general recibido: $data');
  }

  // Unirse al chat de pares
  void joinChat(String senderId, String receiverId) {
    socket.emit('join-chat', {
      'senderId': senderId,
      'receiverId': receiverId,
      'auth-token': authController.getToken,
    });
  }

  // Unirse al chat general
  void joinGeneralChat(String userId) {
    if (userId.isNotEmpty) {
      socket.emit('join-general-chat', {'userId': userId});
      print('Usuario $userId se unió al chat general');
    }
  }

  // Salir del chat general
  void leaveGeneralChat(String userId) {
    if (userId.isNotEmpty) {
      socket.emit('leave-general-chat', {'userId': userId});
      print('Usuario $userId salió del chat general');
    }
  }

  // Enviar mensaje en el chat general
  void sendMessageToGeneralChat(String senderId, String messageContent) {
    if (senderId.isNotEmpty && messageContent.isNotEmpty) {
      socket.emit('message-general-chat', {
        'senderId': senderId,
        'messageContent': messageContent,
      });
      print('Mensaje enviado al chat general: $messageContent');
    }
  }

  // Enviar mensaje privado
  void sendMessage(String senderId, String receiverId, String messageContent, String senderName) {
    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'messageContent': messageContent,
      'senderName': senderName,
      'timestamp': DateTime.now().toIso8601String(),
      'auth-token': authController.getToken, // Enviar token al enviar mensajes
    };

    // Emitir mensaje al servidor
    socket.emit('private-message', messageData);
    print('Mensaje enviado: $messageContent de $senderName a $receiverId');

    // Crear notificación para el receptor del mensaje
    notificacionService.crearNotificacion(
      receiverId,
      'Has recibido un nuevo mensaje.',
    ).then((_) {
      print('Notificación creada para el usuario $receiverId');
    }).catchError((error) {
      print('Error al crear notificación: $error');
    });
  }

  // Desconectar usuario
  void disconnectUser(String userId) {
    if (userId.isNotEmpty) {
      socket.emit('user-disconnected', {
        'userId': userId,
        'auth-token': authController.getToken,
      });
      socket.clearListeners(); // Limpia todos los eventos asociados
      socket.disconnect();
      print('Usuario desconectado manualmente.');
    }
  }

  void clearListeners() {
    socket.clearListeners();
    print('Se han eliminado todos los listeners del socket.');
  }
}
