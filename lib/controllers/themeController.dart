import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Estado del tema: inicialmente claro
  var themeMode = ThemeMode.light.obs;

  // Método para alternar entre claro y oscuro
  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}
