import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/add_habit.dart';
import '../widgets/overall_progress_card.dart';
import '../widgets/days_navbar.dart';
import '../widgets/habit_card.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_dialog.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../services/habit_service.dart';
import '../services/user_profile_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Usuario"; // Se actualizará desde UserProfileService
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  Future<void> _initializeServices() async {
    if (!mounted) return;

    final habitService = Provider.of<HabitService>(context, listen: false);
    final userService = Provider.of<UserProfileService>(context, listen: false);

    await habitService.initializeHabits(date: selectedDate);
    final profile = await userService.getCurrentUserProfile();

    if (mounted && profile != null) {
      setState(() {
        userName = profile.fullName.isNotEmpty ? profile.fullName : "Usuario";
      });
    }
  }

  // Datos ahora se obtienen del HabitService
  void _editHabit(int index) async {
    final habitService = Provider.of<HabitService>(context, listen: false);
    final habitsList = habitService.habits;
    if (index >= habitsList.length) return;

    final habit = habitsList[index];
    if (!mounted) return;

    final editedHabit = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(isEditing: true, habitData: habit),
      ),
    );

    if (editedHabit != null && mounted) {
      final habitService = Provider.of<HabitService>(context, listen: false);
      await habitService.updateHabitTemplate(habit['id'], editedHabit);

      if (mounted) {
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Hábito "${editedHabit['name']}" actualizado!',
        );
      }
    }
  }

  void _deleteHabit(int index) async {
    final habitService = Provider.of<HabitService>(context, listen: false);
    final habitsList = habitService.habits;
    if (index >= habitsList.length) return;

    final habit = habitsList[index];
    final habitName = habit['name'];

    if (!mounted) return;

    final confirmed = await CustomDialog.showConfirmationDialog(
      context: context,
      title: 'Eliminar hábito',
      content: '¿Estás seguro de que quieres eliminar "$habitName"?',
      confirmText: 'Eliminar',
      isDangerous: true,
    );

    if (confirmed == true && mounted) {
      final habitService = Provider.of<HabitService>(context, listen: false);
      await habitService.deleteHabit(habit['id']);

      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Hábito "$habitName" eliminado',
        );
      }
    }
  } // Método para incrementar progreso según el tipo de hábito

  void _incrementHabit(int index) {
    final habitService = Provider.of<HabitService>(context, listen: false);
    final habitsList = habitService.habits;
    if (index >= habitsList.length) return;

    final habit = habitsList[index];
    habitService.incrementHabit(habit['habitId']);
  }

  // Método para decrementar progreso según el tipo de hábito
  void _decrementHabit(int index) {
    final habitService = Provider.of<HabitService>(context, listen: false);
    final habitsList = habitService.habits;
    if (index >= habitsList.length) return;

    final habit = habitsList[index];
    habitService.decrementHabit(habit['habitId']);
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
    // Generar últimos 7 días con hoy al final (derecha)
    return List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));
  }

  @override
  Widget build(BuildContext context) {
    final String today = _getFormattedDate(selectedDate);
    final weekDays = _getWeekDays();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Text(
              "Hola, $userName 👋",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDark ? Colors.white : themeProvider.primaryColor,
              ),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark
              ? Colors.white
              : context.read<ThemeProvider>().primaryColor,
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
              if (newHabit != null && mounted) {
                final habitService = Provider.of<HabitService>(
                  context,
                  listen: false,
                );
                await habitService.addHabit(newHabit);

                if (mounted) {
                  CustomSnackBar.showSuccess(
                    context: context,
                    message:
                        'Hábito "${newHabit['name']}" creado exitosamente!',
                  );
                }
              }
            },
            icon: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Icon(
                  Icons.add,
                  size: 28,
                  color: isDark ? Colors.white : themeProvider.primaryColor,
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<HabitService>(
        builder: (context, habitService, child) {
          if (habitService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (habitService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${habitService.error}'),
                  ElevatedButton(
                    onPressed: () => habitService.initializeHabits(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final habits = habitService.habits;

          return Column(
            children: [
              DaysNavbar(
                weekDays: weekDays,
                selectedDate: selectedDate,
                habits: habits,
                onDateSelected: (date) async {
                  setState(() {
                    selectedDate = date;
                  });
                  // Cargar hábitos del día seleccionado
                  final habitService = Provider.of<HabitService>(context, listen: false);
                  await habitService.changeSelectedDate(date);
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
                              : AppColors.textPrimary.withValues(alpha: 0.6),
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
                            final current = (habit['current'] ?? 0).toDouble();
                            final objetivo = (habit['objetivo'] ?? 1).toDouble();
                            final progress = objetivo > 0 ? (current / objetivo).clamp(0.0, 1.0) : 0.0;
                            
                            return HabitCard(
                              name: habit['name'] ?? 'Hábito',
                              progress: progress,
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
          );
        },
      ),
    );
  }
}
