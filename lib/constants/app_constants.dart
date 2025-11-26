import 'package:flutter/material.dart';

// Colores de la aplicación (tema por defecto - morado)
class AppColors {
  static const Color primaryBackground = Color(0xFFF1EFFD);
  static const Color secondaryBackground = Color(0xFFD0C7F9);
  static const Color acentoSuave = Color(0xFFAC99F4);
  static const Color primary = Color(0xFF8A69EE);
  static const Color action = Color(0xFF6C31E5);
  static const Color darkBackground = Color(0xFF461B9C);
  static const Color obscureText = Color(0xFF240A56);
  static const Color textPrimary = Color(0xFF240A56);
  static const Color textSecondary = Color(0xFF666666);
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
  static Color get shadowColor => Colors.grey.withValues(alpha: 0.5);
  static Color get borderColor => Colors.grey.shade300;
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

  // Elevation levels
  static const double elevationLow = 1.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;
}

// Utilidades de estilo comunes
class AppStyles {
  // Text Styles
  static TextStyle headlineStyle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: AppSizes.fontSizeXLarge,
      fontWeight: FontWeight.bold,
      color: color ?? Theme.of(context).textTheme.headlineMedium?.color,
    );
  }

  static TextStyle titleStyle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: AppSizes.fontSizeLarge,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).textTheme.titleLarge?.color,
    );
  }

  static TextStyle bodyStyle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: AppSizes.fontSizeMedium,
      fontWeight: FontWeight.normal,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle captionStyle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: AppSizes.fontSizeSmall,
      fontWeight: FontWeight.w400,
      color: color ?? Theme.of(context).textTheme.bodySmall?.color,
    );
  }

  // Card Decorations
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: AppSizes.elevationMedium,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration inputDecoration(
    BuildContext context, {
    bool hasError = false,
  }) {
    return BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceVariant.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      border: Border.all(
        color: hasError ? AppColors.error : AppColors.borderColor,
        width: hasError ? 2 : 1,
      ),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall * 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: AppSizes.elevationMedium,
    );
  }

  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.styleFrom(
      backgroundColor: isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.borderColor,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall * 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: AppSizes.elevationLow,
    );
  }

  // Layout Utilities
  static EdgeInsetsGeometry get defaultPadding =>
      const EdgeInsets.all(AppSizes.paddingMedium);

  static EdgeInsetsGeometry get smallPadding =>
      const EdgeInsets.all(AppSizes.paddingSmall);

  static EdgeInsetsGeometry get largePadding =>
      const EdgeInsets.all(AppSizes.paddingLarge);

  static SizedBox get smallVerticalSpacing =>
      const SizedBox(height: AppSizes.paddingSmall);

  static SizedBox get mediumVerticalSpacing =>
      const SizedBox(height: AppSizes.paddingMedium);

  static SizedBox get largeVerticalSpacing =>
      const SizedBox(height: AppSizes.paddingLarge);

  static SizedBox get smallHorizontalSpacing =>
      const SizedBox(width: AppSizes.paddingSmall);

  static SizedBox get mediumHorizontalSpacing =>
      const SizedBox(width: AppSizes.paddingMedium);

  static SizedBox get largeHorizontalSpacing =>
      const SizedBox(width: AppSizes.paddingLarge);
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
    color: AppColors.primaryBackground,
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
