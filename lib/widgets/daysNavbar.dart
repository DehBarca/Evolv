import 'package:flutter/material.dart';
import '../screens/calendar.dart'; // Ajusta la ruta según tu estructura
import '../constants/app_constants.dart'; // Agrega esta importación

class DaysNavbar extends StatefulWidget {
  final List<DateTime> weekDays;
  final DateTime selectedDate;
  final List<Map<String, dynamic>> habits;
  final Function(DateTime) onDateSelected;

  const DaysNavbar({
    super.key,
    required this.weekDays,
    required this.selectedDate,
    required this.habits,
    required this.onDateSelected,
  });

  @override
  State<DaysNavbar> createState() => _DaysNavbarState();
}

class _DaysNavbarState extends State<DaysNavbar> {
  String _getShortDayName(DateTime date) {
    const shortDays = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    return shortDays[date.weekday - 1];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: AppSizes.paddingSmall),
      child: Row(
        children: [
          // Botón para abrir calendario completo
          IconButton(
            onPressed: () async {
              final selectedDateFromCalendar = await Navigator.of(context)
                  .push<DateTime>(
                    MaterialPageRoute(
                      builder: (context) => CalendarScreen(
                        selectedDate: widget.selectedDate,
                        habits: widget.habits,
                      ),
                    ),
                  );

              if (selectedDateFromCalendar != null) {
                widget.onDateSelected(selectedDateFromCalendar);
              }
            },
            icon: Icon(Icons.calendar_today, color: AppColors.primary),
            tooltip: 'Ver calendario completo',
          ),

          // Espacio entre botón y días
          const SizedBox(width: AppSizes.paddingSmall),

          // Días de la semana
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.weekDays.map((date) {
                final isSelected = _isSameDay(date, widget.selectedDate);
                final isToday = _isSameDay(date, DateTime.now());

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onDateSelected(date);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.primary, width: AppSizes.borderWidth)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getShortDayName(date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.background
                                  : (isToday
                                        ? AppColors.primary
                                        : AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}