import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/userListController.dart';
import '../controllers/authController.dart';
import '../controllers/connectedUsersController.dart';
import '../controllers/socketController.dart';
import '../screen/chat.dart';
import '../controllers/theme_controller.dart'; // Asegúrate de tener el controlador de tema

class PerfilPage extends StatelessWidget {
  final SocketController socketController = Get.find<SocketController>();
  final ThemeController themeController = Get.find<ThemeController>(); // Controlador de tema

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserListController>();
    final authController = Get.find<AuthController>();
    final connectedUsersController = Get.find<ConnectedUsersController>();
    final TextEditingController searchController = TextEditingController();

    // Verificar si el tema es oscuro
    final isDarkMode = themeController.themeMode.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Usuarios'),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue, // Cambiar el color de la AppBar según el tema
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeController.toggleTheme(); // Alternar entre modo oscuro y claro
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Nombre del Usuario',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black, // Cambiar color de la etiqueta
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.blue), // Color del borde al enfocar
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Color del texto
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
                  final isConnected = connectedUsersController.connectedUsers.contains(user.id);

                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black, // Color del texto según el tema
                      ),
                    ),
                    subtitle: Text(
                      user.mail,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87, // Color de subtítulo según el tema
                      ),
                    ),
                    onTap: () {
                      Get.to(() => ChatPage(
                            receiverId: user.id,
                            receiverName: user.name,
                          ));
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
