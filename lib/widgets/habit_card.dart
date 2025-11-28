import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';

class HabitCard extends StatelessWidget {
  final String name;
  final double progress;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const HabitCard({
    super.key,
    required this.name,
    required this.progress,
    this.onIncrement,
    this.onDecrement,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            elevation: 1.5,
            margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (onEdit != null)
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit),
                          iconSize: 18,
                          color: isDark
                              ? Colors.white70
                              : AppColors.obscureText,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 18,
                          color: AppColors.error,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onToggle,
                        child: Icon(
                          progress == 1.0
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: progress == 1.0
                              ? AppColors.success
                              : (onToggle != null
                                    ? themeProvider.primaryColor
                                    : AppColors.borderColor),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadius / 2,
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.borderColor,
                      color: progress == 1.0
                          ? AppColors.success
                          : themeProvider.primaryColor,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white70
                              : AppColors.obscureText,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: progress > 0 ? onDecrement : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 20,
                            color: progress > 0
                                ? themeProvider.primaryColor
                                : AppColors.borderColor,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: progress < 1.0 ? onIncrement : null,
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 20,
                            color: progress < 1.0
                                ? themeProvider.primaryColor
                                : AppColors.borderColor,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
