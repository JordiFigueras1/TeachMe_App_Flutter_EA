import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/themeController.dart';
import 'controllers/authController.dart';
import 'screen/logIn.dart';
import 'screen/register.dart';
import 'screen/home.dart';
import 'screen/user.dart';

void main() {
  Get.put(ThemeController()); // Registra el controlador de tema
  Get.put(AuthController()); // Registra el controlador de autenticación
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(), // Tema claro
        darkTheme: ThemeData.dark(), // Tema oscuro
        themeMode: themeController.themeMode.value, // Escucha los cambios del controlador
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/login', page: () => LogInPage()),
          GetPage(name: '/register', page: () => RegisterPage()),
          GetPage(name: '/home', page: () => HomePage()),
          GetPage(name: '/usuarios', page: () => UserPage()),
        ],
      );
    });
  }
}
