import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'controllers/authController.dart';
import 'controllers/userListController.dart';
import 'controllers/userModelController.dart';
import 'controllers/connectedUsersController.dart';
import 'controllers/socketController.dart';
import 'controllers/theme_controller.dart';
import 'controllers/localeController.dart'; 
import 'screen/logIn.dart';
import 'screen/register.dart';
import 'screen/user.dart';
import 'screen/home.dart';
import 'screen/perfil.dart';
import 'screen/chat.dart';
import 'screen/mapPage.dart';
import 'Widgets/bottomNavigationBar.dart';
import 'l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 

void main() async {
  // Inicializar Firebase
//  WidgetsFlutterBinding.ensureInitialized();
//  await Firebase.initializeApp();

  // Inicializa los controladores
  Get.put(AuthController());
  Get.put<UserListController>(UserListController());
  Get.put<UserModelController>(UserModelController());
  Get.put(ConnectedUsersController());
  Get.put(SocketController());
  Get.put(ThemeController());
  Get.put(LocaleController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    final LocaleController localeController = Get.find();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login', // Página de inicio
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
        themeMode: themeController.themeMode.value,
        getPages: [
          GetPage(name: '/login', page: () => LogInPage()),
          GetPage(name: '/register', page: () => RegisterPage()),
          GetPage(name: '/home', page: () => BottomNavScaffold(child: HomePage())),
          GetPage(name: '/usuarios', page: () => BottomNavScaffold(child: UserPage())),
          GetPage(name: '/perfil', page: () => PerfilPage()),
          GetPage(name: '/chat', page: () => ChatPage(
            receiverId: Get.arguments['receiverId'],
            receiverName: Get.arguments['receiverName'],
          )),
          GetPage(name: '/map', page: () => MapPage()),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('es', ''),
        ],
        locale: localeController.currentLocale.value,
      );
    });
  }
}
