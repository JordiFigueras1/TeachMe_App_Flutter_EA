import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notificacionController.dart';

class NotificacionesPage extends StatelessWidget {
  final NotificacionController _notificacionController = Get.put(NotificacionController());
  final String userId;

  NotificacionesPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Cargar las notificaciones del usuario al entrar a la pantalla
    _notificacionController.fetchNotificaciones(userId);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: Obx(() {
        if (_notificacionController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_notificacionController.notificaciones.isEmpty) {
          return const Center(child: Text('No hay notificaciones.'));
        }

        return ListView.builder(
          itemCount: _notificacionController.notificaciones.length,
          itemBuilder: (context, index) {
            final notificacion = _notificacionController.notificaciones[index];
            return ListTile(
              key: ValueKey(notificacion.id), // Evitar problemas con el árbol de widgets
              title: Text(notificacion.descripcion),
              subtitle: Text(notificacion.fecha.toString()),
              trailing: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  // Marcar como leída y actualizar la lista local
                  _notificacionController
                      .marcarNotificacionComoLeida(notificacion.id)
                      .then((_) {
                    _notificacionController.notificaciones.removeAt(index);
                  }).catchError((error) {
                  });
                },
              ),
            );
          },
        );
      }),
    );
  }
}
