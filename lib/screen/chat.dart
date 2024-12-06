import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';
import '../controllers/socketController.dart';

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
  final List<Map<String, String>> messages = [];

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
      );

      setState(() {
        messages.add({
          'senderId': authController.getUserId,
          'messageContent': messageContent,
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
                    child: Text(
                      message['messageContent'] ?? '',
                      style: const TextStyle(color: Colors.black),
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
