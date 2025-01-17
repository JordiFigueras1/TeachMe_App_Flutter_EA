import 'dart:math';

class LocationService {
  // Función para calcular la distancia entre dos puntos geográficos (en km)
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double radian = 57.29577951308232;
    final double dLat = (lat2 - lat1) / radian;
    final double dLng = (lng2 - lng1) / radian;
    final double a = (0.5 - (dLat / 2)) +
        (cos(lat1 / radian) * cos(lat2 / radian) * (1 - cos(dLng)) / 2);
    return 12742 * asin(sqrt(a)); // 12742 es el diámetro de la Tierra en km
  }
}
