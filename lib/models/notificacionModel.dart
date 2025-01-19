import 'package:flutter/material.dart';

class NotificacionModel {
  final String id;
  final String userId;
  final String descripcion;
  final bool leida;
  final DateTime fecha;

  NotificacionModel({
    required this.id,
    required this.userId,
    required this.descripcion,
    required this.leida,
    required this.fecha,
  });

  // Método para convertir JSON a objeto
  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['_id'],
      userId: json['userId'],
      descripcion: json['descripcion'],
      leida: json['leida'] ?? false,
      fecha: DateTime.parse(json['fecha']),
    );
  }

  // Método para convertir objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'descripcion': descripcion,
      'leida': leida,
      'fecha': fecha.toIso8601String(),
    };
  }
}
