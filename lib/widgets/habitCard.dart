import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class HabitCard extends StatelessWidget {
  final String name;
  final double progress;

  const HabitCard({super.key, required this.name, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSizes.paddingSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderColor,
              color: progress == 1.0 ? AppColors.success : AppColors.primary,
              minHeight: 6,
            ),
          ),
        ),
        trailing: Icon(
          progress == 1.0 ? Icons.check_circle : Icons.circle_outlined,
          color: progress == 1.0 ? AppColors.success : AppColors.borderColor,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Hábito "$name" clickeado. Eso se marcara como completado si es booleano o se incrementará si es un contador.',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }
}
