import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';
import '../services/webSocketService.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final WebSocketService webSocketService = Get.find<WebSocketService>();
  final AuthController authController = Get.find<AuthController>();
  List<String> connectedUsers = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller);

    // Escuchar usuarios conectados
    webSocketService.listenToConnectedUsers((users) {
      setState(() {
        connectedUsers = users;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              webSocketService.disconnect(authController.getUserId);
              authController.setUserId('');
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animación
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 100,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Lista de usuarios conectados
          Expanded(
            child: connectedUsers.isEmpty
                ? const Center(child: Text('No hay usuarios conectados.'))
                : ListView.builder(
                    itemCount: connectedUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.green),
                        title: Text('Usuario ID: ${connectedUsers[index]}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
