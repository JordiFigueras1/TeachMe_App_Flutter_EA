import 'package:get/get.dart';

class AuthController extends GetxController {
  // Variable para almacenar el userId
  var userId = ''.obs;

  // Método para establecer el userId
  void setUserId(String id) {
    userId.value = id;
  }

  // Método para obtener el userId
  String get getUserId => userId.value;
}
