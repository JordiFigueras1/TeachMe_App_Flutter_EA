import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String id;
  String name;
  String username; // Agregado
  String mail;
  String password;
  String fechaNacimiento;
  bool isProfesor;
  bool isAlumno;
  bool isAdmin;
  bool conectado;
  double lat;
  double lng;

  UserModel({
    required this.id,
    required this.name,
    required this.username, // Agregado
    required this.mail,
    required this.password,
    required this.fechaNacimiento,
    this.isProfesor = false,
    this.isAlumno = false,
    this.isAdmin = true,
    this.conectado = false,
    this.lat = 0.0,
    this.lng = 0.0,
  });

  // Método para actualizar el modelo
  void setUser({
    required String id,
    required String name,
    required String username, // Agregado
    required String mail,
    required String password,
    required String fechaNacimiento,
    required bool isProfesor,
    required bool isAlumno,
    required bool isAdmin,
    required bool conectado,
    double? lat,
    double? lng,
  }) {
    this.id = id;
    this.name = name;
    this.username = username; // Actualizado
    this.mail = mail;
    this.password = password;
    this.fechaNacimiento = fechaNacimiento;
    this.isProfesor = isProfesor;
    this.isAlumno = isAlumno;
    this.isAdmin = isAdmin;
    this.conectado = conectado;
    if (lat != null) this.lat = lat;
    if (lng != null) this.lng = lng;
    notifyListeners();
  }

  // Crear instancia desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['nombre'] ?? 'Sin nombre',
      username: json['username'] ?? 'Sin username',
      mail: json['email'] ?? 'Sin email',
      password: '', // El backend no devuelve la contraseña
      fechaNacimiento: json['fechaNacimiento'] ?? 'No especificada',
      isProfesor: json['isProfesor'] ?? false,
      isAlumno: json['isAlumno'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      conectado: json['conectado'] ?? false,
      lat: json['location']?['coordinates']?[1] ?? 0.0, // Validación segura
      lng: json['location']?['coordinates']?[0] ?? 0.0,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre': name,
      'username': username, // Agregado
      'email': mail,
      'password': password,
      'fechaNacimiento': fechaNacimiento,
      'isProfesor': isProfesor,
      'isAlumno': isAlumno,
      'isAdmin': isAdmin,
      'conectado': conectado,
      'lat': lat,
      'lng': lng,
    };
  }

  // Método toString para depuración y representación
  @override
  String toString() {
    return '''
    UserModel {
      id: $id,
      name: $name,
      username: $username,
      mail: $mail,
      fechaNacimiento: $fechaNacimiento,
      isProfesor: $isProfesor,
      isAlumno: $isAlumno,
      isAdmin: $isAdmin,
      conectado: $conectado,
      lat: $lat,
      lng: $lng
    }
    ''';
  }
}
