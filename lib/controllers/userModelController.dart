import 'package:get/get.dart';
import 'package:flutter_application_1/models/userModel.dart';

class UserModelController extends GetxController {
  final user = UserModel(
    name: 'Usuario desconocido',
    mail: 'No especificado',
    password: 'Sin contraseña',
    comment: 'Sin comentarios',
  ).obs;

  // Método para actualizar los datos del usuario
  void setUser(String name, String mail, String password, String comment) {
    user.update((val) {
      if (val != null) {
        val.setUser(name, mail, password, comment);
      }
    });
  }
}