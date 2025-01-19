import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';
import '../controllers/socketController.dart';
import '../controllers/connectedUsersController.dart';
import '../controllers/theme_controller.dart';
import '../controllers/userModelController.dart';
import '../screen/notificaciones.dart'; // Asegúrate de que esta ruta sea la correcta

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
  final ThemeController themeController = Get.find<ThemeController>();
  final UserModelController userModelController = Get.find<UserModelController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);

    // Conectar el socket si hay un usuario logueado
    if (authController.getUserId.isNotEmpty) {
      socketController.connectSocket(authController.getUserId);

      // Escuchar actualizaciones del estado de usuarios
      socketController.socket.on('update-user-status', (data) {
        print('Actualización del estado de usuarios: $data');
        connectedUsersController.updateConnectedUsers(List<String>.from(data));
      });
    }
  }

  void _logout() {
    if (authController.getUserId.isNotEmpty) {
      // Emitir desconexión al backend
      socketController.disconnectUser(authController.getUserId);

      // Limpiar el estado del usuario en AuthController
      authController.setUserId('');
      authController.setToken('');
      connectedUsersController.updateConnectedUsers([]);
    }

    // Navegar al login
    Get.offAllNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.iconTheme.color,
            ),
            onPressed: themeController.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.notifications), // Ícono de notificaciones
            onPressed: () {
              Get.to(() => NotificacionesPage(userId: userModelController.user.value.id));
            },
            tooltip: 'Ver notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.person_search), // Ícono de búsqueda de perfiles
            onPressed: () {
              Get.toNamed('/perfil');
            },
            tooltip: 'Buscar perfiles',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
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
                child: Icon(
                  Icons.favorite,
                  color: theme.primaryColor.withOpacity(
                      themeController.themeMode.value == ThemeMode.dark ? 0.9 : 0.7),
                  size: 80,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Lista de usuarios conectados
          Expanded(
            child: Obx(() {
              if (connectedUsersController.connectedUsers.isEmpty) {
                return Center(
                  child: Text(
                    'No hay usuarios conectados.',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                itemCount: connectedUsersController.connectedUsers.length,
                itemBuilder: (context, index) {
                  final userId = connectedUsersController.connectedUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Hero(
                        tag: 'user-avatar-$userId', // Asignar un tag único a cada usuario
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondary,
                          child: Icon(
                            Icons.person,
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ),
                      title: Text(
                        'ID: $userId',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Estado: Conectado',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón para programar clases visible para todos
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Separación del botón de mapa
            child: FloatingActionButton(
              heroTag: 'programar-clase', // Hero tag único
              onPressed: () => Get.toNamed('/programar_clase'),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
              tooltip: 'Programar Clase',
            ),
          ),
          // Botón para ver el mapa
          FloatingActionButton(
            heroTag: 'ver-mapa', // Hero tag único
            onPressed: () => Get.toNamed('/map'),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.map),
            tooltip: 'Ver Mapa',
          ),
          const SizedBox(height: 8),
          // Botón para el chat general
          FloatingActionButton(
            heroTag: 'chat-general', // Hero tag único para el chat general
            onPressed: () => Get.toNamed('/chat-general'),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.chat),
            tooltip: 'Chat General',
          ),
        ],
      ),
    );
  }
}
