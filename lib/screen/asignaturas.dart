import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asignaturaController.dart';
import '../Widgets/asignaturaCard.dart';
import '../controllers/themeController.dart';

class AsignaturasPage extends StatelessWidget {
  final AsignaturaController asignaturaController = Get.put(AsignaturaController());
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final String userId = Get.parameters['userId'] ?? '';

    asignaturaController.fetchAsignaturas(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignaturas del Usuario'),
        actions: [
          // Botón para alternar entre temas
          IconButton(
            icon: Obx(() => Icon(
                  themeController.themeMode.value == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                )),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      body: Obx(() {
        if (asignaturaController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (asignaturaController.errorMessage.isNotEmpty) {
          return Center(child: Text(asignaturaController.errorMessage.value));
        } else if (asignaturaController.asignaturas.isEmpty) {
          return const Center(child: Text('No hay asignaturas disponibles.'));
        } else {
          return ListView.builder(
            itemCount: asignaturaController.asignaturas.length,
            itemBuilder: (context, index) {
              return AsignaturaCard(asignatura: asignaturaController.asignaturas[index]);
            },
          );
        }
      }),
    );
  }
}
