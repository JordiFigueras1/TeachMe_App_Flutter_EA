import 'package:get/get.dart';
import '../models/notificacionModel.dart';
import '../services/notificacionService.dart';

class NotificacionController extends GetxController {
  final NotificacionService _notificacionService = NotificacionService();

  var notificaciones = <NotificacionModel>[].obs;
  var isLoading = false.obs;

  // Cargar notificaciones del usuario
  Future<void> fetchNotificaciones(String userId) async {
    isLoading(true);
    try {
      final result = await _notificacionService.listarNotificaciones(userId);
      notificaciones.assignAll(result);
    } catch (e) {
      print('Error al obtener notificaciones: $e');
    } finally {
      isLoading(false);
    }
  }

  // Marcar una notificación como leída
  Future<void> marcarNotificacionComoLeida(String notificationId) async {
    try {
      await _notificacionService.marcarComoLeida(notificationId);
      notificaciones.removeWhere((notificacion) => notificacion.id == notificationId);
    } catch (e) {
      print('Error al marcar notificación como leída: $e');
    }
  }

  // Eliminar todas las notificaciones del usuario
  Future<void> eliminarNotificaciones(String userId) async {
    try {
      await _notificacionService.eliminarNotificaciones(userId);
      notificaciones.clear();
    } catch (e) {
      print('Error al eliminar notificaciones: $e');
    }
  }
}
