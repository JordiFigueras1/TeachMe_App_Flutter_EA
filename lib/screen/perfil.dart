import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/userListController.dart';
import '../controllers/authController.dart';
import '../controllers/connectedUsersController.dart';
import '../controllers/socketController.dart';
import '../screen/chat.dart';
import '../controllers/theme_controller.dart';

class PerfilPage extends StatelessWidget {
  final SocketController socketController = Get.find<SocketController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserListController>();
    final authController = Get.find<AuthController>();
    final connectedUsersController = Get.find<ConnectedUsersController>();
    final TextEditingController searchController = TextEditingController();
    final ThemeData theme = Theme.of(context);

    // ID de sala global
    const String globalRoomId = 'global-chat-room';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Buscar Usuarios'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
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
                labelStyle: theme.textTheme.bodyLarge,
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
                prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              ),
              style: theme.textTheme.bodyLarge,
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
                return const Center(child: CircularProgressIndicator());
              }

              if (userController.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    'No se encontraron usuarios.',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: userController.searchResults.length,
                itemBuilder: (context, index) {
                  final user = userController.searchResults[index];
                  final isConnected = connectedUsersController.connectedUsers.contains(user.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isConnected ? Colors.green : Colors.grey,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        user.mail,
                        style: theme.textTheme.bodyMedium,
                      ),
                      trailing: Icon(
                        Icons.chat,
                        color: theme.colorScheme.secondary, // Color dinámico según el tema
                      ),
                      onTap: () {
                        socketController.joinRoom(globalRoomId);
                        Get.to(() => ChatPage(
                              roomId: globalRoomId, // Usar roomId
                              roomName: 'Sala Global', // Usar roomName
                            ));
                      },
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
