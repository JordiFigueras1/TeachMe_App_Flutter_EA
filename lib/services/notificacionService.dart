import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/notificacionModel.dart';
import '../controllers/authController.dart'; // Importa el AuthController

class NotificacionService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000/api/notificaciones'; // URL base
  final AuthController _authController = Get.find<AuthController>();

  NotificacionService() {
    // Configura un interceptor para añadir el token en cada petición
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authController.getToken;
        if (token.isNotEmpty) {
          options.headers['auth-token'] = '$token';
        }
        return handler.next(options);
      },
    ));
  }

  // Crear notificación
  Future<NotificacionModel> crearNotificacion(String userId, String descripcion) async {
    final response = await _dio.post(_baseUrl, data: {
      'userId': userId,
      'descripcion': descripcion,
    });
    return NotificacionModel.fromJson(response.data);
  }

  // Listar notificaciones de un usuario
  Future<List<NotificacionModel>> listarNotificaciones(String userId) async {
    final response = await _dio.get('$_baseUrl/$userId');
    return (response.data as List)
        .map((notificacion) => NotificacionModel.fromJson(notificacion))
        .toList();
  }

  // Marcar una notificación como leída
  Future<void> marcarComoLeida(String notificationId) async {
    await _dio.put('$_baseUrl/$notificationId/leida');
  }

  // Eliminar todas las notificaciones de un usuario
  Future<void> eliminarNotificaciones(String userId) async {
    await _dio.delete('$_baseUrl/$userId');
  }
}
