import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/authController.dart';

class BottomNavScaffold extends StatelessWidget {
  final Widget child;
  static final RxInt selectedIndex = 0.obs;

  const BottomNavScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      return Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex.value,
          onTap: (index) {
            if (selectedIndex.value != index) {
              selectedIndex.value = index;

              switch (index) {
                case 0:
                  Get.offNamed('/home');
                  break;
                case 1:
                  Get.offNamed(
                    '/usuarios',
                    arguments: {'userId': authController.userId.value},
                  );
                  break;
              }
            }
          },
          selectedItemColor: const Color(0xFF5C0E69),
          unselectedItemColor: Colors.black54,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Usuarios',
            ),
          ],
        ),
      );
    });
  }
}
