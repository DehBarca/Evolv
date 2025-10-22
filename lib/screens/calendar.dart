import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> habits;

  const CalendarScreen({
    super.key,
    required this.selectedDate,
    required this.habits,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late ScrollController _scrollController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Simular progreso por día (en una app real vendría de una base de datos)
  double _getDayProgress(DateTime date) {
    // Para demo, usar un cálculo basado en el día del mes
    final dayOfMonth = date.day;
    final progress = (dayOfMonth % 10) / 10.0; // 0.0 a 0.9
    return progress.clamp(0.0, 1.0);
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppColors.progressExcellent;
    if (progress >= 0.6) return AppColors.progressGood;
    if (progress >= 0.4) return AppColors.progressRegular;
    if (progress >= 0.2) return AppColors.progressLow;
    return AppColors.progressVeryLow;
  }

  DateTime _getMonthFromIndex(int index) {
    final now = DateTime.now();
    // index 0 = mes actual, index 1 = mes anterior, etc.
    final targetMonth = DateTime(now.year, now.month - index, 1);
    return targetMonth;
  }

  List<DateTime?> _getCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Calcular cuántos días vacíos necesitamos al inicio
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    final emptyDays = firstWeekday - 1; // Número de días vacíos antes del 1

    final days = <DateTime?>[];

    // Agregar días vacíos
    for (int i = 0; i < emptyDays; i++) {
      days.add(null);
    }

    // Agregar días del mes
    for (int i = 0; i < lastDayOfMonth.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    return days;
  }

  String _getMonthName(DateTime month) {
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${monthNames[month.month - 1]} ${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.primary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_selectedDate),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leyenda de progreso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _LegendItem('Excelente', AppColors.progressExcellent),
                      _LegendItem('Bueno', AppColors.progressGood),
                      _LegendItem('Regular', AppColors.progressRegular),
                      _LegendItem('Bajo', AppColors.progressLow),
                      _LegendItem('Muy bajo', AppColors.progressVeryLow),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: 24, // 2 años hacia atrás
              itemBuilder: (context, index) {
                final currentMonth = _getMonthFromIndex(index);
                final calendarDays = _getCalendarDays(currentMonth);

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Título del mes
                      Text(
                        _getMonthName(currentMonth),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Encabezado de días de la semana
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _DayHeader('Lun'),
                          _DayHeader('Mar'),
                          _DayHeader('Mié'),
                          _DayHeader('Jue'),
                          _DayHeader('Vie'),
                          _DayHeader('Sáb'),
                          _DayHeader('Dom'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grid del calendario
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: calendarDays.length,
                        itemBuilder: (context, gridIndex) {
                          final date = calendarDays[gridIndex];

                          if (date == null) {
                            // Día vacío
                            return Container();
                          }

                          final progress = _getDayProgress(date);
                          final isSelected =
                              date.year == _selectedDate.year &&
                              date.month == _selectedDate.month &&
                              date.day == _selectedDate.day;
                          final isToday =
                              date.year == DateTime.now().year &&
                              date.month == DateTime.now().month &&
                              date.day == DateTime.now().day;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                              });
                              Navigator.of(context).pop(date);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.action
                                    : theme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: isToday && !isSelected
                                    ? Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      )
                                    : isDark
                                    ? Border.all(
                                        color: AppColors.darkSurface,
                                        width: 1,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.action.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  // Número del día
                                  Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                      ),
                                    ),
                                  ),

                                  // Indicador de progreso (barra inferior)
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    right: 4,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkSurface
                                            : AppColors.borderColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: progress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getProgressColor(progress),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Leyenda de colores (solo en el primer mes)
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String day;

  const _DayHeader(this.day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white70
                : AppColors.textPrimary.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
