import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFFA67C52), // Marrón claro
    scaffoldBackgroundColor: const Color(0xFFFAF3E3), // Fondo beige claro
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A2C12)), // Letras marrón oscuro
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF4A2C12)), // Texto general marrón oscuro
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF7C5A35)), // Texto secundario marrón medio
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDEC2A6), // Marrón beige para los botones
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(color: Color(0xFF4A2C12), fontWeight: FontWeight.bold), // Texto de botones marrón oscuro
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFA67C52), // Marrón claro para el AppBar
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}
