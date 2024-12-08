import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asignaturaController.dart';
import '../Widgets/asignaturaCard.dart';

class AsignaturasPage extends StatelessWidget {
  final AsignaturaController asignaturaController = Get.put(AsignaturaController());

  @override
  Widget build(BuildContext context) {
    final String userId = Get.parameters['userId'] ?? '';

    asignaturaController.fetchAsignaturas(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignaturas del Usuario'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 83, 98, 186),
      ),
      body: Obx(() {
        if (asignaturaController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (asignaturaController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              asignaturaController.errorMessage.value,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        } else if (asignaturaController.asignaturas.isEmpty) {
          return const Center(
            child: Text(
              'No hay asignaturas disponibles.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: asignaturaController.asignaturas.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: AsignaturaCard(asignatura: asignaturaController.asignaturas[index]),
              );
            },
          );
        }
      }),
    );
  }
}
