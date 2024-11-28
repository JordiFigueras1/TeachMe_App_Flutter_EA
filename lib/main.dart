import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/bottomNavigationBar.dart';
import 'package:flutter_application_1/screen/logIn.dart';
import 'package:flutter_application_1/screen/register.dart';
import 'package:flutter_application_1/screen/home.dart';
import 'package:flutter_application_1/screen/user.dart';
import 'package:flutter_application_1/screen/experiencies.dart';
import 'package:flutter_application_1/screen/perfil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App Educativa', // Nombre de la aplicación
      theme: AppTheme.lightTheme, // Tema global definido en app_theme.dart
      initialRoute: '/login', // Ruta inicial de la aplicación
      getPages: _getPages(), // Función para registrar las rutas
    );
  }

  // Función que retorna las rutas de la aplicación
  List<GetPage<dynamic>> _getPages() {
    return [
      GetPage(name: '/login', page: () => LogInPage()),
      GetPage(name: '/register', page: () => RegisterPage()),
      GetPage(name: '/home', page: () => BottomNavScaffold(child: HomePage())),
      GetPage(name: '/usuarios', page: () => BottomNavScaffold(child: UserPage())),
      GetPage(name: '/experiencies', page: () => BottomNavScaffold(child: ExperienciesPage())),
      GetPage(name: '/perfil', page: () => BottomNavScaffold(child: PerfilPage())),
    ];
  }
}
