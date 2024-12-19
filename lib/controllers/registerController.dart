import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../models/userModel.dart';
import '../services/user.dart';

class RegisterController extends GetxController {
  final UserService userService = Get.put(UserService());
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController(); // Nuevo controlador
  final mailController = TextEditingController();
  final ageController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void signUp() async {
    if (nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty || // Nueva validación
        mailController.text.isEmpty ||
        ageController.text.isEmpty) {
      errorMessage.value = 'Todos los campos son obligatorios';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'Las contraseñas no coinciden';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!GetUtils.isEmail(mailController.text)) {
      errorMessage.value = 'Correo electrónico no válido';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    try {
      UserModel newUser = UserModel(
        id: '0', // ID temporal; esto debería actualizarse con el ID real tras la creación
        name: nameController.text,
        password: passwordController.text,
        mail: mailController.text,
        age: int.parse(ageController.text),
        isProfesor: false,
        isAlumno: false,
        isAdmin: true,
      );
      final response = await userService.createUser(newUser);

      if (response == 201 || response == 204) {
        Get.snackbar('Éxito', 'Usuario registrado correctamente',
            snackPosition: SnackPosition.BOTTOM);
        Get.toNamed('/login');
      } else if (response == 400) {
        errorMessage.value = 'Datos inválidos. Revisa los campos.';
        Get.snackbar('Error', errorMessage.value,
            snackPosition: SnackPosition.BOTTOM);
      } else if (response == 500) {
        errorMessage.value =
            'Error interno del servidor. Inténtalo más tarde.';
        Get.snackbar('Error', errorMessage.value,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        errorMessage.value = 'Ocurrió un error desconocido.';
        Get.snackbar('Error', errorMessage.value,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Error en signUp: $e");
      errorMessage.value = 'No se pudo conectar con el servidor.';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
  try {
    isLoading.value = true;
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      isLoading.value = false;
      return; // El usuario canceló el inicio de sesión
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    UserModel newUser = UserModel(
      id: googleUser.id,  // Utiliza el id de Google para registrar al usuario
      name: googleUser.displayName ?? 'Usuario de Google',
      mail: googleUser.email,
      password: '', // Deja vacío o no lo uses
      age: 18,  // Asigna un valor predeterminado si no se obtiene de Google
      isProfesor: false,
      isAlumno: false,
      isAdmin: true,
    );

    final response = await userService.createUser(newUser);

    if (response == 201 || response == 204) {
      Get.snackbar('Éxito', 'Usuario registrado correctamente con Google',
          snackPosition: SnackPosition.BOTTOM);
      Get.toNamed('/login');
    } else {
      throw Exception('Error al registrar con Google');
    }
  } catch (e) {
    errorMessage.value = 'Error al iniciar sesión con Google.';
    Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoading.value = false;
  }
}
}
