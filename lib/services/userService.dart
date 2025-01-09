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

  Future<dio.Response> updateUser({required String userId, required Map<String, dynamic> data}) async {
    try {
      final response = await dioClient.put('$baseUrl/$userId', data: data);
      return response;
    } catch (e) {
      print("Error en updateUser: $e");
      rethrow;
    }
  }

  Future<dio.Response> updateRole(String userId, bool isProfesor, bool isAlumno) async {
    try {
      final response = await dioClient.put(
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
          'identifier': credentials['identifier'],
          'password': credentials['password'],
          'lat': credentials['lat'],
          'lng': credentials['lng'],
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['usuario'] ?? {};
        final token = response.data['token'] ?? '';

        if (userData.isEmpty || token.isEmpty) {
          throw Exception('Datos faltantes en la respuesta del servidor');
        }

        final authController = Get.find<AuthController>();
        authController.setUserId(userData['id']);
        authController.setToken(token);

        dioClient.options.headers['auth-token'] = token;
        return response;
      } else {
        throw Exception('Error inesperado: ${response.statusCode}');
      }
    } catch (e) {
      print("Error en logIn: $e");
      rethrow;
    }
  }

  Future<dio.Response> getUserById(String userId) async {
    try {
      final response = await dioClient.get('$baseUrl/$userId');
      return response;
    } catch (e) {
      print("Error en getUserById: $e");
      rethrow;
    }
  }


  Future<dio.Response> updateDisponibilidad(String userId, List<Map<String, String>> disponibilidad) async {
    try {
      final response = await dioClient.put(
        '$baseUrl/$userId/actualizar-disponibilidad',
        data: {'disponibilidad': disponibilidad},
      );
      return response;
    } catch (e) {
      print("Error en updateDisponibilidad: $e");
      rethrow;
    }
  }

  Future<List<UserModel>> getUserCoordinates() async {
    try {
      final authController = Get.find<AuthController>();
      dioClient.options.headers['auth-token'] = authController.getToken;

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

  Future<void> updateAsignaturas(String userId, List<String> asignaturaIds) async {
    try {
      final response = await dioClient.put(
        '$baseUrl/$userId/actualizar-asignaturas',
        data: {'asignaturas': asignaturaIds},
      );
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar las asignaturas');
      }
    } catch (e) {
      print("Error en updateAsignaturas: $e");
      throw Exception('Error en la solicitud: $e');
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
        return -1;
      }
    } catch (e) {
      print("Error en deleteUser: $e");
      return 500;
    }
  }

  Future<List<AsignaturaModel>> getAllAsignaturas() async {
  try {
    dio.Response response = await dioClient.get('http://localhost:3000/api/asignaturas');
    List<dynamic> data = response.data;
    return data.map((json) => AsignaturaModel.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Error al obtener todas las asignaturas');
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
