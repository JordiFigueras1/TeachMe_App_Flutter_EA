import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/userListController.dart';
import '../controllers/userModelController.dart';
import '../controllers/theme_controller.dart';
import '../models/userModel.dart';

class MapPage extends StatelessWidget {
  final UserListController userListController = Get.put(UserListController());
  final UserModelController userModelController =
      Get.find<UserModelController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    userListController
        .fetchUserCoordinates(); // Obtener coordenadas de todos los usuarios
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
        // Verificamos si el usuario logueado tiene coordenadas disponibles
        final loggedInUser = userModelController.user.value;
        if (loggedInUser.lat == 0.0 || loggedInUser.lng == 0.0) {
          return const Center(
            child: Text(
              'No se puede centrar el mapa porque las coordenadas del usuario no están disponibles.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        // Generar marcadores solo para el usuario logueado
        final markers = _generateMarkersForUsers([loggedInUser], isDarkMode);

        return FlutterMap(
          options: MapOptions(
            center: LatLng(loggedInUser.lat,
                loggedInUser.lng), // Centrado en el usuario logueado
            zoom:
                13.0, // Zoom ajustado para ver la ubicación del usuario con más detalle
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers), // Mostrar solo al usuario logueado
          ],
        );
      }),
    );
  }

  List<Marker> _generateMarkersForUsers(
      List<UserModel> users, bool isDarkMode) {
    return users.map((user) {
      return Marker(
        width: 120.0,
        height: 70.0,
        point: LatLng(user.lat, user.lng),
        builder: (ctx) => GestureDetector(
          onTap: () {
            _showUserDetails(ctx, user, isDarkMode);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: isDarkMode ? Colors.blue : Colors.red,
                size: 30.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  user.name, // Mostrar el nombre del usuario
                  style: TextStyle(
                    fontSize: 10.0,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showUserDetails(BuildContext context, UserModel user, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: isDarkMode ? Colors.black87 : Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Detalles de ${user.name}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Correo: ${user.mail}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Asignaturas que imparte:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              user.asignaturasImparte != null &&
                      user.asignaturasImparte!.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: user.asignaturasImparte!.map((asignatura) {
                        return Text(
                          '- ${asignatura.nombre} (${asignatura.nivel})',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    )
                  : Text(
                      'No tiene asignaturas asignadas.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
