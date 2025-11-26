import 'package:flutter/material.dart';

enum AppThemeType {
  purple, // Tema actual (morado)
  blue, // Azul
  green, // Verde
  orange, // Naranja
  pink, // Rosa
  teal, // Azul verdoso
}

class AppThemeData {
  final String name;
  final String description;
  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color accent;
  final AppThemeType type;

  const AppThemeData({
    required this.name,
    required this.description,
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.accent,
    required this.type,
  });

  // Tema morado (actual)
  static const AppThemeData purple = AppThemeData(
    name: 'Morado Evolv',
    description: 'El tema clásico de Evolv',
    primary: Color(0xFF8A69EE),
    primaryVariant: Color(0xFF6C31E5),
    secondary: Color(0xFFAC99F4),
    background: Color(0xFFF1EFFD),
    surface: Color(0xFFD0C7F9),
    accent: Color(0xFF461B9C),
    type: AppThemeType.purple,
  );

  // Tema azul
  static const AppThemeData blue = AppThemeData(
    name: 'Azul Océano',
    description: 'Tranquilidad y serenidad',
    primary: Color(0xFF2196F3),
    primaryVariant: Color(0xFF1976D2),
    secondary: Color(0xFF64B5F6),
    background: Color(0xFFE3F2FD),
    surface: Color(0xFFBBDEFB),
    accent: Color(0xFF0D47A1),
    type: AppThemeType.blue,
  );

  // Tema verde
  static const AppThemeData green = AppThemeData(
    name: 'Verde Naturaleza',
    description: 'Crecimiento y equilibrio',
    primary: Color(0xFF4CAF50),
    primaryVariant: Color(0xFF388E3C),
    secondary: Color(0xFF81C784),
    background: Color(0xFFE8F5E8),
    surface: Color(0xFFC8E6C9),
    accent: Color(0xFF1B5E20),
    type: AppThemeType.green,
  );

  // Tema naranja
  static const AppThemeData orange = AppThemeData(
    name: 'Naranja Energía',
    description: 'Vitalidad y motivación',
    primary: Color(0xFFFF9800),
    primaryVariant: Color(0xFFF57C00),
    secondary: Color(0xFFFFB74D),
    background: Color(0xFFFFF3E0),
    surface: Color(0xFFFFE0B2),
    accent: Color(0xFFE65100),
    type: AppThemeType.orange,
  );

  // Tema rosa
  static const AppThemeData pink = AppThemeData(
    name: 'Rosa Creatividad',
    description: 'Inspiración y creatividad',
    primary: Color(0xFFE91E63),
    primaryVariant: Color(0xFFC2185B),
    secondary: Color(0xFFF06292),
    background: Color(0xFFFCE4EC),
    surface: Color(0xFFF8BBD9),
    accent: Color(0xFF880E4F),
    type: AppThemeType.pink,
  );

  // Tema teal
  static const AppThemeData teal = AppThemeData(
    name: 'Turquesa Equilibrio',
    description: 'Calma y concentración',
    primary: Color(0xFF009688),
    primaryVariant: Color(0xFF00796B),
    secondary: Color(0xFF4DB6AC),
    background: Color(0xFFE0F2F1),
    surface: Color(0xFFB2DFDB),
    accent: Color(0xFF004D40),
    type: AppThemeType.teal,
  );

  static List<AppThemeData> get allThemes => [
    purple,
    blue,
    green,
    orange,
    pink,
    teal,
  ];

  static AppThemeData getThemeByType(AppThemeType type) {
    return allThemes.firstWhere((theme) => theme.type == type);
  }
}
