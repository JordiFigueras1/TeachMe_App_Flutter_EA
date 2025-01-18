import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/userListController.dart';
import '../controllers/connectedUsersController.dart'; // Importar ConnectedUsersController
import '../controllers/theme_controller.dart';
import '../models/userModel.dart';

class MapPage extends StatelessWidget {
  final UserListController userListController = Get.put(UserListController());
  final ConnectedUsersController connectedUsersController =
      Get.find<ConnectedUsersController>(); // Acceder al controller
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    userListController
        .fetchUserCoordinates(); // Obtener coordenadas solo para los usuarios logueados
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
        final connectedUsers = connectedUsersController
            .connectedUsers; // Obtener la lista de usuarios conectados

        // Verificar si hay usuarios conectados
        if (connectedUsers.isEmpty) {
          return const Center(
            child: Text(
              'No hay usuarios logueados para mostrar en el mapa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        // Filtrar los usuarios logueados para mostrarlos en el mapa
        final usersAtLocations = userListController.userList
            .where((user) =>
                connectedUsers.contains(user.id)) // Solo mostrar los conectados
            .toList();

        final groupedUsers = _groupUsersByLocation(usersAtLocations);

        final markers =
            _generateMarkersForGroupedUsers(groupedUsers, isDarkMode);

        // Si no se encuentran usuarios en las coordenadas, mostrar un mensaje
        if (markers.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron usuarios con coordenadas válidas.',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        // Agregar una posición base en caso de que no haya usuarios
        final initialLatLng = markers.isNotEmpty
            ? markers.first.point
            : LatLng(40.7128, -74.0060); // Nueva York por defecto

        return FlutterMap(
          options: MapOptions(
            center: initialLatLng, // Definir un punto base si no hay usuarios
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers),
          ],
        );
      }),
    );
  }

  // Agrupar usuarios por ubicación (coordenadas)
  Map<String, List<UserModel>> _groupUsersByLocation(List<UserModel> users) {
    Map<String, List<UserModel>> groupedUsers = {};

    for (var user in users) {
      String key =
          '${user.lat.toStringAsFixed(5)},${user.lng.toStringAsFixed(5)}'; // Usar coordenadas fijas
      if (!groupedUsers.containsKey(key)) {
        groupedUsers[key] = [];
      }
      groupedUsers[key]!.add(user);
    }

    return groupedUsers;
  }

  // Crear marcadores para cada grupo de usuarios
  List<Marker> _generateMarkersForGroupedUsers(
      Map<String, List<UserModel>> groupedUsers, bool isDarkMode) {
    List<Marker> markers = [];

    groupedUsers.forEach((locationKey, usersAtLocation) {
      final LatLng location = LatLng(
        usersAtLocation.first.lat,
        usersAtLocation.first.lng,
      );

      markers.add(Marker(
        width: 120.0,
        height: 70.0,
        point: location,
        builder: (ctx) => GestureDetector(
          onTap: () {
            _showUsersAtLocationDetails(ctx, usersAtLocation, isDarkMode);
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
                  '${usersAtLocation.length} usuarios',
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
      ));
    });

    return markers;
  }

  // Mostrar los detalles de los usuarios en una ubicación
  void _showUsersAtLocationDetails(
      BuildContext context, List<UserModel> users, bool isDarkMode) {
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
              const Text(
                'Selecciona un usuario:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...users.map((user) {
                return ListTile(
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showUserDetails(context, user, isDarkMode);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Mostrar detalles de un solo usuario
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
