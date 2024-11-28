import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String name;
  String mail;
  String password;
  int age;
  bool isProfesor;
  bool isAlumno;
  bool isAdmin;

  UserModel({
    required this.name,
    required this.mail,
    required this.password,
    required this.age,
    this.isProfesor = false,
    this.isAlumno = false,
    this.isAdmin = true,
  });

  void setUser(String name, String mail, String password, int age, bool isProfesor, bool isAlumno, bool isAdmin) {
    this.name = name;
    this.mail = mail;
    this.password = password;
    this.age = age;
    this.isProfesor = isProfesor;
    this.isAlumno = isAlumno;
    this.isAdmin = isAdmin;
    notifyListeners();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['nombre'] ?? '',
      mail: json['email'] ?? '',
      password: json['password'] ?? '',
      age: json['edad'] ?? 0,
      isProfesor: json['isProfesor'] ?? false,
      isAlumno: json['isAlumno'] ?? false,
      isAdmin: json['isAdmin'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'email': mail,
      'password': password,
      'edad': age,
      'isProfesor': isProfesor,
      'isAlumno': isAlumno,
      'isAdmin': isAdmin,
    };
  }
}
