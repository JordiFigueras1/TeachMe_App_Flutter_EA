import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registerController.dart';
import '../controllers/theme_controller.dart';

class RegisterPage extends StatelessWidget {
  final RegisterController registerController = Get.put(RegisterController());
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Registrarse'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.textTheme.bodyLarge?.color,
            ),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: themeController.themeMode.value == ThemeMode.dark
                        ? [const Color(0xFF6366F1), const Color(0xFF3B82F6)]
                        : [Colors.blue, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.person_add,
                  size: 50,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: registerController.nameController,
              label: 'Nombre',
              icon: Icons.person,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: registerController.mailController,
              label: 'Correo Electrónico',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: registerController.ageController,
              label: 'Edad',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: registerController.passwordController,
              label: 'Contraseña',
              icon: Icons.lock,
              obscureText: true,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: registerController.confirmPasswordController,
              label: 'Confirmar Contraseña',
              icon: Icons.lock_outline,
              obscureText: true,
              theme: theme,
            ),
            const SizedBox(height: 24),

            Obx(() {
              if (registerController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                );
              } else {
                return ElevatedButton(
                  onPressed: registerController.signUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: theme.primaryColor,
                  ),
                  child: Text(
                    'Registrarse',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                );
              }
            }),
            const SizedBox(height: 16),

            Obx(() {
              if (registerController.errorMessage.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    registerController.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () => Get.toNamed('/login'),
                child: Text(
                  '¿Ya tienes una cuenta? Inicia sesión',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeController.themeMode.value == ThemeMode.dark
                        ? Colors.lightBlueAccent
                        : theme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.iconTheme.color),
        labelStyle: theme.textTheme.bodyMedium,
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }
}
