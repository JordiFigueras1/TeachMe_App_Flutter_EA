import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late IO.Socket socket; // Socket declarado como no-nullable

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

    _initializeSocket();
  }

  void _initializeSocket() {
    // Asegurarse de inicializar el socket solo si no está conectado
    if (Get.isRegistered<IO.Socket>()) {
      socket = Get.find<IO.Socket>();
    } else {
      socket = IO.io(
        'http://localhost:3000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // Usar solo transporte WebSocket
            .build(),
      );
      Get.put(socket); // Registrar el socket como global
    }

    socket.onConnect((_) {
      print('Conectado al servidor WebSocket');

      // Emitir que el usuario está conectado
      socket.emit('user-connected', {'userId': authController.getUserId});

      // Escuchar el evento 'user-connected' con la lista inicial de usuarios
      socket.on('user-connected', (data) {
        print('Usuarios conectados recibidos: $data');
        setState(() {
          connectedUsers = List<String>.from(data);
        });
      });

      // Escuchar actualizaciones del estado de usuarios
      socket.on('update-user-status', (data) {
        print('Actualización del estado de usuarios: $data');
        setState(() {
          connectedUsers = List<String>.from(data);
        });
      });
    });

    socket.onDisconnect((_) {
      print('Desconectado del servidor WebSocket');
    });

    socket.onError((error) {
      print('Error en el socket: $error');
    });
  }

  void _disconnectSocket() {
    if (socket.connected) {
      socket.emit('user-disconnected', {'userId': authController.getUserId});
      socket.disconnect();
      print('Usuario desconectado del WebSocket');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // No desconectar el socket aquí, para que persista entre pantallas
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
              // Desconectar el usuario del WebSocket
              _disconnectSocket();

              // Limpiar el estado del usuario
              authController.setUserId('');
              connectedUsers.clear();

              // Navegar al login
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
