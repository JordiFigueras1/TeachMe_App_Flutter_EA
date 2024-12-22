import 'package:get/get.dart';
import '../models/userModel.dart';

class UserModelController extends GetxController {
  final user = UserModel(
    id: '0',
    name: 'Usuario desconocido',
    username: 'Sin username',
    mail: 'No especificado',
    password: 'Sin contraseña',
    fechaNacimiento: 'Sin especificar',
    isProfesor: false,
    isAlumno: false,
    isAdmin: false,
  ).obs;

  // Método para actualizar los datos del usuario
  void setUser({
    required String id,
    required String name,
    required String username,
    required String mail,
    required String password,
    required String fechaNacimiento,
    required bool isProfesor,
    required bool isAlumno,
    required bool isAdmin,
    required bool conectado,
    double? lat,
    double? lng,
  }) {
    user.update((val) {
      if (val != null) {
        val.id = id;
        val.name = name;
        val.username = username;
        val.mail = mail;
        val.password = password;
        val.fechaNacimiento = fechaNacimiento;
        val.isProfesor = isProfesor;
        val.isAlumno = isAlumno;
        val.isAdmin = isAdmin;
        val.conectado = conectado;
        if (lat != null) val.lat = lat;
        if (lng != null) val.lng = lng;
      }
    });
  }
}
