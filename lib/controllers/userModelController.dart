import 'package:get/get.dart';
import '../models/userModel.dart';

class UserModelController extends GetxController {
  final user = UserModel(
    name: 'Usuario desconocido',
    mail: 'No especificado',
    password: 'Sin contraseña',
    age: 0, // Agregado: valor predeterminado para `age`
    isProfesor: false,
    isAlumno: false,
    isAdmin: false,
  ).obs;

  // Método para actualizar los datos del usuario
  void setUser(String name, String mail, String password, int age, bool isProfesor, bool isAlumno, bool isAdmin) {
    user.update((val) {
      if (val != null) {
        val.setUser(name, mail, password, age, isProfesor, isAlumno, isAdmin);
      }
    });
  }
}
