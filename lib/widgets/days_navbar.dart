import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/calendar.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          child: Row(
            children: [
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
                icon: Icon(
                  Icons.calendar_today,
                  color: themeProvider.primaryColor,
                ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Día seleccionado: ${date.day}/${date.month}/${date.year}. Se irá al home de ese día.',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: themeProvider.primaryColor,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themeProvider.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadius,
                            ),
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: themeProvider.primaryColor,
                                    width: AppSizes.borderWidth,
                                  )
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
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white
                                            : AppColors.textPrimary),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isToday
                                            ? themeProvider.primaryColor
                                            : (isDark
                                                  ? Colors.white
                                                  : AppColors.textPrimary)),
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
      },
    );
  }
}
