import 'package:a/screens/addHabit.dart';
import 'package:flutter/material.dart';
import '../widgets/overallProgressCard.dart';
import '../widgets/daysNavbar.dart';
import '../widgets/habitCard.dart';
import '../constants/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String userName = "Diego";

  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> habits = [
    {"name": "Correr", "progress": 0.8},
    {"name": "Leer 20 min", "progress": 0.5},
    {"name": "Meditar", "progress": 0.2},
    {"name": "Beber agua", "progress": 1.0},
    {"name": "Estudiar", "progress": 0.4},
    {"name": "3 obras buenas", "progress": 0.66},
  ];

  String _getFormattedDate(DateTime date) {
    final weekdays = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];
    final months = [
      "enero",
      "febrero",
      "marzo",
      "abril",
      "mayo",
      "junio",
      "julio",
      "agosto",
      "septiembre",
      "octubre",
      "noviembre",
      "diciembre",
    ];

    String dayName = weekdays[date.weekday - 1];
    String monthName = months[date.month - 1];

    return "$dayName, ${date.day} de $monthName";
  }

  List<DateTime> _getWeekDays() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final String today = _getFormattedDate(selectedDate);
    final weekDays = _getWeekDays();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hola, $userName 👋",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.primary,
        ),
      ),
      body: Column(
        children: [
          DaysNavbar(
            weekDays: weekDays,
            selectedDate: selectedDate,
            habits: habits,
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    today,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progreso general
                  OverallProgressCard(habits: habits),

                  const SizedBox(height: 24),
                  Text(
                    "Tus hábitos de hoy",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDark ? Colors.white : AppColors.obscureText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Lista de hábitos
                  Expanded(
                    child: ListView.builder(
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return HabitCard(
                          name: habit['name'],
                          progress: habit['progress'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newHabit = await Navigator.of(context)
              .push<Map<String, dynamic>>(
                MaterialPageRoute(builder: (context) => const AddHabitScreen()),
              );
          if (newHabit != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hábito "${newHabit['name']}" creado exitosamente!',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        backgroundColor: AppColors.acentoSuave,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
