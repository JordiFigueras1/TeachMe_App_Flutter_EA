import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/userController.dart';
import '../controllers/authController.dart';
import '../controllers/themeController.dart';

class LogInPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userController.mailController,
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: userController.passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (userController.isLoading.value) {
                return const CircularProgressIndicator();
              } else {
                return ElevatedButton(
                  onPressed: userController.logIn,
                  child: const Text('Iniciar Sesión'),
                );
              }
            }),
            Obx(() {
              if (userController.errorMessage.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    userController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return Container();
              }
            }),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
