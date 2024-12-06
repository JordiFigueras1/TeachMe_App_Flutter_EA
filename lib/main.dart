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

void main() {
  Get.put(AuthController());
  Get.put<UserListController>(UserListController()); // Registrar el controlador
  Get.put<UserModelController>(UserModelController()); // Registrar el controlador
  Get.put<ConnectedUsersController>(ConnectedUsersController());
  Get.put(SocketController());
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
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
      ],
    );
  }
}
