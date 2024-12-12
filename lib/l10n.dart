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
      'logIn': 'Log In',
      'email': 'Email',
      'password': 'Password',
      'loginButton': 'Login',
      'noAccount': 'Don\'t have an account? Sign Up',
      'register': 'Register',
      'name': 'Name',
      'age': 'Age',
      'confirmPassword': 'Confirm Password',
      'alreadyHaveAccount': 'Already have an account? Sign in',
      'subjects': 'Subjects',  // Título de la página de asignaturas
      'noSubjects': 'No subjects available.',  // Mensaje cuando no hay asignaturas
    },
    'es': {
      'helloWorld': 'Hola Mundo',
      'logIn': 'Iniciar Sesión',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'loginButton': 'Iniciar Sesión',
      'noAccount': '¿No tienes cuenta? Regístrate',
      'register': 'Registrarse',
      'name': 'Nombre',
      'age': 'Edad',
      'confirmPassword': 'Confirmar Contraseña',
      'alreadyHaveAccount': '¿Ya tienes una cuenta? Inicia sesión',
      'subjects': 'Asignaturas',  // Título de la página de asignaturas
      'noSubjects': 'No hay asignaturas disponibles.',  // Mensaje cuando no hay asignaturas
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
