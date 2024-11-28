import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user.dart';
import '../controllers/userListController.dart';
import '../controllers/asignaturaController.dart';
import '../Widgets/userCard.dart';
import '../Widgets/asignaturaCard.dart';
import '../models/asignaturaModel.dart';


class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  final UserListController userController = Get.put(UserListController());
  final AsignaturaController asignaturaController = Get.put(AsignaturaController());

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
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Usuarios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Listado de usuarios (lado izquierdo)
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
            // Lista de asignaturas del usuario logueado (lado derecho)
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
