import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String userId;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a Map para JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'colorValue': color.value,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear desde Map de JSON
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: _getIconFromMap(map),
      color: Color(map['colorValue'] ?? 0xFF2196F3),
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Helper para obtener icon de forma segura
  static IconData _getIconFromMap(Map<String, dynamic> map) {
    final codePoint = map['iconCodePoint'];
    final fontFamily = map['iconFontFamily'];
    
    if (codePoint != null) {
      return IconData(
        codePoint,
        fontFamily: fontFamily,
      );
    }
    
    return Icons.category; // Icono por defecto constante
  }

  // Copiar con modificaciones
  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    String? userId,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
