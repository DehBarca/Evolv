import 'package:evolv/screens/addHabit.dart';
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
    {
      "name": "Correr",
      "progress": 0.8,
      "type": "time", // tiempo en minutos
      "target": 30, // 30 minutos
      "increment": 5, // incremento de 5 minutos
    },
    {
      "name": "Leer 20 min",
      "progress": 0.5,
      "type": "time",
      "target": 20, // 20 minutos
      "increment": 5, // incremento de 5 minutos
    },
    {
      "name": "Meditar",
      "progress": 0.2,
      "type": "time",
      "target": 15, // 15 minutos
      "increment": 5, // incremento de 5 minutos
    },
    {
      "name": "Beber agua",
      "progress": 1.0,
      "type": "count",
      "target": 8, // 8 vasos
      "increment": 1, // incremento de 1 vaso
    },
    {
      "name": "Estudiar",
      "progress": 0.4,
      "type": "time",
      "target": 60, // 60 minutos
      "increment": 15, // incremento de 15 minutos
    },
    {
      "name": "3 obras buenas",
      "progress": 0.66,
      "type": "count",
      "target": 3, // 3 obras
      "increment": 1, // incremento de 1 obra (33.33%)
    },
    {
      "name": "Ejercicio",
      "progress": 0,
      "type": "count",
      "target": 1, // 3 obras
      "increment": 1, // incremento de 1 obra (33.33%)
    },
  ];
  void _editHabit(int index) async {
    final habit = habits[index];

    final editedHabit = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(isEditing: true, habitData: habit),
      ),
    );

    if (editedHabit != null) {
      setState(() {
        habits[index] = editedHabit;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hábito "${editedHabit['name']}" actualizado!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _deleteHabit(int index) {
    final habitName = habits[index]['name'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar hábito'),
          content: Text('¿Estás seguro de que quieres eliminar "$habitName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  habits.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hábito "$habitName" eliminado'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para incrementar progreso según el tipo de hábito
  void _incrementHabit(int index) {
    setState(() {
      final habit = habits[index];
      final double currentProgress = habit['progress'];
      final int target = habit['target'];
      final int increment = habit['increment'];

      if (currentProgress < 1.0) {
        // Calcula el incremento como porcentaje del objetivo
        double progressIncrement = increment / target;
        habits[index]['progress'] = (currentProgress + progressIncrement).clamp(
          0.0,
          1.0,
        );
      }
    });
  }

  // Método para decrementar progreso según el tipo de hábito
  void _decrementHabit(int index) {
    setState(() {
      final habit = habits[index];
      final double currentProgress = habit['progress'];
      final int target = habit['target'];
      final int increment = habit['increment'];

      if (currentProgress > 0.0) {
        // Calcula el decremento como porcentaje del objetivo
        double progressDecrement = increment / target;
        habits[index]['progress'] = (currentProgress - progressDecrement).clamp(
          0.0,
          1.0,
        );
      }
    });
  }

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
        actions: [
          IconButton(
            onPressed: () async {
              final newHabit = await Navigator.of(context)
                  .push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder: (context) => const AddHabitScreen(),
                    ),
                  );
              if (newHabit != null) {
                setState(() {
                  habits.add(newHabit);
                });
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
            icon: Icon(
              Icons.add,
              size: 28,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
        ],
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
                          onIncrement: () => _incrementHabit(index),
                          onDecrement: () => _decrementHabit(index),
                          onLongPress: () => _deleteHabit(index),
                          onEdit: () => _editHabit(index),
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
    );
  }
}
