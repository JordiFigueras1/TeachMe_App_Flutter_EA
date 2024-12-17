import 'package:flutter/material.dart';
import '../l10n.dart';  // Asegúrate de que este archivo tenga las traducciones
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/localeController.dart';  // Asegúrate de que esté importado el controlador de idioma

class FAQScreen extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('faq_button') ?? 'Preguntas Frecuentes'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          // Botón para cambiar el tema (modo oscuro/claro)
          IconButton(
            icon: Icon(
              themeController.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: theme.textTheme.bodyLarge?.color,
            ),
            onPressed: themeController.toggleTheme,
          ),
          // Botón para cambiar el idioma
          IconButton(
            icon: Icon(Icons.language, color: theme.textTheme.bodyLarge?.color),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Pregunta 1
          _buildFAQItem(
            context,
            AppLocalizations.of(context)?.translate('faq_question_1') ?? '¿Cuál es tu política de privacidad?',
            AppLocalizations.of(context)?.translate('faq_answer_1') ?? 'Tus datos están seguros con nosotros, cumplimos con las regulaciones.',
          ),
          const Divider(),
          
          // Pregunta 2
          _buildFAQItem(
            context,
            AppLocalizations.of(context)?.translate('faq_question_2') ?? '¿Cómo puedo contactar con un tutor?',
            AppLocalizations.of(context)?.translate('faq_answer_2') ?? 'Puedes contactar con un tutor a través del chat o el botón de contacto.',
          ),
          const Divider(),
          
          // Añadir más preguntas aquí...
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ListTile(
      title: Text(
        question, 
        style: Theme.of(context).textTheme.titleLarge,  // Usando 'titleLarge' para el título
      ),
      subtitle: Text(
        answer, 
        style: Theme.of(context).textTheme.bodyMedium,  // Usando 'bodyMedium' para el subtítulo
      ),
    );
  }
}
