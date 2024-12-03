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
        title: Text('Iniciar Sesión'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userController.mailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: userController.passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Obx(() {
              if (userController.isLoading.value) {
                return CircularProgressIndicator();
              } else {
                return ElevatedButton(
                  onPressed: () {
                    userController.logIn();
                  },
                  child: Text('Iniciar Sesión'),
                );
              }
            }),
            Obx(() {
              if (userController.errorMessage.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    userController.errorMessage.value,
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return Container();
              }
            }),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
