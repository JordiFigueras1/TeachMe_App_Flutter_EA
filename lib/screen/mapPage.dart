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
  MapController _mapController = MapController();
  String selectedRole = 'Todos';
  bool showCircle = false; // Controla la visibilidad del círculo
  double circleRadius = 500; // Controla el radio del círculo (en metros)

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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: selectedRole,
              dropdownColor: isDarkMode ? Colors.black : Colors.white,
              onChanged: (String? newValue) {
                setState(() {
                  selectedRole = newValue!;
                });
              },
              items: <String>['Todos', 'Profesor', 'Alumno']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
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

        final filteredUsers = _filterUsersByRole(usersAtLocations);

        final groupedUsers = _groupUsersByLocation(filteredUsers);
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
              mapController: _mapController,
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
                if (showCircle)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: initialLatLng,
                        color: Colors.blue.withOpacity(0.3),
                        borderStrokeWidth: 1,
                        borderColor: Colors.blue,
                        useRadiusInMeter: true,
                        radius: circleRadius, // Usa la variable del radio
                      ),
                    ],
                  ),
                MarkerLayer(markers: markers),
              ],
            ),
            if (showCircle)
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: showCircle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    color: isDarkMode ? Colors.black : Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Radio del círculo (metros)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.blue,
                              inactiveTrackColor: Colors.grey,
                              trackHeight: 4.0,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10.0,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 20.0,
                              ),
                              thumbColor: isDarkMode
                                  ? Colors.orange
                                  : Colors.orangeAccent,
                              overlayColor: Colors.orange.withOpacity(0.2),
                              valueIndicatorTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            child: Slider(
                              value: circleRadius,
                              min: 0,
                              max: 20000, // 20 km
                              divisions: 40, // Opcional: 500 m por división
                              label:
                                  '${(circleRadius / 1000).toStringAsFixed(1)} km',
                              onChanged: (value) {
                                setState(() {
                                  circleRadius = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                        showCircle = !showCircle;
                      });
                    },
                    heroTag: null,
                    child: Icon(
                      showCircle ? Icons.visibility_off : Icons.visibility,
                    ),
                    backgroundColor:
                        isDarkMode ? Colors.orange : Colors.orangeAccent,
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        if (_zoom < 18) {
                          _zoom++;
                          _mapController.move(_mapController.center, _zoom);
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
                          _mapController.move(_mapController.center, _zoom);
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

  List<UserModel> _filterUsersByRole(List<UserModel> users) {
    if (selectedRole == 'Profesor') {
      return users.where((user) => user.isProfesor).toList();
    } else if (selectedRole == 'Alumno') {
      return users.where((user) => user.isAlumno).toList();
    } else {
      return users; // Devuelve todos los usuarios si no hay filtro
    }
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
    // Colores personalizados para este popup
    final Color backgroundColor =
        isDarkMode ? Color(0xFF0D1B2A) : Color(0xFFEAF6FF);
    final Color titleColor = isDarkMode ? Color(0xFF84A9C0) : Color(0xFF0D3B66);
    final Color textColor = isDarkMode ? Color(0xFFB8D8E7) : Color(0xFF0D1B2A);
    final Color secondaryTextColor =
        isDarkMode ? Color(0xFF5A768A) : Color(0xFF5C6F81);
    final Color buttonColor =
        isDarkMode ? Color(0xFF1E5F74) : Color(0xFF007EA7);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Usuarios en esta ubicación:',
                style: TextStyle(
                  color: titleColor,
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
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    ' ${_getUserRole(user)}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: secondaryTextColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.info,
                          color: buttonColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Cierra el popup de usuarios
                          _showUserDetails(context, user, isDarkMode);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chat,
                          color: buttonColor,
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
    // Colores personalizados
    final Color backgroundColor =
        isDarkMode ? Color(0xFF0D1B2A) : Color(0xFFEAF6FF);
    final Color titleColor = isDarkMode ? Color(0xFF84A9C0) : Color(0xFF0D3B66);
    final Color textColor = isDarkMode ? Color(0xFFB8D8E7) : Color(0xFF0D1B2A);
    final Color secondaryTextColor =
        isDarkMode ? Color(0xFF5A768A) : Color(0xFF5C6F81);
    final Color buttonColor =
        isDarkMode ? Color(0xFF1E5F74) : Color(0xFF007EA7);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Detalles de ${user.name}',
            style: TextStyle(
              color: titleColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre:',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Email:',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.mail,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rol:',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getUserRole(user),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.0,
                ),
              ),
              if (user.asignaturasImparte != null &&
                  user.asignaturasImparte!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Asignaturas que imparte:',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...user.asignaturasImparte!.map((asignatura) {
                  return Text(
                    '- ${asignatura.nombre}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.0,
                    ),
                  );
                }),
              ],
              if (user.disponibilidad != null &&
                  user.disponibilidad!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Disponibilidad:',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...user.disponibilidad!.map((slot) {
                  return Text(
                    '${slot['dia']} - ${slot['turno']}',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14.0,
                    ),
                  );
                }),
              ],
            ],
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.arrow_back, color: buttonColor),
              label: Text(
                'Volver',
                style: TextStyle(
                  color: buttonColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Cierra el popup de detalles
              },
            ),
          ],
        );
      },
    );
  }

  /// Método auxiliar para determinar el rol del usuario
  String _getUserRole(UserModel user) {
    if (user.isProfesor) return 'Profesor';
    if (user.isAlumno) return 'Alumno';
    if (user.isAdmin) return 'Administrador';
    return 'Sin especificar';
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
}
