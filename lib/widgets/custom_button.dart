import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
  });

  const CustomButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
  }) : type = ButtonType.primary;

  const CustomButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
  }) : type = ButtonType.secondary;

  const CustomButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
  }) : type = ButtonType.outline;

  const CustomButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
  }) : type = ButtonType.danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determinar colores según el tipo
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = theme.primaryColor;
        foregroundColor = Colors.white;
        break;
      case ButtonType.secondary:
        backgroundColor = isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.borderColor;
        foregroundColor = isDark ? Colors.white : Colors.black87;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.primaryColor;
        borderColor = theme.primaryColor;
        break;
      case ButtonType.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
    }

    // Determinar tamaños según el size
    EdgeInsetsGeometry buttonPadding;
    double fontSize;
    double iconSize;

    switch (size) {
      case ButtonSize.small:
        buttonPadding = const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall * 1.5,
          vertical: AppSizes.paddingSmall,
        );
        fontSize = 14;
        iconSize = 16;
        break;
      case ButtonSize.medium:
        buttonPadding = const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall * 1.5,
        );
        fontSize = 16;
        iconSize = 18;
        break;
      case ButtonSize.large:
        buttonPadding = const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        );
        fontSize = 18;
        iconSize = 20;
        break;
    }

    Widget buttonChild = isLoading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && !isLoading) ...[
                Icon(icon, size: iconSize, color: foregroundColor),
                const SizedBox(width: AppSizes.paddingSmall),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          );

    if (type == ButtonType.outline) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding ?? buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius:
                  borderRadius ?? BorderRadius.circular(AppSizes.borderRadius),
            ),
            side: BorderSide(color: borderColor ?? theme.primaryColor),
            foregroundColor: foregroundColor,
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding ?? buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppSizes.borderRadius),
          ),
          elevation: type == ButtonType.secondary ? 0 : 2,
        ),
        child: buttonChild,
      ),
    );
  }
}

enum ButtonType { primary, secondary, outline, danger }

enum ButtonSize { small, medium, large }
