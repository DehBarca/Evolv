import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../services/habit_service.dart';

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
  
  // Cache para el progreso de días cargado en batch
  final Map<String, double> _dayProgressCache = {};
  DateTime? _oldestHabitDate;
  bool _isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _scrollController = ScrollController();
    
    // Ejecutar la inicialización después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeDateRange();
      }
    });
  }

  void _initializeDateRange() async {
    if (!mounted) return;
    
    final habitService = Provider.of<HabitService>(context, listen: false);
    _oldestHabitDate = habitService.getOldestHabitDate();
    debugPrint('Oldest habit date: $_oldestHabitDate');
    
    // Cargar TODOS los progresos en una sola consulta
    await _loadAllProgressInBatch();
    
    // Marcar carga como completada y actualizar UI
    if (mounted) {
      setState(() {
        _isLoadingProgress = false;
      });
    }
  }
  
  /// Carga TODOS los progresos de una sola vez usando daily_progress
  Future<void> _loadAllProgressInBatch() async {
    if (!mounted || _oldestHabitDate == null) return;
    
    try {
      final habitService = Provider.of<HabitService>(context, listen: false);
      final now = DateTime.now();
      debugPrint('🔄 Loading ALL daily progress from ${_oldestHabitDate!.toIso8601String().split('T')[0]} to ${now.toIso8601String().split('T')[0]}');
      
      // UNA SOLA consulta para obtener TODOS los progresos
      final progressMap = await habitService.getDailyProgressRange(_oldestHabitDate!, now);
      
      // Solo actualizar si el widget sigue montado
      if (!mounted) return;
      
      // Llenar el caché con los datos obtenidos
      _dayProgressCache.clear();
      _dayProgressCache.addAll(progressMap);
      
      debugPrint('✅ Loaded ${progressMap.length} progress records in ONE batch query');
      
      // Debugear algunos datos cargados (limitar para evitar spam)
      int count = 0;
      progressMap.forEach((date, progress) {
        if (count < 5) { // Solo mostrar los primeros 5
          debugPrint('📊 $date: ${(progress * 100).toStringAsFixed(1)}%');
          count++;
        }
      });
      
      if (progressMap.length > 5) {
        debugPrint('📊 ... and ${progressMap.length - 5} more records');
      }
      
    } catch (e) {
      debugPrint('❌ Error loading progress in batch: $e');
    }
  }
  
  // Calcular el número de meses a mostrar basado en el rango real
  int _getMonthCount() {
    if (_oldestHabitDate == null) return 12; // Default: 1 año
    
    final now = DateTime.now();
    final oldestMonth = DateTime(_oldestHabitDate!.year, _oldestHabitDate!.month);
    final currentMonth = DateTime(now.year, now.month);
    
    // Calcular diferencia en meses
    int monthDiff = ((currentMonth.year - oldestMonth.year) * 12) + (currentMonth.month - oldestMonth.month);
    
    // Agregar 1 porque incluimos el mes actual
    monthDiff += 1;
    
    // Limitar a un máximo razonable (ej: 36 meses = 3 años)
    return monthDiff.clamp(1, 36);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Obtener progreso DIRECTAMENTE del caché (sin consultas individuales)
  double _getDayProgress(DateTime date) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    
    // Si la fecha está fuera del rango válido, return 0
    if (_oldestHabitDate != null && date.isBefore(_oldestHabitDate!)) {
      return 0.0;
    }
    
    if (date.isAfter(DateTime.now())) {
      return 0.0;
    }
    
    // USAR SOLAMENTE LOS DATOS DEL CACHÉ (ya cargados en batch)
    return _dayProgressCache[dateKey] ?? 0.0;
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppColors.progressExcellent;
    if (progress >= 0.6) return AppColors.progressGood;
    if (progress >= 0.4) return AppColors.progressRegular;
    if (progress >= 0.2) return AppColors.progressLow;
    return AppColors.progressVeryLow;
  }

  DateTime _getMonthFromIndex(int index) {
    if (_oldestHabitDate == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month - index, 1);
    }
    
    // Calcular desde el mes más antiguo hacia adelante
    final oldestMonth = DateTime(_oldestHabitDate!.year, _oldestHabitDate!.month, 1);
    final targetMonth = DateTime(oldestMonth.year, oldestMonth.month + index, 1);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer2<ThemeProvider, HabitService>(
      builder: (context, themeProvider, habitService, child) {
        // Esperar a que los templates estén cargados Y el progreso esté cargado
        if (habitService.habitTemplates.isEmpty || _isLoadingProgress) {
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
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
              color: isDark ? Colors.white : themeProvider.primaryColor,
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
                              color: Colors.black.withValues(alpha: 0.1),
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
                  itemCount: _getMonthCount(), // Rango dinámico basado en hábitos
                  itemBuilder: (context, index) {
                    final currentMonth = _getMonthFromIndex(index);
                    final calendarDays = _getCalendarDays(currentMonth);

                    return Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        children: [
                          Text(
                            _getMonthName(currentMonth),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
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

                              final isSelected =
                                  date.year == _selectedDate.year &&
                                  date.month == _selectedDate.month &&
                                  date.day == _selectedDate.day;
                              final isToday =
                                  date.year == DateTime.now().year &&
                                  date.month == DateTime.now().month &&
                                  date.day == DateTime.now().day;

                              // Obtener progreso directamente del caché (ya cargado en batch)
                              final progress = _getDayProgress(date);
                              
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
                                        ? themeProvider.primaryColor
                                        : theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isToday && !isSelected
                                        ? Border.all(
                                            color: themeProvider.primaryColor,
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
                                              color: themeProvider.primaryColor
                                                  .withValues(alpha: 0.3),
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
                                        bottom: AppSizes.paddingSmall / 2,
                                        left: AppSizes.paddingSmall / 2,
                                        right: AppSizes.paddingSmall / 2,
                                        child: Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.darkSurface
                                                : AppColors.borderColor,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: progress,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _getProgressColor(
                                                  progress,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ), // Cierre del Container
                              ); // Cierre del GestureDetector
                              }, // Cierre del itemBuilder
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
      },
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
                : AppColors.textPrimary.withValues(alpha: 0.6),
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
