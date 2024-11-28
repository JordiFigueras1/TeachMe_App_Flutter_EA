import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/userController.dart';

class LogInPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0), // Espaciado horizontal para centrar
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño para centrar mejor
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // **Contenedor con la imagen cuadrada (logo)**
                Container(
                    width: 200, // Ancho del contenedor cuadrado
                    height: 200, // Alto del contenedor cuadrado
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0), // Sin bordes redondeados
                      ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(0), // Sin bordes redondeados
                        child: Image.asset(
                          'assets/images/mi_imagen.png', // Ruta de tu imagen
                          fit: BoxFit.contain, // Ajustar la imagen sin recortarla
                        ),
                      ),
                ),

                const SizedBox(height: 30), // Espacio después del logo

                // **Título**
                Text(
                  "Bienvenido de nuevo",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // **Campo de correo electrónico**
                TextField(
                  controller: userController.mailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),

                // **Campo de contraseña**
                TextField(
                  controller: userController.passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                // **Botón de iniciar sesión**
                Obx(() {
                  if (userController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: () {
                        userController.logIn();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDEC2A6), // Fondo beige claro
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(color: Color(0xFF4A2C12)), // Texto marrón oscuro
                      ),
                    );
                  }
                }),

                const SizedBox(height: 16),

                // **Mensaje de error si existe**
                Obx(() {
                  if (userController.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        userController.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                const SizedBox(height: 16),

                // **Botón para registrarse**
                ElevatedButton(
                  onPressed: () => Get.toNamed('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDEC2A6), // Botón beige claro
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(color: Color(0xFF4A2C12)), // Texto marrón oscuro
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
