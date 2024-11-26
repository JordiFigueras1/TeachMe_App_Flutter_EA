import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String _name;
  String _mail;
  String _password;
  String _comment;
  String _perfil;

  // Constructor
  UserModel(
      {required String name,
      required String mail,
      required String password,
      required String perfil,
      required String comment})
      : _name = name,
        _mail = mail,
        _password = password,
        _perfil = perfil,
        _comment = comment;

  // Getters
  String get name => _name;
  String get mail => _mail;
  String get password => _password;
  String get comment => _comment;
  String get perfil => _perfil;

  // Método para actualizar el usuario
  void setUser(String name, String mail, String password, String comment,String perfil) {
    _name = name;
    _mail = mail;
    _password = password;
    _comment = comment;
    _perfil = perfil;
    notifyListeners();
  }

  // Método fromJson para crear una instancia de UserModel desde un Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? 'Usuario desconocido',
      perfil: json['perfil'] ?? 'Perfil desconocido',
      mail: json['mail'] ?? 'No especificado',
      password: json['password'] ?? 'Sin contraseña',
      comment: json['comment'] ?? 'Sin comentarios',
    );
  }

  // Método toJson para convertir una instancia de UserModel en un Map
  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'mail': _mail,
      'password': _password,
      'comment': _comment,
      'profile': _perfil,
    };
  }
}
