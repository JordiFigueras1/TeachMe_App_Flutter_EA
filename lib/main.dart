import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/bottomNavigationBar.dart';
import '../screen/logIn.dart';
import '../screen/register.dart';
import '../screen/user.dart';
import '../screen/home.dart';
import '../services/webSocketService.dart';
import '../controllers/authController.dart';

void main() {
  Get.put(AuthController());
  Get.put(WebSocketService());
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
      ],
    );
  }
}
