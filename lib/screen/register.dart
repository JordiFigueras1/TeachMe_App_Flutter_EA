import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/registerController.dart';

class RegisterPage extends StatelessWidget {
  final RegisterController registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrarse')),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 26),
                // **Campo de usuario**
                TextField(
                  controller: registerController.nameController,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                ),
                const SizedBox(height: 16), // Espacio entre los campos
                // **Campo de correo electrónico**
                TextField(
                  controller: registerController.mailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                ),
                const SizedBox(height: 16), // Espacio entre los campos
                // **Campo de contraseña**
                TextField(
                  controller: registerController.passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                const SizedBox(height: 20), // Espacio entre los campos
                // **Seleccionar tipo de perfil**
                const Text('Seleccione el tipo de perfil'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GetBuilder<RegisterController>(builder: (controller) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          activeColor: Colors.blue,
                          value: 0,
                          groupValue: controller.perfil,
                          onChanged: (value) {
                            controller.setPerfil(value!);
                          },
                        ),
                        const Text('Alumno'),
                        Radio(
                          activeColor: Colors.blue,
                          value: 1,
                          groupValue: controller.perfil,
                          onChanged: (value) {
                            controller.setPerfil(value!);
                          },
                        ),
                        const Text('Profesor'),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 16), // Espacio después de la selección
                // **Comentario**
                TextField(
                  controller: registerController.commentController,
                  decoration: const InputDecoration(labelText: 'Comentario'),
                ),
                const SizedBox(height: 16), // Espacio adicional
                // **Botón de registrarse**
                Obx(() {
                  if (registerController.isLoading.value) {
                    return const CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      onPressed: registerController.signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDEC2A6), // Fondo beige
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(color: Color(0xFF4A2C12)), // Texto marrón
                      ),
                    );
                  }
                }),

                // **Mensaje de error**
                Obx(() {
                  if (registerController.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        registerController.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                const SizedBox(height: 16),

                // **Botón para volver al login**
                ElevatedButton(
                  onPressed: () => Get.toNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDEC2A6), // Fondo beige
                  ),
                  child: const Text(
                    'Volver',
                    style: TextStyle(color: Color(0xFF4A2C12)), // Texto marrón
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
