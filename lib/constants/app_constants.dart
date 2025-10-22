import 'package:flutter/material.dart';

// Colores de la aplicación
class AppColors {
  static const Color primaryBackground = Color(0xFFF1EFFD);
  static const Color secondaryBackground = Color(0xFFD0C7F9);
  static const Color acentoSuave = Color(0xFFAC99F4);
  static const Color primary = Color(0xFF8A69EE);
  static const Color action = Color(0xFF6C31E5);
  static const Color darkBackground = Color(0xFF461B9C);
  static const Color obscureText = Color(0xFF240A56);
  static const Color textPrimary = Color(0xFF240A56); // Agregado
  static const Color background = Color(0xFFF1EFFD); // Agregado
  static const Color error = Colors.red;
  static const Color success = Colors.green;

  // Colores de progreso
  static const Color progressExcellent = Color(0xFF4CAF50); // Verde
  static const Color progressGood = Color(0xFF8BC34A); // Verde claro
  static const Color progressRegular = Color(0xFFFFEB3B); // Amarillo
  static const Color progressLow = Color(0xFFFF9800); // Naranja
  static const Color progressVeryLow = Color(0xFFF44336); // Rojo

  // Colores de tema oscuro
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBackground2 = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);

  // Colores específicos
  static final Color shadowColor = Colors.grey.withValues(alpha: 0.5);
  static final Color borderColor = Colors.grey.shade300;
}

// Tamaños y espacios
class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadius = 12.0;
  static const double borderWidth = 1.5;

  static const double iconSizeSmall = 24.0;
  static const double iconSizeMedium = 32.0;
  static const double iconSizeLarge = 80.0;

  static const double buttonHeight = 50.0;
  static const double maxContainerWidth = 400.0;
}

// Estilos de texto
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );
}

// Configuraciones de sombras
class AppShadows {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.shadowColor,
      spreadRadius: 2,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: AppColors.shadowColor,
      spreadRadius: 1,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}

// Decoraciones comunes
class AppDecorations {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.background,
    border: Border.all(
      color: AppColors.borderColor,
      width: AppSizes.borderWidth,
    ),
    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
    boxShadow: AppShadows.cardShadow,
  );

  static InputDecoration textFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      prefixIcon: Icon(icon),
    );
  }
}
