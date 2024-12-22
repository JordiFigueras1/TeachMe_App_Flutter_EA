import 'package:dio/dio.dart' as dio; // Alias para evitar conflicto
import 'package:get/get.dart';
import '../models/userModel.dart';
import '../models/asignaturaModel.dart';
import '../controllers/authController.dart';

class UserService {
  final String baseUrl = 'http://localhost:3000/api/usuarios'; // Cambia si es necesario
  final dio.Dio dioClient = dio.Dio();

  UserService() {
    final authController = Get.find<AuthController>();
    dioClient.options.headers['auth-token'] = authController.getToken; // Añadir el token a las cabeceras automáticamente
  }

  Future<int> createUser(UserModel newUser) async {
    try {
      print(newUser.toJson().toString());
      dio.Response response = await dioClient.post('$baseUrl', data: newUser.toJson());
      int statusCode = response.statusCode ?? 500;

      if (statusCode == 204 || statusCode == 201 || statusCode == 200) {
        return statusCode;
      } else if (statusCode == 400) {
        return 400;
      } else if (statusCode == 500) {
        return 500;
      } else {
        return -1;
      }
    } catch (e) {
      print("Error en createUser: $e");
      return 500;
    }
  }

  Future<dio.Response> updateRole(String userId, bool isProfesor, bool isAlumno) async {
    try {
      final response = await dioClient.put( // Cambia PATCH por PUT
        '$baseUrl/$userId/rol',
        data: {
          'isProfesor': isProfesor,
          'isAlumno': isAlumno,
        },
      );
      return response;
    } catch (e) {
      print("Error en updateRole: $e");
      rethrow;
    }
  }


  Future<dio.Response> logIn(Map<String, dynamic> credentials) async {
    try {
      dio.Response response = await dioClient.post(
        '$baseUrl/login',
        data: {
          'identifier': credentials['identifier'], // Puede ser correo o username
          'password': credentials['password'],
          'lat': credentials['lat'], // Coordenada de latitud
          'lng': credentials['lng'], // Coordenada de longitud
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['usuario'] ?? {};
        final token = response.data['token'] ?? '';

        if (userData.isEmpty || token.isEmpty) {
          throw Exception('Datos faltantes en la respuesta del servidor');
        }

        // Configura los datos en AuthController
        final authController = Get.find<AuthController>();
        authController.setUserId(userData['id']);
        authController.setToken(token);

        // Verifica si el token se configuró correctamente
        print('Encabezado auth-token establecido: ${dioClient.options.headers['auth-token']}');
        dioClient.options.headers['auth-token'] = token;

        return response; // Devuelve la respuesta
      } else {
        throw Exception('Error inesperado: ${response.statusCode}');
      }
    } catch (e) {
      print("Error en logIn: $e");
      rethrow;
    }
  }

  Future<List<UserModel>> getUserCoordinates() async {
    try {
      final authController = Get.find<AuthController>();
      dioClient.options.headers['auth-token'] = authController.getToken; // Asegurar token antes de la solicitud

      final dio.Response response = await dioClient.get('$baseUrl/coordenadas');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener coordenadas de usuarios.');
      }
    } catch (e) {
      print("Error en getUserCoordinates: $e");
      throw Exception('Error al conectar con el servidor.');
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
