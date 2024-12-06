import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/userListController.dart';
import '../controllers/authController.dart';
import '../controllers/connectedUsersController.dart';
import '../controllers/socketController.dart';
import '../screen/chat.dart';

class PerfilPage extends StatelessWidget {
  final SocketController socketController = Get.find<SocketController>();

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserListController>();
    final authController = Get.find<AuthController>();
    final connectedUsersController = Get.find<ConnectedUsersController>();
    final TextEditingController searchController = TextEditingController();

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
                  final isConnected = connectedUsersController.connectedUsers.contains(user.id);

                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.mail),
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
