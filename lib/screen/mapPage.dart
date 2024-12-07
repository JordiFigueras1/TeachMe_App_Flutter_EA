import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/userListController.dart';

class MapPage extends StatelessWidget {
  final UserListController userListController = Get.put(UserListController());

  @override
  Widget build(BuildContext context) {
    // Llamar a la función para obtener las coordenadas de los usuarios
    userListController.fetchUserCoordinates();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Usuarios'),
      ),
      body: Obx(() {
        if (userListController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userListController.userList.isEmpty) {
          return const Center(child: Text('No hay usuarios con coordenadas disponibles.'));
        }

        // Calcular el centro dinámico basado en las coordenadas de los usuarios
        final latitudes = userListController.userList.map((user) => user.lat).toList();
        final longitudes = userListController.userList.map((user) => user.lng).toList();

        double centerLatitude = 41.3879; // Valor predeterminado (Barcelona)
        double centerLongitude = 2.16992; // Valor predeterminado (Barcelona)

        if (latitudes.isNotEmpty && longitudes.isNotEmpty) {
          centerLatitude = latitudes.reduce((a, b) => a + b) / latitudes.length;
          centerLongitude = longitudes.reduce((a, b) => a + b) / longitudes.length;
        }

        // Crear los marcadores para cada usuario
        final markers = userListController.userList.map((user) {
          final coordinates = user.lat != 0.0 && user.lng != 0.0
              ? LatLng(user.lat, user.lng)
              : null;

          if (coordinates != null) {
            print("Creando marcador para ${user.name} en (${user.lat}, ${user.lng})");
            return Marker(
              width: 100.0,
              height: 100.0,
              point: coordinates,
              builder: (ctx) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
          return null;
        }).where((marker) => marker != null).toList();

        return FlutterMap(
          options: MapOptions(
            center: LatLng(centerLatitude, centerLongitude), // Centro dinámico
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers.cast<Marker>()),
          ],
        );
      }),
    );
  }
}
