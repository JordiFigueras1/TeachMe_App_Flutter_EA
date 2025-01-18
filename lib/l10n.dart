import 'dart:ui';
import 'package:flutter/material.dart';

// Clase que gestiona la localización
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Mapa de traducciones para diferentes idiomas
  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'helloWorld': 'Hello World',
      'login': 'Log In',
      'identifier': 'Email or Username',
      'password': 'Password',
      'loginButton': 'Log In',
      'noAccount': "Don't have an account? Register",
      'register': 'Register',
      'fullName': 'Full Name',
      'username': 'Username',
      'email': 'Email',
      'birthdate': 'Birthdate',
      'confirmPassword': 'Confirm Password',
    },
    'es': {
      'helloWorld': 'Hola Mundo',
      'login': 'Iniciar Sesión',
      'identifier': 'Correo o Nombre de Usuario',
      'password': 'Contraseña',
      'loginButton': 'Iniciar Sesión',
      'noAccount': '¿No tienes cuenta? Regístrate',
      'register': 'Registrarse',
      'fullName': 'Nombre Completo',
      'username': 'Nombre de Usuario',
      'email': 'Correo Electrónico',
      'birthdate': 'Fecha de Nacimiento',
      'confirmPassword': 'Confirmar Contraseña',
    },
  };

  // Método para obtener la traducción de una clave
  String? translate(String key) {
    return _localizedValues[locale.languageCode]?[key];
  }

  // Método estático 'of' para acceder a las localizaciones
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Delegado requerido por Flutter para las localizaciones
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

// Delegado que carga las traducciones según el idioma
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Idiomas soportados
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Carga la clase de localización para el idioma actual
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
