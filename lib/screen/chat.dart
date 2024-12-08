import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';
import '../controllers/socketController.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatPage({Key? key, required this.receiverId, required this.receiverName}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = []; // Cambiar el tipo para incluir el timestamp

  @override
  void initState() {
    super.initState();
    _joinChat();
    _listenForMessages();
  }

  void _joinChat() {
    socketController.joinChat(authController.getUserId, widget.receiverId);
  }

  void _listenForMessages() {
    socketController.clearListeners('receive-message'); // Limpiar listeners previos
    socketController.socket.on('receive-message', (data) {
      if (data['receiverId'] == authController.getUserId) {
        setState(() {
          messages.add({
            'senderId': data['senderId'] ?? '',
            'messageContent': data['messageContent'] ?? '',
            'timestamp': DateTime.parse(data['timestamp']) ?? DateTime.now(), // Convertir timestamp a DateTime
          });
        });
      }
    });
  }

  void _sendMessage() {
  final messageContent = messageController.text.trim();
  if (messageContent.isNotEmpty) {
    socketController.sendMessage(
      authController.getUserId,
      widget.receiverId,
      messageContent,
      authController.getUserName, // Enviar también el nombre del usuario
    );

    setState(() {
      messages.add({
        'senderName': authController.getUserName, // Guardar el nombre del usuario
        'messageContent': messageContent,
        'timestamp': DateTime.now(),
      });
    });

    messageController.clear();
  }
}

  @override
  void dispose() {
    socketController.socket.emit('leave-chat', {
      'senderId': authController.getUserId,
      'receiverId': widget.receiverId,
    });
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp); // Formatear la fecha
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con ${widget.receiverName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['senderId'] == authController.getUserId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${message['senderName']} - ${_formatTimestamp(message['timestamp'])}', // Mostrar autor y fecha
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          message['messageContent'] ?? '',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
