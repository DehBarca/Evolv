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
    if (progress >= 0.8) return AppColors.success;
    if (progress >= 0.6) return Colors.lightGreen;
    if (progress >= 0.4) return Colors.yellow;
    if (progress >= 0.2) return Colors.orange;
    return AppColors.error;
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
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Calendario',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_selectedDate),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: AppSizes.paddingMedium,
            right: AppSizes.paddingMedium,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                boxShadow: AppShadows.cardShadow,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leyenda de progreso',
                    style: AppTextStyles.bodyText,
                  ),
                  SizedBox(height: AppSizes.paddingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _LegendItem('Excelente', Colors.green),
                      _LegendItem('Bueno', Colors.lightGreen),
                      _LegendItem('Regular', Colors.yellow),
                      _LegendItem('Bajo', Colors.orange),
                      _LegendItem('Muy bajo', Colors.red),
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
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    children: [
                      Text(
                        _getMonthName(currentMonth),
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),

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
                      const SizedBox(height: AppSizes.paddingMedium),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              crossAxisSpacing: AppSizes.paddingSmall,
                              mainAxisSpacing: AppSizes.paddingSmall,
                            ),
                        itemCount: calendarDays.length,
                        itemBuilder: (context, gridIndex) {
                          final date = calendarDays[gridIndex];

                          if (date == null) {
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
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                border: isToday && !isSelected
                                    ? Border.all(
                                        color: AppColors.primary,
                                        width: AppSizes.borderWidth,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? AppShadows.buttonShadow
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
                                            ? AppColors.background
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),

                                  // Indicador de progreso (barra inferior)
                                  Positioned(
                                    bottom: AppSizes.paddingSmall / 2,
                                    left: AppSizes.paddingSmall / 2,
                                    right: AppSizes.paddingSmall / 2,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppColors.borderColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: progress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getProgressColor(progress),
                                            borderRadius: BorderRadius.circular(2),
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
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.borderColor,
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