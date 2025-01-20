import 'package:get/get.dart';

class MapController extends GetxController {
  // Controlador para manejar el radio de búsqueda
  RxDouble searchRadius = 10.0.obs;

  // Función para actualizar el radio de búsqueda
  void updateSearchRadius(double radius) {
    searchRadius.value = radius;
  }
}
