import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/models/asignaturaModel.dart';
import 'package:flutter_application_1/services/asignatura.dart';



class AsignaturaController extends GetxController {
  final AsignaturaService asignaturaService = Get.put(AsignaturaService()); 
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController usuariosController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void createAsignatura() async {
    
    if (nombreController.text.isEmpty ||
        usuariosController.text.isEmpty ||
        descripcionController.text.isEmpty) {
      Get.snackbar('Error', 'Todos los campos son obligatorios',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final newAsignatura = Asignatura(
      nombre: nombreController.text,
      descripcion: descripcionController.text,
      usuariosAsignados: usuariosController.text.split(',').map((e) => e.trim()).toList(),
    );

    
    isLoading.value = true;
    errorMessage.value = '';

    try {
    
      final statusCode = await asignaturaService.createAsignatura(newAsignatura);

      if (statusCode == 201) {
        
        Get.snackbar('Éxito', 'Asignatura creada con éxito');
        Get.toNamed('/asignaturas'); 
      } else {
       
        errorMessage.value = 'Error al crear la asignatura';
      }
    } catch (e) {
      
      errorMessage.value = 'Error: No se pudo conectar con la API';
    } finally {
      
      isLoading.value = false;
    }
  }
}
      
       
