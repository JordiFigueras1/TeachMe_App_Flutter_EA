import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asignaturaController.dart';
import '../Widgets/asignaturaCard.dart';

class AsignaturasPage extends StatelessWidget {
  final AsignaturaController asignaturaController = Get.put(AsignaturaController());

  @override
  Widget build(BuildContext context) {
    final String userId = Get.parameters['userId'] ?? ''; // Se espera pasar el `userId` como parámetro

    asignaturaController.fetchAsignaturas(userId);

    return Scaffold(
      appBar: AppBar(title: Text('Asignaturas del Usuario')),
      body: Obx(() {
        if (asignaturaController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (asignaturaController.errorMessage.isNotEmpty) {
          return Center(child: Text(asignaturaController.errorMessage.value));
        } else if (asignaturaController.asignaturas.isEmpty) {
          return Center(child: Text('No hay asignaturas disponibles.'));
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
