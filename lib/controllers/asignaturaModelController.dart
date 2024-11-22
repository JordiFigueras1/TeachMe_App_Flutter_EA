import 'package:get/get.dart';
import 'package:flutter_application_1/models/asignaturaModel.dart'; 

class AsignaturaController extends GetxController {
 
  final asignatura = Asignatura(
    nombre: 'Asignatura desconocida',
    descripcion: 'Sin descripción',
    usuariosAsignados: [], 
  ).obs;

  void setAsignatura(String nombre, String descripcion, List<String> usuariosAsignados) {
    asignatura.update((val) {
      if (val != null) {
        val.setAsignatura(nombre, descripcion, usuariosAsignados);
      }
    });
  }
}
