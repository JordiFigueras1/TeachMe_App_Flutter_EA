import 'package:get/get.dart';

class AuthController extends GetxController {
  // Variables para almacenar token y userId
  var token = ''.obs;
  var userId = ''.obs;

  // Métodos para establecer token y userId
  void setToken(String newToken) {
    token.value = newToken;
  }

  void setUserId(String id) {
    userId.value = id;
  }

  // Métodos para obtener token y userId
  String get getToken => token.value;
  String get getUserId => userId.value;
}
