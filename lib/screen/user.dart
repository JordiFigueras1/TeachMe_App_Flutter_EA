import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user.dart';
import '../controllers/userListController.dart';
import '../controllers/asignaturaController.dart';
import '../Widgets/userCard.dart';
import '../Widgets/asignaturaCard.dart';
import '../controllers/themeController.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  final UserListController userController = Get.put(UserListController());
  final AsignaturaController asignaturaController = Get.put(AsignaturaController());
  final ThemeController themeController = Get.find<ThemeController>();

  late String userId;

  @override
  void initState() {
    super.initState();
    userId = Get.arguments?['userId'] ?? '';

    if (userId.isNotEmpty) {
      asignaturaController.fetchAsignaturas(userId);
    } else {
      print("Error: No se proporcionó un userId válido");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: Obx(() => Icon(
                  themeController.themeMode.value == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                )),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                if (userController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else if (userController.userList.isEmpty) {
                  return Center(child: Text("No hay usuarios disponibles"));
                } else {
                  return ListView.builder(
                    itemCount: userController.userList.length,
                    itemBuilder: (context, index) {
                      return UserCard(user: userController.userList[index]);
                    },
                  );
                }
              }),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Obx(() {
                if (asignaturaController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else if (asignaturaController.asignaturas.isEmpty) {
                  return Center(child: Text("No tienes asignaturas asignadas"));
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis Asignaturas',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: asignaturaController.asignaturas.length,
                          itemBuilder: (context, index) {
                            return AsignaturaCard(
                              asignatura: asignaturaController.asignaturas[index],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
