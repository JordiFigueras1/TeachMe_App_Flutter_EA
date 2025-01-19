import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Para formatear timestamps
import '../controllers/socketController.dart';
import '../controllers/authController.dart';

class ChatGeneralPage extends StatefulWidget {
  const ChatGeneralPage({Key? key}) : super(key: key);

  @override
  _ChatGeneralPageState createState() => _ChatGeneralPageState();
}

class _ChatGeneralPageState extends State<ChatGeneralPage> {
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _joinGeneralChat();
    _listenForMessages();
  }

  void _joinGeneralChat() {
    socketController.joinGeneralChat(authController.getUserId);
  }

  void _listenForMessages() {
    socketController.socket.on('message-general-chat', (data) {
      final senderId = data['senderId'];
      // Evitar duplicar el mensaje si el emisor lo recibe de nuevo
      if (senderId != authController.getUserId) {
        setState(() {
          messages.add({
            'senderName': data['senderName'] ?? 'Anónimo',
            'messageContent': data['messageContent'] ?? '',
            'timestamp': DateTime.parse(data['timestamp']),
            'isMe': false, // Mensaje recibido
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _sendMessage() {
    final messageContent = messageController.text.trim();
    if (messageContent.isNotEmpty) {
      final timestamp = DateTime.now();
      socketController.sendMessageToGeneralChat(
        authController.getUserId,
        messageContent,
      );

      // Agregar el mensaje al estado local
      setState(() {
        messages.add({
          'senderName': 'Tú',
          'messageContent': messageContent,
          'timestamp': timestamp,
          'isMe': true, // Mensaje enviado por el emisor
        });
      });

      messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp); // Solo hora y minutos
  }

  @override
  void dispose() {
    socketController.leaveGeneralChat(authController.getUserId);
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat General'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['isMe'] ?? false;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? theme.primaryColor.withOpacity(0.8)
                          : theme.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            '${message['senderName']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        Text(
                          '${message['messageContent']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: isMe ? Colors.white70 : Colors.black54,
                          ),
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
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    backgroundColor: theme.primaryColor,
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
