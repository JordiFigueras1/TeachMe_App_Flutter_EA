import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';
import '../controllers/socketController.dart';
import '../controllers/connectedUsersController.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();
  final ConnectedUsersController connectedUsersController = Get.find<ConnectedUsersController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);

    if (authController.getUserId.isNotEmpty) {
      socketController.connectSocket(authController.getUserId);
      socketController.socket.on('update-user-status', (data) {
        connectedUsersController.updateConnectedUsers(List<String>.from(data));
      });
    }
  }

  void _logout() {
    if (authController.getUserId.isNotEmpty) {
      socketController.disconnectUser(authController.getUserId);
      authController.setUserId('');
      connectedUsersController.updateConnectedUsers([]);
    }
    Get.offAllNamed('/login');
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
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 83, 98, 186),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Get.toNamed('/perfil'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.pinkAccent,
                  size: 100,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Usuarios Conectados:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              if (connectedUsersController.connectedUsers.isEmpty) {
                return const Center(
                  child: Text('No hay usuarios conectados.', style: TextStyle(fontSize: 16)),
                );
              }
              return ListView.builder(
                itemCount: connectedUsersController.connectedUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: Text(
                      'Usuario ID: ${connectedUsersController.connectedUsers[index]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
