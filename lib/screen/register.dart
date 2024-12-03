import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registerController.dart';
import '../controllers/themeController.dart';

class RegisterPage extends StatelessWidget {
  final RegisterController registerController = Get.put(RegisterController());
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
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
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 26),
                TextField(
                  controller: registerController.nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: registerController.mailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                ),
                TextField(
                  controller: registerController.ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Edad'),
                ),
                TextField(
                  controller: registerController.passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                TextField(
                  controller: registerController.confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (registerController.isLoading.value) {
                    return const CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      onPressed: registerController.signUp,
                      child: const Text('Registrarse'),
                    );
                  }
                }),
                Obx(() {
                  if (registerController.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        registerController.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.toNamed('/login'),
                  child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
