import 'package:get/get.dart';

class AuthController extends GetxController {
  // Variables para almacenar token, userId y userName
  var token = ''.obs;
  var userId = ''.obs;
  var nombre = ''.obs;

  // Métodos para establecer token y userId
  void setToken(String newToken) {
    token.value = newToken;
    print('Token establecido: $token');
  }

  void setUserId(String id) {
    userId.value = id;
    print('User ID establecido: $userId');
  }

  void setUserName(String name) {
    nombre.value = name;
    print('UserName establecido: $nombre');
  }

  // Métodos para obtener token, userId y userName
  String get getToken => token.value;
  String get getUserId => userId.value;
  String get getUserName => nombre.value;

  // Método para depuración
  void printAuthData() {
    print('Auth Data -> Token: $token, UserID: $userId, UserName: $nombre');
  }
}
