import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  AppThemeData _currentTheme = AppThemeData.purple;
  static const String _themeKey = 'selected_theme';

  AppThemeData get currentTheme => _currentTheme;
  AppThemeType get currentThemeType => _currentTheme.type;

  ThemeProvider() {
    _loadTheme();
  }

  // Cargar tema guardado
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeTypeString = prefs.getString(_themeKey);

      if (themeTypeString != null) {
        final themeType = AppThemeType.values.firstWhere(
          (type) => type.toString() == themeTypeString,
          orElse: () => AppThemeType.purple,
        );
        _currentTheme = AppThemeData.getThemeByType(themeType);
        notifyListeners();
      }
    } catch (e) {
      // En caso de error, usar tema por defecto
      _currentTheme = AppThemeData.purple;
    }
  }

  // Cambiar tema
  Future<void> setTheme(AppThemeType themeType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeType.toString());

      _currentTheme = AppThemeData.getThemeByType(themeType);
      notifyListeners();
    } catch (e) {
      // Manejar error silenciosamente
      debugPrint('Error saving theme: $e');
    }
  }

  // Obtener colores actuales para uso en widgets
  Color get primaryColor => _currentTheme.primary;
  Color get primaryVariantColor => _currentTheme.primaryVariant;
  Color get secondaryColor => _currentTheme.secondary;
  Color get backgroundColor => _currentTheme.background;
  Color get surfaceColor => _currentTheme.surface;
  Color get accentColor => _currentTheme.accent;
}
