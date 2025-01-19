import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/userListController.dart';
import '../controllers/connectedUsersController.dart';
import '../controllers/theme_controller.dart';
import '../controllers/userModelController.dart';
import '../models/userModel.dart';
import '../screen/chat.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final UserListController userListController = Get.put(UserListController());
  final ConnectedUsersController connectedUsersController =
      Get.find<ConnectedUsersController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final UserModelController userModelController =
      Get.find<UserModelController>();

  double _zoom = 13.0;
  MapController _mapController = MapController(); // Agregar MapController

  @override
  Widget build(BuildContext context) {
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
        final connectedUsers = connectedUsersController.connectedUsers;

        if (connectedUsers.isEmpty) {
          return const Center(
            child: Text(
              'No hay usuarios logueados para mostrar en el mapa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        final usersAtLocations = userListController.userList
            .where((user) => connectedUsers.contains(user.id))
            .toList();

        final groupedUsers = _groupUsersByLocation(usersAtLocations);
        final markers =
            _generateMarkersForGroupedUsers(groupedUsers, isDarkMode);

        if (markers.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron usuarios con coordenadas válidas.',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        final initialLatLng = markers.first.point;

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController, // Asigna el MapController
              options: MapOptions(
                center: initialLatLng,
                zoom: _zoom,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        if (_zoom < 18) {
                          _zoom++;
                          _mapController.move(_mapController.center,
                              _zoom); // Actualiza el zoom
                        }
                      });
                    },
                    heroTag: null,
                    child: Icon(Icons.zoom_in),
                    backgroundColor:
                        isDarkMode ? Colors.blue : Colors.blueAccent,
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        if (_zoom > 1) {
                          _zoom--;
                          _mapController.move(_mapController.center,
                              _zoom); // Actualiza el zoom
                        }
                      });
                    },
                    heroTag: null,
                    child: Icon(Icons.zoom_out),
                    backgroundColor:
                        isDarkMode ? Colors.blue : Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Map<String, List<UserModel>> _groupUsersByLocation(List<UserModel> users) {
    Map<String, List<UserModel>> groupedUsers = {};

    for (var user in users) {
      String key =
          '${user.lat.toStringAsFixed(5)},${user.lng.toStringAsFixed(5)}';
      groupedUsers.putIfAbsent(key, () => []);
      groupedUsers[key]!.add(user);
    }

    return groupedUsers;
  }

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
                'Usuarios en esta ubicación:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                  subtitle: Text(
                    ' ${_getUserRole(user)}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.info,
                          color: isDarkMode ? Colors.blue : Colors.green,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Cierra el popup de usuarios
                          _showUserDetails(context, user, isDarkMode);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chat,
                          color: isDarkMode ? Colors.blue : Colors.green,
                        ),
                        onPressed: () {
                          _startChatWithUser(context, user);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context); // Cierra el popup
                    _showUserDetails(context, user,
                        isDarkMode); // Muestra el popup de detalles
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showUserDetails(BuildContext context, UserModel user, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
          title: Text(
            'Detalles de ${user.name}',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre: ${user.name}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${user.mail}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ' ${_getUserRole(user)}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Disponibilidad:',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...?user.disponibilidad?.map((slot) => Text(
                        '${slot['dia']} - ${slot['turno']}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      )) ??
                  [],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _startChatWithUser(BuildContext context, UserModel user) {
    // Aquí puedes implementar la lógica para abrir el chat con el usuario.
    Get.snackbar(
      'Chat iniciado',
      'Iniciando chat con ${user.name}',
      snackPosition: SnackPosition.BOTTOM,
    );

    // Navegar a la página de chat
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatPage(receiverId: user.id, receiverName: user.name)),
    );
  }

  String _getUserRole(UserModel user) {
    if (user.isProfesor) return 'Profesor';
    if (user.isAlumno) return 'Alumno';
    return 'Sin rol';
  }
}
