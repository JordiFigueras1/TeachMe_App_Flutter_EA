import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/localeController.dart';
import 'package:flutter_application_1/services/userService.dart';
import 'package:get/get.dart';
import '../controllers/userModelController.dart';
import '../controllers/theme_controller.dart';
import '../controllers/userController.dart';
import '../controllers/authController.dart';
import 'dart:html' as html;
import '../helpers/image_picker_helper.dart';
import '../services/cloudinary_service.dart';
import '../screen/upload_image_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n.dart';
import '../controllers/localeController.dart';
import 'dart:html' as html;
import '../helpers/image_picker_helper.dart';
import '../services/cloudinary_service.dart';




class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserModelController userModelController = Get.find<UserModelController>();

  final ThemeController themeController = Get.find<ThemeController>();

  final UserController userController = Get.put(UserController());

  final LocaleController localeController = Get.find<LocaleController>();

  final ImagePickerHelper _imagePicker = ImagePickerHelper();

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final _userService = UserService();
  

   String? _profileImageUrl;

    @override
  void initState() {
    super.initState();
    _loadProfileImageUrl();
  }

Future<void> _loadProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('profileImageUrl');
    });
  }

  Future<void> _saveProfileImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', url);
  }


  Future<void> _selectAndUploadProfileImage() async {
    final user = userModelController.user.value;
    
    final imageBase64 = await _imagePicker.pickImage();
    if (imageBase64 != null) {
      String? imageUrl = await _cloudinaryService.uploadImage(imageBase64);
      print("esta es la url$imageUrl");
      await _userService.updateUser(userId: user.id, data: {'foto': imageUrl});
      if (imageUrl != null) {
        setState(() {
          user.foto = imageUrl;
        userModelController.user.value.foto = imageUrl;
          _profileImageUrl = imageUrl;
        });
        _saveProfileImageUrl(imageUrl);
      } else {
        Get.snackbar('Error', 'No se pudo subir la imagen.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Llama a fetchUserById para actualizar los datos del usuario al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Get.find<AuthController>();
      final userId = authController.getUserId;
      if (userId.isNotEmpty) {
        userController.fetchUserById(userId);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('user_profile') ?? 'Perfil de Usuario'),

        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.iconTheme.color,
            ),
            onPressed: themeController.toggleTheme,
          ),
          IconButton(
                  icon: Icon(Icons.language,
                      color: theme.textTheme.bodyLarge?.color),
                  onPressed: () {
                    if (localeController.currentLocale.value.languageCode ==
                        'es') {
                      localeController.changeLanguage('en');
                    } else {
                      localeController.changeLanguage('es');
                    }
                  },
                )
        ],
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: _selectAndUploadProfileImage,
        child: const Icon(Icons.upload),
        tooltip: 'Subir foto de perfil',
      ),
      body: Obx(() {
        final user = userModelController.user.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto, nombre y correo
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
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
                // Estadísticas para profesores
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatisticItem(
                      theme,
                      Icons.star,
                      AppLocalizations.of(context)?.translate('ratings') ?? 'Valoraciones',
                      '-',
                    ),
                    _buildStatisticItem(
                      theme,
                      Icons.book,
                      AppLocalizations.of(context)?.translate('subjects') ?? 'Asignaturas',
                      '${user.asignaturasImparte?.length ?? 0}',
                    ),
                    _buildStatisticItem(
                      theme,
                      Icons.person,
                      AppLocalizations.of(context)?.translate('students') ?? 'Alumnos',
                      '-',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],

              _buildSectionTitle(
                  AppLocalizations.of(context)?.translate('description') ?? 'Descripción',
                  theme, ),
                Text(
                  user.descripcion ?? AppLocalizations.of(context)?.translate('no_description') ?? 'Sin descripción',
                  style: theme.textTheme.bodyMedium, ),

                const SizedBox(height: 20),


             
              

              // Asignaturas
              _buildSectionTitle(AppLocalizations.of(context)?.translate('subjects') ?? 'Asignaturas',theme,),

              if (user.asignaturasImparte != null && user.asignaturasImparte!.isNotEmpty)
                Column(
                  children: user.asignaturasImparte!
                      .map((asignatura) => ListTile(
                            title: Text(asignatura.nombre),
                            subtitle: Text(asignatura.nivel.isNotEmpty
                                ? asignatura.nivel
                                : AppLocalizations.of(context)?.translate('no_level_specified') ?? 'Sin nivel especificado'),
                          ))
                      .toList(),
                )
              else
                Text(AppLocalizations.of(context)?.translate('no_subjects_assigned') ??'No tienes asignaturas asignadas',
                    style: theme.textTheme.bodyMedium),

              const SizedBox(height: 20),

              // Disponibilidad
              _buildSectionTitle(AppLocalizations.of(context)?.translate('availability') ??'Disponibilidad', theme),
              if (user.disponibilidad != null && user.disponibilidad!.isNotEmpty)
                Column(
                  children: user.disponibilidad!
                      .map((d) => ListTile(
                            title: Text('${d['dia']} - ${d['turno']}'),
                          ))
                      .toList(),
                )
              else
                Text(AppLocalizations.of(context)?.translate('no_availability_configured') ??'No has configurado tu disponibilidad',
                    style: theme.textTheme.bodyMedium),

              if (!user.isProfesor) ...[
                const SizedBox(height: 30),
                // Historial de clases para alumnos
                _buildSectionTitle(AppLocalizations.of(context)?.translate('class_history') ?? 'Historial de Clases',theme,),
                Text(AppLocalizations.of(context)?.translate('class_history_description') ??'Aquí se mostrará el historial de clases del alumno.',
                    style: theme.textTheme.bodyMedium),
              ],

              const SizedBox(height: 30),

              // Botones de configuración
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed('/settings_general')!.then((_) {
                          // Actualiza los datos del usuario al volver
                          final authController = Get.find<AuthController>();
                          final userId = authController.getUserId;
                          if (userId.isNotEmpty) {
                            userController.fetchUserById(userId);
                          }
                        });
                      },
                      icon: const Icon(Icons.settings),
                      label: Text(AppLocalizations.of(context)?.translate('settings') ?? 'Configuración',),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed('/settings_asignaturas')!.then((_) {
                          // Actualiza los datos del usuario al volver
                          final authController = Get.find<AuthController>();
                          final userId = authController.getUserId;
                          if (userId.isNotEmpty) {
                            userController.fetchUserById(userId);
                          }
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(AppLocalizations.of(context)?.translate('update_data') ?? 'Actualizar Datos', ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
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
