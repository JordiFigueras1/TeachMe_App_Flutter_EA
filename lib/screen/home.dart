import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/themeController.dart';
import '../controllers/authController.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Botón para alternar entre temas
          IconButton(
            icon: Obx(() => Icon(
                  themeController.themeMode.value == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                )),
            onPressed: themeController.toggleTheme,
          ),
          // Botón para cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.setUserId(''); // Limpia el userId
              Get.offAllNamed('/login'); // Redirige al Login
            },
          ),
        ],
      ),
      body: Center(
        child: Obx(() {
          final userId = authController.userId.value;
          return Text(userId.isEmpty
              ? 'Bienvenido a HomePage'
              : 'Bienvenido, Usuario $userId');
        }),
      ),
    );
  }
}
