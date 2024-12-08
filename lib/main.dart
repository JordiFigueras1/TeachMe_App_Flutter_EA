import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/bottomNavigationBar.dart';
import '../screen/logIn.dart';
import '../screen/register.dart';
import '../screen/user.dart';
import '../screen/home.dart';
import '../controllers/authController.dart';
import '../screen/perfil.dart';
import '../controllers/userListController.dart';
import '../controllers/userModelController.dart';
import '../controllers/connectedUsersController.dart';
import '../screen/chat.dart';
import 'controllers/socketController.dart';
import '../controllers/theme_controller.dart'; // Importa el controlador del tema
import '../screen/mapPage.dart';

void main() {
  Get.put(AuthController());
  Get.put<UserListController>(UserListController());
  Get.put<UserModelController>(UserModelController());
  Get.put(ConnectedUsersController());
  Get.put(SocketController());
  Get.put(ThemeController()); // Registrar el controlador del tema

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find(); // Obtiene el controlador del tema

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login', // Establece la ruta inicial
        theme: ThemeData.light(), // Tema claro
        darkTheme: ThemeData.dark(), // Tema oscuro
        themeMode: themeController.themeMode.value, // Controlador del tema reactivo
        getPages: [
          GetPage(
            name: '/login',
            page: () => LogInPage(),
          ),
          GetPage(
            name: '/register',
            page: () => RegisterPage(),
          ),
          GetPage(
            name: '/home',
            page: () => BottomNavScaffold(child: HomePage()),
          ),
          GetPage(
            name: '/usuarios',
            page: () => BottomNavScaffold(
              child: UserPage(),
            ),
          ),
          GetPage(
            name: '/perfil',
            page: () => PerfilPage(),
          ),
          GetPage(
            name: '/chat',
            page: () => ChatPage(
              receiverId: Get.arguments['receiverId'],
              receiverName: Get.arguments['receiverName'],
            ),
          ),
          GetPage(
            name: '/map',
            page: () => MapPage(),
          ),
        ],
      );
    });
  }
}
