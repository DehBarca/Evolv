import 'package:flutter/material.dart';
import '../constants/app_constants.dart'; // Agrega esta importación

class OverallProgressCard extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const OverallProgressCard({
    super.key,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final double avgProgress =
        habits.map((h) => h['progress'] as double).reduce((a, b) => a + b) /
        habits.length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progreso de hoy",
                    style: AppTextStyles.bodyText,
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
                    child: LinearProgressIndicator(
                      value: avgProgress,
                      backgroundColor: AppColors.borderColor,
                      color: AppColors.primary,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text("${(avgProgress * 100).toInt()}% completado"),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.paddingSmall),
            Icon(Icons.insights, color: AppColors.primary, size: AppSizes.iconSizeMedium),
          ],
        ),
      ),
    );
  }
}