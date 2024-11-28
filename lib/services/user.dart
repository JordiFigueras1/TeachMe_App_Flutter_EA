import 'package:dio/dio.dart';
import '../models/userModel.dart';
import '../models/asignaturaModel.dart';


class UserService {
  //final String baseUrl = "http://localhost:3000/api/usuarios";
  final String baseUrl = 'http://10.0.2.2:3000/api/usuarios';
  final Dio dio = Dio();

  Future<int> createUser(UserModel newUser) async {
    try {
      print(newUser.toJson().toString()); // Reemplaza log con print
      Response response = await dio.post('$baseUrl', data: newUser.toJson());

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
      Response response = await dio.get('$baseUrl/$userId/asignaturas');
      List<dynamic> data = response.data;
      return data.map((json) => AsignaturaModel.fromJson(json)).toList();
    } catch (e) {
      print("Error en getAsignaturasByUser: $e");
      throw Exception('Error al obtener asignaturas');
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      Response response = await dio.get('$baseUrl');
      List<dynamic> responseData = response.data;
      List<UserModel> users = responseData.map((data) => UserModel.fromJson(data)).toList();
      return users;
    } catch (e) {
      print("Error en getUsers: $e");
      throw Exception('Error al obtener usuarios');
    }
  }

Future<Response> logIn(Map<String, String> credentials) async {
  try {
    Response response = await dio.post('$baseUrl/login', data: credentials);
    if (response.statusCode == 200 && response.data != null) {
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
      Response response = await dio.delete('$baseUrl/$id');
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
}