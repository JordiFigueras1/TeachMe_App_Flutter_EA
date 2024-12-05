import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String id; // Agregar esta propiedad
  String name;
  String mail;
  String password;
  int age;
  bool isProfesor;
  bool isAlumno;
  bool isAdmin;
  bool conectado; // Nuevo atributo

  UserModel({
    required this.id, // Requerir la propiedad id
    required this.name,
    required this.mail,
    required this.password,
    required this.age,
    this.isProfesor = false,
    this.isAlumno = false,
    this.isAdmin = true,
    this.conectado = false, // Valor predeterminado
  });

  void setUser(String id, String name, String mail, String password, int age, bool isProfesor, bool isAlumno, bool isAdmin, bool conectado) {
    this.id = id;
    this.name = name;
    this.mail = mail;
    this.password = password;
    this.age = age;
    this.isProfesor = isProfesor;
    this.isAlumno = isAlumno;
    this.isAdmin = isAdmin;
    this.conectado = conectado;
    notifyListeners();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '', // Extraer el id
      name: json['nombre'] ?? '',
      mail: json['email'] ?? '',
      password: json['password'] ?? '',
      age: json['edad'] ?? 0,
      isProfesor: json['isProfesor'] ?? false,
      isAlumno: json['isAlumno'] ?? false,
      isAdmin: json['isAdmin'] ?? true,
      conectado: json['conectado'] ?? false, // Extraer estado de conexión
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Incluir el id
      'nombre': name,
      'email': mail,
      'password': password,
      'edad': age,
      'isProfesor': isProfesor,
      'isAlumno': isAlumno,
      'isAdmin': isAdmin,
      'conectado': conectado, // Incluir estado de conexión
    };
  }
}
