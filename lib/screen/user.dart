import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user.dart';
import '../controllers/userListController.dart';
import '../controllers/asignaturaController.dart';
import '../Widgets/userCard.dart';
import '../Widgets/asignaturaCard.dart';
import '../models/asignaturaModel.dart';
import '../controllers/theme_controller.dart'; // Asegúrate de tener este controlador

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  final UserListController userController = Get.put(UserListController());
  final AsignaturaController asignaturaController = Get.put(AsignaturaController());
  final ThemeController themeController = Get.find<ThemeController>(); // Controlador de tema

  late String userId; // ID del usuario logueado

  @override
  void initState() {
    super.initState();

    // Obtener el userId desde los argumentos pasados al navegar a esta pantalla
    userId = Get.arguments?['userId'] ?? '';

    if (userId.isNotEmpty) {
      // Llamar al método para obtener las asignaturas del usuario logueado
      asignaturaController.fetchAsignaturas(userId);
    } else {
      // Manejar el caso donde el userId no se proporcionó
      print("Error: No se proporcionó un userId válido");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si el tema es oscuro
    final isDarkMode = themeController.themeMode.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue, // Cambiar color de la AppBar según el tema
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
                  return const Center(child: Text("No hay usuarios disponibles"));
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
                  return const Center(child: Text("No tienes asignaturas asignadas"));
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis Asignaturas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black, // Cambiar color del texto
                        ),
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
    );
  }
}
