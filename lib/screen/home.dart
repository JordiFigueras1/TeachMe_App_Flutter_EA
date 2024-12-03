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
          IconButton(
            icon: const Icon(Icons.brightness_6), // Icono de modo nocturno/diurno
            onPressed: () {
              themeController.toggleTheme(); // Alterna el tema
            },
          ),
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
        child: const Text('Bienvenido a HomePage'),
      ),
    );
  }
}
