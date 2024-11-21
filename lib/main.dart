import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/Widgets/bottomNavigationBar.dart';
import 'package:flutter_application_1/screen/experiencies.dart';
import 'package:flutter_application_1/screen/logIn.dart';
import 'package:flutter_application_1/screen/perfil.dart';
import 'package:flutter_application_1/screen/register.dart';
import 'package:flutter_application_1/screen/user.dart';
import 'package:flutter_application_1/screen/home.dart';


void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        // Ruta de inicio de sesión
        GetPage(
          name: '/login',
          page: () => LogInPage(),
        ),
        // Ruta de registro
        GetPage(
          name: '/register',
          page: () => RegisterPage(),
        ),
        // Ruta de la pantalla principal con BottomNavScaffold
        GetPage(
          name: '/home',
          page: () => BottomNavScaffold(child: HomePage()),
        ),
        GetPage(
          name: '/usuarios',
          page: () => BottomNavScaffold(child: UserPage()),
        ),
        GetPage(
          name: '/experiencies',
          page: () => BottomNavScaffold(child: ExperienciesPage()),
        ),
        GetPage(
          name: '/perfil',
          page: () => BottomNavScaffold(child: PerfilPage()),
        ),
      ],
    );
  }
}

/* class BottomNavScaffold extends StatefulWidget {
  final Widget child;

  const BottomNavScaffold({required this.child});

  @override
  _BottomNavScaffoldState createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navegación usando Get.toNamed()
    switch (_selectedIndex) {
      case 0:
        Get.toNamed('/home');
        break;
      case 1:
        Get.toNamed('/usuarios');
        break;
      case 2:
        Get.toNamed('/experiencies');
        break;
      case 3:
        Get.toNamed('/perfil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 92, 14, 105),
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: 'Experiencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
} */
