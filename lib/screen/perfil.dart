import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/userModelController.dart';
import '../controllers/userListController.dart';
import '../controllers/authController.dart';
import '../services/webSocketService.dart';

class PerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserListController>();
    final authController = Get.find<AuthController>();
    final webSocketService = Get.find<WebSocketService>(); // Usa el mismo servicio global

    final TextEditingController searchController = TextEditingController();

    // Conectar al WebSocket
    webSocketService.connect(authController.getUserId, authController.getToken);

    // Escuchar eventos de usuarios conectados
    webSocketService.listenToConnectedUsers((connectedUsers) {
      userController.handleWebSocketUpdates(connectedUsers);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Buscar Usuarios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Nombre del Usuario',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  userController.searchUsers(value, authController.getToken);
                }
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (userController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (userController.searchResults.isEmpty) {
                return Center(child: Text('No se encontraron usuarios.'));
              }

              return ListView.builder(
                itemCount: userController.searchResults.length,
                itemBuilder: (context, index) {
                  final user = userController.searchResults[index];
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: user.conectado ? Colors.green : Colors.grey,
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.mail),
                    onTap: () {
                      // Acción al seleccionar un usuario
                      print('Usuario seleccionado: ${user.name}');
                    },
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
