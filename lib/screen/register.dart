import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registerController.dart';
import '../controllers/theme_controller.dart'; // Asegúrate de tener el controlador de tema

class RegisterPage extends StatelessWidget {
  final RegisterController registerController = Get.put(RegisterController());
  final ThemeController themeController = Get.find<ThemeController>(); // Controlador de tema

  @override
  Widget build(BuildContext context) {
    // Verificar si el tema es oscuro
    final isDarkMode = themeController.themeMode.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue, // Cambiar color de la AppBar según el tema
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
                // Campos de texto con soporte para tema oscuro
                _buildTextField(
                  controller: registerController.nameController,
                  label: 'Nombre',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: registerController.mailController,
                  label: 'Correo electrónico',
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: registerController.ageController,
                  label: 'Edad',
                  isDarkMode: isDarkMode,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: registerController.passwordController,
                  label: 'Contraseña',
                  isDarkMode: isDarkMode,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: registerController.confirmPasswordController,
                  label: 'Confirmar contraseña',
                  isDarkMode: isDarkMode,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                // Botón de registro
                Obx(() {
                  if (registerController.isLoading.value) {
                    return const CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      onPressed: registerController.signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue, // Cambié 'primary' por 'backgroundColor'
                      ),
                      child: const Text('Registrarse'),
                    );
                  }
                }),
                // Mostrar mensaje de error si existe
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
                    return const SizedBox();
                  }
                }),
                const SizedBox(height: 16),
                // Botón de navegación a Login
                TextButton(
                  onPressed: () => Get.toNamed('/login'),
                  child: Text(
                    '¿Ya tienes una cuenta? Inicia sesión',
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.blue), // Color del texto
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función para crear campos de texto con soporte de tema
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isDarkMode = false,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Color de la etiqueta
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.blue),
        ),
        border: OutlineInputBorder(),
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Color del texto
    );
  }
}

