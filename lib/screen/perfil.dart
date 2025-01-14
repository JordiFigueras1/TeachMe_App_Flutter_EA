import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/userListController.dart';
import '../controllers/userModelController.dart';
import '../controllers/connectedUsersController.dart';
import '../controllers/asignaturaController.dart';
import '../models/userModel.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final UserListController userListController = Get.find<UserListController>();
  final UserModelController userModelController = Get.find<UserModelController>();
  final ConnectedUsersController connectedUsersController = Get.find<ConnectedUsersController>();
  final AsignaturaController asignaturaController = Get.find<AsignaturaController>();

  String? selectedAsignaturaId;
  String? selectedDia;
  String? selectedTurno;
  UserModel? selectedUser;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await asignaturaController.fetchAllAsignaturas();
    userListController.userList.clear();
  }

  void _filterUsers() {
    final role = userModelController.user.value.isProfesor ? 'alumno' : 'profesor';
    final List<Map<String, String>> disponibilidad = (selectedDia != null && selectedTurno != null)
        ? [{'dia': selectedDia!, 'turno': selectedTurno!}]
        : [];
    userListController.filterUsers(role, selectedAsignaturaId, disponibilidad);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: selectedUser == null ? const Text('Buscar Usuarios') : const Text('Perfil'),
        leading: selectedUser != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedUser = null; // Volver a la lista de usuarios
                  });
                },
              )
            : null,
        actions: selectedUser == null
            ? [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _filterUsers,
                ),
              ]
            : null,
      ),
      body: selectedUser == null ? _buildUserList(theme) : _buildUserProfile(theme),
    );
  }

  Widget _buildUserList(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Obx(() {
                if (asignaturaController.isLoading.value) {
                  return const CircularProgressIndicator();
                }
                return DropdownButtonFormField<String>(
                  value: selectedAsignaturaId,
                  items: asignaturaController.asignaturas
                      .map((asignatura) => DropdownMenuItem(
                            value: asignatura.id,
                            child: Text('${asignatura.nombre} - Nivel: ${asignatura.nivel}'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedAsignaturaId = value;
                  }),
                  decoration: const InputDecoration(labelText: 'Asignatura'),
                );
              }),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedDia,
                      items: ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes']
                          .map((dia) => DropdownMenuItem(
                                value: dia,
                                child: Text(dia),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        selectedDia = value;
                      }),
                      decoration: const InputDecoration(labelText: 'Día'),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedTurno,
                      items: ['Mañana', 'Tarde']
                          .map((turno) => DropdownMenuItem(
                                value: turno,
                                child: Text(turno),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        selectedTurno = value;
                      }),
                      decoration: const InputDecoration(labelText: 'Turno'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (userListController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userListController.userList.isEmpty) {
              return const Center(child: Text('No se encontraron usuarios.'));
            }

            return ListView.builder(
              itemCount: userListController.userList.length,
              itemBuilder: (context, index) {
                final user = userListController.userList[index];
                final isConnected = connectedUsersController.connectedUsers.contains(user.id);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isConnected ? Colors.green : Colors.grey,
                    child: const Icon(Icons.person),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.mail),
                  onTap: () {
                    setState(() {
                      selectedUser = user;
                    });
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildUserProfile(ThemeData theme) {
    final user = selectedUser!;
    final isConnected = connectedUsersController.connectedUsers.contains(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: isConnected ? Colors.green : Colors.grey,
                  backgroundImage: user.foto != null && user.foto!.isNotEmpty
                      ? NetworkImage(user.foto!)
                      : null,
                  child: user.foto == null || user.foto!.isEmpty
                      ? Icon(Icons.person, size: 50, color: theme.iconTheme.color)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(user.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(user.mail, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (user.isProfesor) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatisticItem(theme, Icons.star, 'Valoraciones', '-'),
                _buildStatisticItem(
                    theme, Icons.book, 'Asignaturas', '${user.asignaturasImparte?.length ?? 0}'),
                _buildStatisticItem(theme, Icons.person, 'Alumnos', '-'),
              ],
            ),
            const SizedBox(height: 20),
          ],
          _buildSectionTitle('Descripción', theme),
          Text(user.descripcion ?? 'Sin descripción', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          _buildSectionTitle('Asignaturas', theme),
          if (user.asignaturasImparte != null && user.asignaturasImparte!.isNotEmpty)
            Column(
              children: user.asignaturasImparte!
                  .map((asignatura) => ListTile(
                        title: Text(asignatura.nombre),
                        subtitle: Text(asignatura.nivel),
                      ))
                  .toList(),
            )
          else
            Text('No tiene asignaturas asignadas', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          _buildSectionTitle('Disponibilidad', theme),
          if (user.disponibilidad != null && user.disponibilidad!.isNotEmpty)
            Column(
              children: user.disponibilidad!
                  .map((d) => ListTile(
                        title: Text('${d['dia']} - ${d['turno']}'),
                      ))
                  .toList(),
            )
          else
            Text('No ha configurado su disponibilidad', style: theme.textTheme.bodyMedium),
          if (!user.isProfesor) ...[
            const SizedBox(height: 30),
            _buildSectionTitle('Historial de Clases', theme),
            Text('Aquí se mostrará el historial de clases del alumno.',
                style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/chat', arguments: {
                  'receiverId': user.id,
                  'receiverName': user.name,
                });
              },
              icon: const Icon(Icons.chat),
              label: const Text('Iniciar Chat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatisticItem(ThemeData theme, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: theme.iconTheme.color),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
