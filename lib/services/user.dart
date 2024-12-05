import 'package:dio/dio.dart' as dio; // Alias para evitar conflicto
import 'package:get/get.dart';
import '../models/userModel.dart';
import '../models/asignaturaModel.dart';
import '../controllers/authController.dart';

class UserService {
  //final String baseUrl = 'http://10.0.2.2:3000/api/usuarios'; // Cambia si es necesario
   final String baseUrl = 'http://localhost:3000/api/usuarios'; // Cambia si es necesario

  final dio.Dio dioClient = dio.Dio();

  UserService() {
    final authController = Get.find<AuthController>();
    dioClient.options.headers['auth-token'] = authController.getToken; // Añadir el token a las cabeceras automáticamente
  }

  Future<int> createUser(UserModel newUser) async {
    try {
      print(newUser.toJson().toString()); // Reemplaza log con print
      dio.Response response = await dioClient.post('$baseUrl', data: newUser.toJson());

      int statusCode = response.statusCode ?? 500; // Obtén el statusCode de la respuesta

      if (statusCode == 204 || statusCode == 201 || statusCode == 200) {
        return statusCode;
      } else if (statusCode == 400) {
        return 400;
      } else if (statusCode == 500) {
        return 500;
      } else {
        return -1; // Error desconocido
      }
    } catch (e) {
      print("Error en createUser: $e");
      return 500;
    }
  }

  Future<List<AsignaturaModel>> getAsignaturasByUser(String userId) async {
    try {
      dio.Response response = await dioClient.get('$baseUrl/$userId/asignaturas');
      List<dynamic> data = response.data;
      return data.map((json) => AsignaturaModel.fromJson(json)).toList();
    } catch (e) {
      print("Error en getAsignaturasByUser: $e");
      throw Exception('Error al obtener asignaturas');
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      dio.Response response = await dioClient.get('$baseUrl');
      List<dynamic> responseData = response.data;
      List<UserModel> users = responseData.map((data) => UserModel.fromJson(data)).toList();
      return users;
    } catch (e) {
      print("Error en getUsers: $e");
      throw Exception('Error al obtener usuarios');
    }
  }

  Future<dio.Response> logIn(Map<String, String> credentials) async {
    try {
      dio.Response response = await dioClient.post('$baseUrl/login', data: credentials);
      if (response.statusCode == 200 && response.data != null) {
        // Almacenar token y userId en AuthController
        final authController = Get.find<AuthController>();
        final userId = response.data['usuario']['id']; // Obtén el ID del usuario
        final token = response.data['token']; // Obtén el token JWT

        authController.setUserId(userId);
        authController.setToken(token);

        return response; // Devuelve el objeto Response si es válido
      } else if (response.statusCode == 204) {
        throw Exception('Login fallido: Sin contenido en la respuesta');
      } else {
        throw Exception('Error inesperado: ${response.statusCode}');
      }
    } catch (e) {
      print("Error en logIn: $e");
      rethrow;
    }
  }

  Future<int> deleteUser(String id) async {
    try {
      dio.Response response = await dioClient.delete('$baseUrl/$id');
      int statusCode = response.statusCode ?? 500;

      if (statusCode == 204 || statusCode == 200) {
        return statusCode;
      } else if (statusCode == 400) {
        return 400;
      } else if (statusCode == 500) {
        return 500;
      } else {
        return -1; // Error desconocido
      }
    } catch (e) {
      print("Error en deleteUser: $e");
      return 500;
    }
  }

Future<List<UserModel>> searchUsers(String nombre, String token) async {
  try {
    final response = await dioClient.get(
      '$baseUrl/buscar',
      queryParameters: {'nombre': nombre},
      options: dio.Options(
        headers: {'auth-token': token},
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al buscar usuarios');
    }
  } catch (e) {
    throw Exception('Error al conectar con el servidor: $e');
  }
}
}
