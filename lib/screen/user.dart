import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user.dart';
import '../controllers/userListController.dart';
import '../controllers/asignaturaController.dart';
import '../Widgets/userCard.dart';
import '../Widgets/asignaturaCard.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  final UserListController userController = Get.put(UserListController());
  final AsignaturaController asignaturaController = Get.put(AsignaturaController());

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
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 83, 98, 186),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Listado de usuarios (lado izquierdo)
            Expanded(
              child: Obx(() {
                if (userController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userController.userList.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay usuarios disponibles",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
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
            const SizedBox(width: 20),
            // Lista de asignaturas del usuario logueado (lado derecho)
            Expanded(
              flex: 2,
              child: Obx(() {
                if (asignaturaController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (asignaturaController.asignaturas.isEmpty) {
                  return const Center(
                    child: Text(
                      "No tienes asignaturas asignadas",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mis Asignaturas',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/addAsignatura', arguments: {'userId': userId}),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Asignatura'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
