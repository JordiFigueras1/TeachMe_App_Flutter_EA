import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/localeController.dart'; // Importa el controlador
import 'l10n.dart'; // Importa el archivo de localización
import 'screen/asignaturas.dart';
import 'screen/chat.dart';
import 'screen/home.dart';
import 'screen/logIn.dart';
import 'screen/mapPage.dart';
import 'screen/perfil.dart';
import 'screen/register.dart';
import 'screen/user.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

 

void main() {
  Get.put(LocaleController());  // Registrar el controlador de idioma
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LocaleController localeController = Get.find();  // Obtener el controlador de idioma

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        localizationsDelegates: [
          AppLocalizations.delegate, // Delegado de traducciones
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),  // Inglés
          const Locale('es', ''),  // Español
        ],
        locale: localeController.currentLocale.value,  // Asignar el idioma actual
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1C1C1E),
          scaffoldBackgroundColor: const Color(0xFF1C1C1E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2C2C2E),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        themeMode: ThemeMode.system,
        getPages: [
          GetPage(name: '/asignaturas', page: () => AsignaturasPage()),
          // Agrega tus rutas aquí
        ],
      );
    });
  }
}
