import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asignaturaController.dart';
import '../Widgets/asignaturaCard.dart';
import '../controllers/theme_controller.dart'; // Importa el controlador del tema
import '../controllers/localeController.dart'; // Importa el controlador de idioma
import '../l10n.dart'; // Asegúrate de importar el archivo de localización

class AsignaturasPage extends StatelessWidget {
  final AsignaturaController asignaturaController = Get.put(AsignaturaController());

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find(); // Encuentra el controlador del tema
    final LocaleController localeController = Get.find(); // Encuentra el controlador del idioma

    final String userId = Get.parameters['userId'] ?? ''; // Se espera pasar el `userId` como parámetro

    asignaturaController.fetchAsignaturas(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('subjects') ?? 'Asignaturas', // Traducción para el título
        ),
        actions: [
          // Cambio de tema
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode // Si el tema es oscuro, cambiar a claro
                  : Icons.dark_mode,  // Si el tema es claro, cambiar a oscuro
            ),
            onPressed: () {
              themeController.toggleTheme(); // Alternar entre temas
            },
          ),
          // Cambio de idioma
          IconButton(
            icon: Icon(Icons.language, color: themeController.themeMode.value == ThemeMode.dark ? Colors.white : Colors.black),
            onPressed: () {
              // Cambia el idioma entre inglés y español
              if (localeController.currentLocale.value.languageCode == 'es') {
                localeController.changeLanguage('en');
              } else {
                localeController.changeLanguage('es');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (asignaturaController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (asignaturaController.errorMessage.isNotEmpty) {
          return Center(child: Text(asignaturaController.errorMessage.value));
        } else if (asignaturaController.asignaturas.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)?.translate('noSubjects') ?? 'No hay asignaturas disponibles.'));
        } else {
          return ListView.builder(
            itemCount: asignaturaController.asignaturas.length,
            itemBuilder: (context, index) {
              return AsignaturaCard(asignatura: asignaturaController.asignaturas[index]);
            },
          );
        }
      }),
    );
  }
}
