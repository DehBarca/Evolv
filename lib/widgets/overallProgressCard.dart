import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class OverallProgressCard extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const OverallProgressCard({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double avgProgress =
        habits.map((h) => h['progress'] as double).reduce((a, b) => a + b) /
        habits.length;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Progreso de hoy",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadius / 2,
                    ),
                    child: LinearProgressIndicator(
                      value: avgProgress,
                      backgroundColor: AppColors.borderColor,
                      color: AppColors.primary,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    "${(avgProgress * 100).toInt()}% completado",
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            Icon(
              Icons.insights,
              color: AppColors.primary,
              size: AppSizes.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }
}
