import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user.dart';
import '../controllers/authController.dart';
import '../controllers/userModelController.dart';

class UserController extends GetxController {
  final UserService userService = Get.put(UserService());
  final UserModelController userModelController = Get.find<UserModelController>();

  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> logIn() async {
    if (mailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Todos los campos son obligatorios',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!GetUtils.isEmail(mailController.text)) {
      Get.snackbar('Error', 'Correo electrónico no válido',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    try {
      final response = await userService.logIn({
        'email': mailController.text,
        'password': passwordController.text,
      });

      if (response.statusCode == 200) {
        final userId = response.data['usuario']['id'];
        final token = response.data['token'];

        // Almacenar userId y token en el AuthController
        final authController = Get.find<AuthController>();
        authController.setUserId(userId);
        authController.setToken(token);

        // Llamar a `setUser` en `UserModelController`

        userModelController.setUser(
        response.data['usuario']['id'] ?? '0', // Asegurar que 'id' tenga un valor por defecto
        response.data['usuario']['nombre'] ?? 'Desconocido',
        response.data['usuario']['email'] ?? 'No especificado',
        '', // No enviar la contraseña
        response.data['usuario']['edad'] ?? 0, // Valor predeterminado
        response.data['usuario']['isProfesor'] ?? false,
        response.data['usuario']['isAlumno'] ?? false,
        response.data['usuario']['isAdmin'] ?? false,
        true, // Establecer 'conectado' como 'true'
      );
        // Navegar al Home
        Get.offNamed('/home', arguments: {'userId': userId});
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Credenciales incorrectas';
        Get.snackbar('Error', errorMessage.value,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage.value = 'Error al conectar con el servidor: $e';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
