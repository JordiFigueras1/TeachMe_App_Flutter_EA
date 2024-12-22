import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/userService.dart';
import '../controllers/authController.dart';
import '../controllers/userModelController.dart';
import 'package:geolocator/geolocator.dart';

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

    isLoading.value = true;

    try {
      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Permisos de ubicación denegados permanentemente. Habilítelos en la configuración.');
      }

      // Obtener las coordenadas del dispositivo
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      print("Coordenadas obtenidas: (${position.latitude}, ${position.longitude})");

      final response = await userService.logIn({
        'identifier': mailController.text, // Correo o username
        'password': passwordController.text,
        'lat': position.latitude.toString(),
        'lng': position.longitude.toString(),
      });

      if (response.statusCode == 200) {
        final userData = response.data['usuario'] ?? {};
        final locationData = userData['location']?['coordinates'] ?? [0.0, 0.0];

        final userId = userData['id'] ?? '0';
        final token = response.data['token'] ?? '';

        // Validar que los datos críticos estén presentes
        if (userId == '0' || token.isEmpty) {
          throw Exception('Datos críticos faltantes en la respuesta del servidor.');
        }

        // Almacenar userId y token en el AuthController
        final authController = Get.find<AuthController>();
        authController.setUserId(userId);
        authController.setToken(token);

        // Verificar que el token se haya configurado correctamente
        if (authController.getToken.isEmpty) {
          throw Exception('El token devuelto por el servidor es nulo o vacío.');
        }
        print("Token configurado correctamente: ${authController.getToken}");

        // Llamar a `setUser` en `UserModelController` con argumentos nombrados
        userModelController.setUser(
          id: userId,
          name: userData['nombre'] ?? 'Desconocido',
          username: userData['username'] ?? 'No especificado',
          mail: userData['email'] ?? 'No especificado',
          password: '', // Nunca asignamos la contraseña desde el backend
          fechaNacimiento: userData['fechaNacimiento'] ?? 'Sin especificar',
          isProfesor: userData['isProfesor'] ?? false,
          isAlumno: userData['isAlumno'] ?? false,
          isAdmin: userData['isAdmin'] ?? false,
          conectado: true,
          lat: locationData.length > 1 ? locationData[1] : 0.0,
          lng: locationData.length > 0 ? locationData[0] : 0.0,
        );

        print("Datos asignados correctamente al modelo UserModel.");

        // Comprobar rol y redirigir
        checkRoleAndNavigate();
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

  void checkRoleAndNavigate() {
    final user = userModelController.user.value;

    // Agrega este print para verificar la ruta de navegación
    print('Redirigiendo a: ${!user.isProfesor && !user.isAlumno ? "/roleSelection" : "/home"}');

    if (!user.isProfesor && !user.isAlumno) {
      // Primer inicio de sesión: Redirigir a RoleSelectionPage
      Get.offAllNamed('/roleSelection');
    } else {
      // No es el primer inicio de sesión: Redirigir al Home
      Get.offAllNamed('/home');
    }
  }

  Future<void> assignRole(String role) async {
    try {
      final userId = Get.find<AuthController>().getUserId;
      final isProfesor = role == "profesor";
      final isAlumno = role == "alumno";

      // Llamada al servicio para actualizar el rol
      final response = await userService.updateRole(userId, isProfesor, isAlumno);

      if (response.statusCode == 200) {
        // Actualizar el modelo del usuario en el controlador
        userModelController.setUser(
          id: userModelController.user.value.id,
          name: userModelController.user.value.name,
          username: userModelController.user.value.username,
          mail: userModelController.user.value.mail,
          password: userModelController.user.value.password,
          fechaNacimiento: userModelController.user.value.fechaNacimiento,
          isProfesor: isProfesor,
          isAlumno: isAlumno,
          isAdmin: userModelController.user.value.isAdmin,
          conectado: true,
        );

        // Navegar al Home después de asignar el rol
        Get.offAllNamed('/home');
      } else {
        Get.snackbar("Error", "No se pudo asignar el rol. Inténtalo de nuevo.");
      }
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un problema: $e");
    }
  }
}
