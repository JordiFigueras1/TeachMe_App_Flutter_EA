import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' hide MapController;
import 'package:latlong2/latlong.dart';
import '../controllers/mapController.dart';
import '../controllers/userListController.dart';
import '../controllers/userModelController.dart';
import '../controllers/theme_controller.dart';
import '../services/mapService.dart';

class MapPage extends StatelessWidget {
  // Instanciamos el controlador MapController
  final mapController = Get.put(MapController());

  // Otros controladores
  final UserListController userListController = Get.put(UserListController());
  final UserModelController userModelController =
      Get.find<UserModelController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final LocationService locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    userListController.fetchUserCoordinates();

    final isDarkMode = themeController.themeMode.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Usuarios'),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeController.toggleTheme();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (userListController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userListController.userList.isEmpty) {
          return const Center(
            child: Text('No hay usuarios con coordenadas disponibles.'),
          );
        }

        final userLoggedInLat = userModelController.user.value.lat;
        final userLoggedInLng = userModelController.user.value.lng;

        if (userLoggedInLat == 0.0 || userLoggedInLng == 0.0) {
          return const Center(
            child: Text(
              'No se puede centrar el mapa porque las coordenadas del usuario no están disponibles.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        final double searchRadius = mapController.searchRadius.value;

        final markers = userListController.userList
            .map((user) {
              final coordinates = user.lat != 0.0 && user.lng != 0.0
                  ? LatLng(user.lat, user.lng)
                  : null;

              if (coordinates != null) {
                double distance = locationService.calculateDistance(
                    userLoggedInLat, userLoggedInLng, user.lat, user.lng);
                if (distance <= searchRadius) {
                  return Marker(
                    width: 100.0,
                    height: 100.0,
                    point: coordinates,
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        // Aquí puedes agregar el código para abrir un chat con el usuario
                        _showChatDialog(context, user);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: isDarkMode ? Colors.blue : Colors.red,
                            size: 40.0,
                          ),
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
              return null;
            })
            .where((marker) => marker != null)
            .toList();

        markers.add(Marker(
          width: 100.0,
          height: 100.0,
          point: LatLng(userLoggedInLat, userLoggedInLng),
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_pin,
                color: isDarkMode ? Colors.blue : Colors.green,
                size: 40.0,
              ),
              Text(
                'Tú',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Buscar usuarios dentro de ${searchRadius.toStringAsFixed(1)} km'),
                  Slider(
                    value: searchRadius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 10,
                    label: '${searchRadius.toStringAsFixed(1)} km',
                    onChanged: (double value) {
                      mapController.searchRadius.value = value;
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(userLoggedInLat, userLoggedInLng),
                  zoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: markers.cast<Marker>()),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // Método para mostrar el diálogo del chat
  void _showChatDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Iniciar chat con ${user.name}'),
          content: Text('¿Quieres iniciar un chat con ${user.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Lógica para abrir la pantalla de chat con el usuario seleccionado
                // Aquí podrías navegar a la página de chat, por ejemplo
              },
              child: Text('Iniciar chat'),
            ),
          ],
        );
      },
    );
  }
}
