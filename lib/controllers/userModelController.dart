import 'package:get/get.dart';
import '../models/userModel.dart';

class UserModelController extends GetxController {
  final user = UserModel(
    id: '0', // ID predeterminado
    name: 'Usuario desconocido',
    mail: 'No especificado',
    password: 'Sin contraseña',
    age: 0, // Agregado: valor predeterminado para `age`
    isProfesor: false,
    isAlumno: false,
    isAdmin: false,
  ).obs;

  // Método para actualizar los datos del usuario
  void setUser(
    String id,
    String name,
    String mail,
    String password,
    int age,
    bool isProfesor,
    bool isAlumno,
    bool isAdmin,
    bool conectado,
  ) {
    user.update((val) {
      if (val != null) {
        val.setUser(
          id.isNotEmpty ? id : '0', // Asegurar que id nunca sea nulo
          name.isNotEmpty ? name : 'Usuario desconocido', // Valor predeterminado
          mail.isNotEmpty ? mail : 'No especificado', // Valor predeterminado
          password, // Contraseña vacía está bien
          age > 0 ? age : 0, // Si edad no está presente, usar 0
          isProfesor,
          isAlumno,
          isAdmin,
          conectado,
        );
      }
    });
  }
}
