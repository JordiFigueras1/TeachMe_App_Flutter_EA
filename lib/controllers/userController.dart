import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user.dart';
import '../controllers/authController.dart';


class UserController extends GetxController {
  final UserService userService = Get.put(UserService());

  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

Future<void> logIn() async {
  if (mailController.text.isEmpty || passwordController.text.isEmpty) {
    Get.snackbar('Error', 'Todos los campos son obligatorios', snackPosition: SnackPosition.BOTTOM);
    return;
  }

  if (!GetUtils.isEmail(mailController.text)) {
    Get.snackbar('Error', 'Correo electrónico no válido', snackPosition: SnackPosition.BOTTOM);
    return;
  }

  isLoading.value = true;

  try {
    final response = await userService.logIn({
      'email': mailController.text,
      'password': passwordController.text,
    });

    if (response.statusCode == 200) {
      // Extraer el `_id` del usuario desde la respuesta
      final userId = response.data['usuario']['_id']; // Aquí accedes al `_id`

      // Configurar el `userId` globalmente
      Get.find<AuthController>().setUserId(userId);

      // Redirigir al home y pasar el `userId` como argumento
      Get.offNamed('/home', arguments: {'userId': userId});
    } else {
      errorMessage.value = response.data['message'] ?? 'Credenciales incorrectas';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    }
  } catch (e) {
    errorMessage.value = 'Error al conectar con el servidor: $e';
    Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoading.value = false;
  }
}
}
