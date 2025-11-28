import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../services/habit_service.dart';

class HabitDetailScreen extends StatefulWidget {
  final Map<String, dynamic> habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground2
          : AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground2
            : AppColors.primaryBackground,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : themeProvider.primaryColor,
        ),
        title: Text(
          widget.habit['name'] ?? 'Detalle del hábito',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<HabitService>(
        builder: (context, habitService, child) {
          // Buscar el hábito actualizado en el servicio
          final updatedHabit = habitService.habits.firstWhere(
            (h) => h['habitId'] == widget.habit['habitId'],
            orElse: () => widget.habit,
          );

          final current = (updatedHabit['current'] ?? 0).toDouble();
          final objetivo = (updatedHabit['objetivo'] ?? 1).toDouble();
          final progress = objetivo > 0
              ? (current / objetivo).clamp(0.0, 1.0)
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta principal del hábito
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre y progreso
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                updatedHabit['name'] ?? 'Hábito',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _toggleHabit(context, updatedHabit),
                              child: Icon(
                                progress == 1.0
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: progress == 1.0
                                    ? AppColors.success
                                    : themeProvider.primaryColor,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Barra de progreso
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
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Progreso numérico
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso: ${current.toInt()}/${objetivo.toInt()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Controles de incremento/decremento
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Controles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Botón decrementar
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: current > 0
                                    ? () {
                                        _decrementHabit(context, updatedHabit);
                                      }
                                    : null,
                                icon: const Icon(Icons.remove),
                                label: const Text('Reducir'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: current > 0
                                      ? themeProvider.primaryColor
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botón incrementar
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: current < objetivo
                                    ? () {
                                        _incrementHabit(context, updatedHabit);
                                      }
                                    : null,
                                icon: const Icon(Icons.add),
                                label: const Text('Incrementar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: current < objetivo
                                      ? themeProvider.primaryColor
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botón completar
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: progress < 1.0
                                    ? () {
                                        _completeHabit(context, updatedHabit);
                                      }
                                    : null,
                                icon: const Icon(Icons.done_all),
                                label: const Text('Completar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: progress < 1.0
                                      ? AppColors.success
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Información del hábito
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del hábito',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoRow(
                          'Objetivo diario',
                          '${objetivo.toInt()}',
                          Icons.flag_outlined,
                          isDark,
                        ),
                        const Divider(height: 24),

                        _buildInfoRow(
                          'Incremento',
                          '${updatedHabit['increment'] ?? 1}',
                          Icons.add_circle_outline,
                          isDark,
                        ),
                        const Divider(height: 24),

                        _buildInfoRow(
                          'Categoría',
                          '${updatedHabit['category'] ?? 'Sin categoría'}',
                          Icons.category_outlined,
                          isDark,
                        ),
                        const Divider(height: 24),

                        _buildInfoRow(
                          'Tipo',
                          '${updatedHabit['type'] ?? 'Numérico'}',
                          Icons.type_specimen_outlined,
                          isDark,
                        ),
                        if (updatedHabit['description'] != null &&
                            updatedHabit['description']
                                .toString()
                                .isNotEmpty) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Descripción',
                            updatedHabit['description'],
                            Icons.description_outlined,
                            isDark,
                          ),
                        ],
                        const Divider(height: 24),

                        _buildInfoRow(
                          'Creado',
                          updatedHabit['createdAt'] != null
                              ? _formatDate(
                                  DateTime.parse(updatedHabit['createdAt']),
                                )
                              : 'Desconocido',
                          Icons.calendar_today_outlined,
                          isDark,
                        ),

                        if (progress == 1.0) ...[
                          const Divider(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.celebration_outlined,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '¡Objetivo completado! 🎉',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleHabit(BuildContext context, Map<String, dynamic> habit) {
    final habitService = Provider.of<HabitService>(context, listen: false);
    final current = (habit['current'] ?? 0).toDouble();
    final objetivo = (habit['objetivo'] ?? 1).toDouble();
    final progress = objetivo > 0 ? (current / objetivo).clamp(0.0, 1.0) : 0.0;

    if (progress >= 1.0) {
      // Si está completo, resetear a 0
      habitService.updateHabit(habit['habitId'], 0);
    } else {
      // Si no está completo, completar al 100%
      habitService.updateHabit(habit['habitId'], objetivo.toInt());
    }
  }

  void _completeHabit(BuildContext context, Map<String, dynamic> habit) {
    final habitService = Provider.of<HabitService>(context, listen: false);
    final current = (habit['current'] ?? 0).toDouble();
    final objetivo = (habit['objetivo'] ?? 1).toDouble();

    if (current < objetivo) {
      // Establecer el progreso directamente al objetivo completo
      habitService.updateHabit(habit['habitId'], objetivo.toInt());
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Colors.white70 : AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _incrementHabit(BuildContext context, Map<String, dynamic> habit) {
    final habitService = Provider.of<HabitService>(context, listen: false);
    habitService.incrementHabit(habit['habitId']);
  }

  void _decrementHabit(BuildContext context, Map<String, dynamic> habit) {
    final habitService = Provider.of<HabitService>(context, listen: false);
    habitService.decrementHabit(habit['habitId']);
  }
}
