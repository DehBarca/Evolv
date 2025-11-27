import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_template.dart';
import '../models/habit.dart';
import '../models/daily_progress.dart';

class HabitService extends ChangeNotifier {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HabitTemplate> _habitTemplates = [];
  List<Habit> _dailyHabits = [];
  List<Map<String, dynamic>> _habits = []; // Mantener compatibilidad temporal
  DateTime _selectedDate = DateTime.now();
  DateTime? _oldestHabitDate;
  bool _isLoading = false;
  String? _error;

  List<HabitTemplate> get habitTemplates => _habitTemplates;
  List<Habit> get dailyHabits => _dailyHabits;
  List<Map<String, dynamic>> get habits => _habits;
  DateTime get selectedDate => _selectedDate;
  DateTime? get oldestHabitDate => _oldestHabitDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Templates por defecto para usuarios nuevos
  List<HabitTemplate> _getDefaultTemplates() {
    final now = DateTime.now();
    return [
      HabitTemplate(
        id: "template_1",
        userId: _userId,
        titulo: "Correr",
        description: "Ejercicio cardiovascular diario",
        type: "time",
        objetivo: 30,
        increment: 5,
        category: "Salud",
        activeDays: [1, 2, 3, 4, 5, 6, 7], // Todos los días
        createdAt: now,
        updatedAt: now,
      ),
      HabitTemplate(
        id: "template_2",
        userId: _userId,
        titulo: "Leer 20 min",
        description: "Lectura diaria para crecimiento personal",
        type: "time",
        objetivo: 20,
        increment: 5,
        category: "Educación",
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        createdAt: now,
        updatedAt: now,
      ),
      HabitTemplate(
        id: "template_3",
        userId: _userId,
        titulo: "Meditar",
        description: "Meditación mindfulness",
        type: "time",
        objetivo: 15,
        increment: 5,
        category: "Bienestar",
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        createdAt: now,
        updatedAt: now,
      ),
      HabitTemplate(
        id: "template_4",
        userId: _userId,
        titulo: "Beber agua",
        description: "Mantener hidratación adecuada",
        type: "count",
        objetivo: 8,
        increment: 1,
        category: "Salud",
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        createdAt: now,
        updatedAt: now,
      ),
      HabitTemplate(
        id: "template_5",
        userId: _userId,
        titulo: "Estudiar",
        description: "Estudio académico o profesional",
        type: "time",
        objetivo: 60,
        increment: 15,
        category: "Educación",
        activeDays: [1, 2, 3, 4, 5],
        createdAt: now,
        updatedAt: now,
      ),
      HabitTemplate(
        id: "template_6",
        userId: _userId,
        titulo: "3 obras buenas",
        description: "Actos de bondad diarios",
        type: "count",
        objetivo: 3,
        increment: 1,
        category: "Personal",
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> initializeHabits({DateTime? date}) async {
    if (_userId.isEmpty) return;

    _isLoading = true;
    _error = null;
    _selectedDate = date ?? DateTime.now();
    notifyListeners();

    try {
      await _loadHabitTemplates();
      await _loadDailyHabits(_selectedDate);
      
      if (_dailyHabits.isEmpty && _habitTemplates.isNotEmpty) {
        await _createMissingDailyHabits(_selectedDate);
      }
      
      await _getOldestHabitDate();
      _generateLegacyHabitsData();

    } catch (e) {
      _error = 'Error al cargar hábitos: $e';
      if (_habitTemplates.isEmpty) {
        _habitTemplates = _getDefaultTemplates();
      }
      if (_dailyHabits.isEmpty) {
        _dailyHabits = [];
      }
      _generateLegacyHabitsData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Cargar templates del usuario
  Future<void> _loadHabitTemplates() async {
    try {
      final snapshot = await _firestore
          .collection('habit_templates')
          .where('userId', isEqualTo: _userId)
          .get();

      if (snapshot.docs.isEmpty) {
        await _createDefaultTemplates();
      } else {
        _habitTemplates = snapshot.docs
            .map((doc) => HabitTemplate.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      }
    } catch (e) {
      _habitTemplates = _getDefaultTemplates();
    }
  }

  // Crear templates por defecto
  Future<void> _createDefaultTemplates() async {
    try {
      final defaultTemplates = _getDefaultTemplates();
      final batch = _firestore.batch();

      for (final template in defaultTemplates) {
        final docRef = _firestore
            .collection('habit_templates')
            .doc(template.id);

        batch.set(docRef, template.toMap());
      }

      await batch.commit();
      _habitTemplates = defaultTemplates;
    } catch (e) {
      _habitTemplates = _getDefaultTemplates();
    }
  }

  // Cargar hábitos del día seleccionado
  Future<void> _loadDailyHabits(DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      final snapshot = await _firestore
          .collection('habits')
          .where('idUser', isEqualTo: _userId)
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .get();

      _dailyHabits = snapshot.docs
          .map((doc) {
            try {
              return Habit.fromMap({...doc.data(), 'id': doc.id});
            } catch (e) {
              return null;
            }
          })
          .where((habit) => habit != null)
          .cast<Habit>()
          .toList();
    } catch (e) {
      _dailyHabits = [];
    }
  }

  // Obtener fecha del hábito más antiguo
  Future<void> _getOldestHabitDate() async {
    try {
      final snapshot = await _firestore
          .collection('habits')
          .where('idUser', isEqualTo: _userId)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        DateTime? oldestDate;
        
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            final timestamp = data['date'] as Timestamp;
            final habitDate = timestamp.toDate();
            final normalizedDate = DateTime(habitDate.year, habitDate.month, habitDate.day);
            
            if (oldestDate == null || normalizedDate.isBefore(oldestDate)) {
              oldestDate = normalizedDate;
            }
          } catch (e) {
            // Ignorar documentos con fechas inválidas
          }
        }
        
        _oldestHabitDate = oldestDate ?? DateTime.now();
      } else {
        _oldestHabitDate = DateTime.now();
      }
      
    } catch (e) {
      _oldestHabitDate = DateTime.now();
    }
  }

  // Generar datos legacy para compatibilidad
  void _generateLegacyHabitsData() {
    try {
      if (_dailyHabits.isEmpty) {
        _habits = [];
        return;
      }
      
      _habits = _dailyHabits.map((habit) {
        HabitTemplate? template;
        try {
          template = _habitTemplates.firstWhere((t) => t.id == habit.idTemplate);
        } catch (e) {
          template = null;
        }
        
        if (template == null) return null;
        
        if (template.deleted) {
          final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          final habitDate = DateTime(habit.date.year, habit.date.month, habit.date.day);
          
          if (habitDate.isAfter(today) || habitDate.isAtSameMomentAs(today)) {
            return null;
          }
        }
        
        final progress = template.objetivo > 0 ? (habit.value / template.objetivo).clamp(0.0, 1.0) : 0.0;
        
        return {
          'id': template.id,
          'habitId': habit.id,
          'name': template.titulo,
          'icon': '📝',
          'current': habit.value.round(),
          'increment': template.increment,
          'objetivo': template.objetivo,
          'progress': progress,
          'category': template.category,
          'color': '#6B7280',
        };
      }).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      _habits = [];
    }
  }

  // Crear hábitos diarios faltantes para el día especificado
  Future<void> _createMissingDailyHabits(DateTime date) async {
    try {
      final now = DateTime.now();
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dayOfWeek = date.weekday;
      
      final activeTemplates = _habitTemplates.where((template) {
        return template.activeDays.contains(dayOfWeek) && !template.deleted;
      }).toList();
      
      for (final template in activeTemplates) {
        final existingHabits = _dailyHabits.where((h) => h.idTemplate == template.id);
        if (existingHabits.isNotEmpty) continue;
        
        final habit = Habit(
          id: '',
          idUser: _userId,
          idTemplate: template.id,
          date: normalizedDate,
          value: 0.0,
          createdAt: now,
          updatedAt: now,
        );

        try {
          final docRef = await _firestore
              .collection('habits')
              .add(habit.toMap());

          final createdHabit = habit.copyWith(id: docRef.id);
          _dailyHabits.add(createdHabit);
        } catch (e) {
          // Error creating habit, skip
        }
      }
    } catch (e) {
      // Error creating missing habits
    }
  }

  // Cambiar fecha seleccionada
  Future<void> changeSelectedDate(DateTime newDate) async {
    // Actualizar daily_progress del día anterior antes de cambiar
    if (_dailyHabits.isNotEmpty) {
      await _updateDailyProgress(_selectedDate);
    }
    
    _selectedDate = newDate;
    
    // Cargar hábitos existentes del día
    await _loadDailyHabits(_selectedDate);
    
    // Crear hábitos faltantes para templates activos en este día
    await _createMissingDailyHabits(_selectedDate);
    
    // Regenerar datos para la UI
    _generateLegacyHabitsData();
    notifyListeners();
  }

  // Crear hábito diario si no existe
  Future<void> _createDailyHabitIfNotExists(String templateId, DateTime date) async {
    Habit? existingHabit;
    try {
      existingHabit = _dailyHabits.firstWhere((h) => h.idTemplate == templateId);
    } catch (e) {
      existingHabit = null;
    }

    if (existingHabit == null) {
      final now = DateTime.now();
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      final newHabit = Habit(
        id: '',
        idUser: _userId,
        idTemplate: templateId,
        date: normalizedDate,
        value: 0.0,
        createdAt: now,
        updatedAt: now,
      );

      try {
        final docRef = await _firestore
            .collection('habits')
            .add(newHabit.toMap());

        final createdHabit = newHabit.copyWith(id: docRef.id);
        _dailyHabits.add(createdHabit);
        _generateLegacyHabitsData();
        await _updateDailyProgress(date);
        notifyListeners();
      } catch (e) {
        // Error creating habit
      }
    }
  }

  // Actualizar template de hábito (para pantalla de edición)
  Future<void> updateHabitTemplate(String id, Map<String, dynamic> updates) async {
    try {
      final templateIndex = _habitTemplates.indexWhere((t) => t.id == id);
      if (templateIndex == -1) {
        _error = 'Template de hábito no encontrado';
        notifyListeners();
        return;
      }

      final currentTemplate = _habitTemplates[templateIndex];
      
      if (_userId.isNotEmpty) {
        try {
          final docSnapshot = await _firestore
              .collection('habit_templates')
              .doc(id)
              .get();

          if (!docSnapshot.exists) {
            await _firestore
                .collection('habit_templates')
                .doc(id)
                .set(currentTemplate.toMap());
          }

          final updatedData = {
            ...updates,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await _firestore
              .collection('habit_templates')
              .doc(id)
              .update(updatedData);
        } catch (firestoreError) {
          // Error de Firestore, continuar con actualización local
        }
      }

      final updatedTemplate = HabitTemplate(
        id: currentTemplate.id,
        userId: currentTemplate.userId,
        titulo: updates['name'] ?? currentTemplate.titulo,
        description: updates['description'] ?? currentTemplate.description,
        type: updates['type'] ?? currentTemplate.type,
        objetivo: updates['target'] ?? currentTemplate.objetivo,
        increment: updates['increment'] ?? currentTemplate.increment,
        category: updates['categoryName'] ?? currentTemplate.category,
        activeDays: updates['activeDays'] ?? currentTemplate.activeDays,
        deleted: updates['deleted'] ?? currentTemplate.deleted,
        createdAt: currentTemplate.createdAt,
        updatedAt: DateTime.now(),
      );

      _habitTemplates[templateIndex] = updatedTemplate;
      _generateLegacyHabitsData();
      notifyListeners();
      
    } catch (e) {
      _error = 'Error al actualizar template de hábito: $e';
      notifyListeners();
    }
  }

  Future<void> addHabit(Map<String, dynamic> habitData) async {
    try {
      final now = DateTime.now();
      final templateId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final newTemplate = HabitTemplate(
        id: templateId,
        userId: _userId,
        titulo: habitData['name'] ?? '',
        description: habitData['description'] ?? '',
        type: habitData['type'] ?? 'count',
        objetivo: habitData['target'] ?? 1,
        increment: habitData['increment'] ?? 1,
        category: habitData['categoryName'] ?? 'General',
        activeDays: (habitData['activeDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [1, 2, 3, 4, 5, 6, 7],
        createdAt: now,
        updatedAt: now,
      );

      if (_userId.isNotEmpty) {
        await _firestore
            .collection('habit_templates')
            .doc(templateId)
            .set(newTemplate.toMap());
      }

      _habitTemplates.add(newTemplate);
      
      final selectedDayOfWeek = _selectedDate.weekday;
      if (newTemplate.activeDays.contains(selectedDayOfWeek)) {
        await _createDailyHabitIfNotExists(templateId, _selectedDate);
      }
      
      _generateLegacyHabitsData();
      notifyListeners();
      
    } catch (e) {
      _error = 'Error al agregar hábito: $e';
      notifyListeners();
    }
  }

  // Actualizar progreso de hábito diario
  Future<void> updateHabit(String id, int newValue) async {
    if (_userId.isEmpty) return;

    try {
      final habitIndex = _dailyHabits.indexWhere((h) => h.id == id);
      if (habitIndex != -1) {
        await _firestore
            .collection('habits')
            .doc(id)
            .update({
          'value': newValue.toDouble(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _dailyHabits[habitIndex] = _dailyHabits[habitIndex].copyWith(
          value: newValue.toDouble(),
          updatedAt: DateTime.now(),
        );
        _generateLegacyHabitsData();
        await _updateDailyProgress(_selectedDate);
        notifyListeners();
        return;
      }

      final legacyHabitIndex = _habits.indexWhere((h) => h['id'] == id);
      if (legacyHabitIndex != -1) {
        final templateId = id;
        await _createDailyHabitIfNotExists(templateId, _selectedDate);
        
        final newHabitIndex = _dailyHabits.indexWhere((h) => h.idTemplate == templateId);
        if (newHabitIndex != -1) {
          final habitId = _dailyHabits[newHabitIndex].id;
          await _firestore
              .collection('habits')
              .doc(habitId)
              .update({
            'value': newValue.toDouble(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          _dailyHabits[newHabitIndex] = _dailyHabits[newHabitIndex].copyWith(
            value: newValue.toDouble(),
            updatedAt: DateTime.now(),
          );
          _generateLegacyHabitsData();
          await _updateDailyProgress(_selectedDate);
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Error al actualizar hábito: $e';
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await updateHabitTemplate(habitId, {
        'deleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _generateLegacyHabitsData();
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar hábito: $e';
      notifyListeners();
    }
  }
  // Método para restaurar un hábito eliminado (opcional)
  Future<void> restoreHabit(String habitId) async {
    try {
      await updateHabitTemplate(habitId, {
        'deleted': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      _generateLegacyHabitsData();
      await _createMissingDailyHabits(_selectedDate);
      notifyListeners();
    } catch (e) {
      _error = 'Error al restaurar hábito: $e';
      notifyListeners();
    }
  }

  void incrementHabit(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h['habitId'] == habitId);
    if (habitIndex == -1) return;
    final habit = _habits[habitIndex];
    final int currentValue = habit['current'] ?? 0;
    final int incrementValue = habit['increment'] ?? 1;
    final int objetivo = habit['objetivo'] ?? 1;

    if (currentValue < objetivo) {
      final newValue = currentValue + incrementValue;
      updateHabit(habit['habitId'], newValue);
    }
  }

  void decrementHabit(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h['habitId'] == habitId);
    if (habitIndex == -1) return;
    final habit = _habits[habitIndex];
    final int currentValue = habit['current'] ?? 0;
    final int incrementValue = habit['increment'] ?? 1;

    if (currentValue > 0) {
      final newValue = (currentValue - incrementValue).clamp(0, double.infinity).toInt();
      updateHabit(habit['habitId'], newValue);
    }
  }
  double get overallProgress {
    if (_habits.isEmpty) return 0.0;
    final totalProgress = _habits.fold(
      0.0,
      (total, habit) {
        final current = (habit['current'] ?? 0).toDouble();
        final objetivo = (habit['objetivo'] ?? 1).toDouble();
        final progress = objetivo > 0 ? (current / objetivo).clamp(0.0, 1.0) : 0.0;
        return total + progress;
      },
    );
    return totalProgress / _habits.length;
  }

  /// Obtiene la racha actual del usuario (días consecutivos con actividad)
  /// Obtiene el total de templates de hábitos activos del usuario
  Future<int> getTotalActiveTemplates() async {
    if (_userId.isEmpty) return 0;
    
    try {
      final snapshot = await _firestore
          .collection('habit_templates')
          .where('userId', isEqualTo: _userId)
          .where('deleted', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting total templates: $e');
      return _habitTemplates.length;
    }
  }

  /// Obtiene el progreso general actual basado en los hábitos del día
  Future<double> getCurrentOverallProgress() async {
    if (_userId.isEmpty) return 0.0;
    
    try {
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      
      // Obtener hábitos del día actual
      final habits = await _loadHabitsForDate(normalizedToday);
      
      if (habits.isEmpty) {
        return 0.0;
      }
      
      // Calcular progreso promedio
      double totalProgress = 0.0;
      for (final habit in habits) {
        totalProgress += habit.value.clamp(0.0, 1.0);
      }
      
      return totalProgress / habits.length;
    } catch (e) {
      debugPrint('Error calculating current overall progress: $e');
      return overallProgress; // Fallback al método anterior
    }
  }

  /// Obtiene la racha actual usando la nueva colección daily_progress
  Future<int> getStreakFromDailyProgress() async {
    if (_userId.isEmpty) return 0;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int streak = 0;
      DateTime checkDate = today;

      // Revisar historial hacia atrás hasta encontrar un día sin actividad
      for (int i = 0; i < 365; i++) {
        final hasActivity = await _hasActivityOnDateNew(checkDate);

        if (hasActivity) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          // Si es hoy y no hay actividad, la racha es 0
          if (i == 0) return 0;
          break;
        }
      }

      return streak;
    } catch (e) {
      debugPrint('Error calculating streak from daily progress: $e');
      return getCurrentStreak(); // Fallback al método anterior
    }
  }

  /// Verifica si hay actividad en una fecha usando la nueva estructura
  Future<bool> _hasActivityOnDateNew(DateTime date) async {
    if (_userId.isEmpty) return false;

    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // Buscar en la colección daily_progress
      final snapshot = await _firestore
          .collection('daily_progress')
          .where('idUser', isEqualTo: _userId)
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final progress = DailyProgress.fromMap(snapshot.docs.first.data());
        return progress.overallProgress > 0.0;
      }

      // Si no existe en daily_progress, buscar en habits del día
      final habits = await _loadHabitsForDate(normalizedDate);
      return habits.any((habit) => habit.value > 0.0);
    } catch (e) {
      debugPrint('Error checking activity for date $date: $e');
      return false;
    }
  }

  Future<int> getCurrentStreak() async {
    if (_userId.isEmpty) return 0;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int streak = 0;
      DateTime checkDate = today;

      // Revisar historial hacia atrás hasta encontrar un día sin actividad
      for (int i = 0; i < 365; i++) {
        // Limitar a 1 año
        final dateStr = _formatDate(checkDate);
        final hasActivity = await _hasActivityOnDate(dateStr);

        if (hasActivity) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          // Si es hoy y no hay actividad, la racha es 0
          if (i == 0) return 0;
          break;
        }
      }

      return streak;
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return 0;
    }
  }

  Future<bool> _hasActivityOnDate(String dateStr) async {
    if (_userId.isEmpty) return false;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('habit_history')
          .doc(dateStr)
          .get();

      if (!snapshot.exists) return false;

      final data = snapshot.data();
      if (data == null) return false;

      // Verificar si algún hábito tuvo progreso ese día
      final habits = data['habits'] as List<dynamic>?;
      if (habits == null || habits.isEmpty) return false;

      return habits.any((h) => (h['progress'] ?? 0.0) > 0.0);
    } catch (e) {
      debugPrint('Error checking activity for date $dateStr: $e');
      return false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Guarda el progreso del día en el historial
  Future<void> saveDailyProgress() async {
    if (_userId.isEmpty || _habits.isEmpty) return;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateStr = _formatDate(today);

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('habit_history')
          .doc(dateStr)
          .set({
            'date': Timestamp.fromDate(today),
            'habits': _habits
                .map(
                  (h) => {
                    'id': h['id'],
                    'name': h['name'],
                    'progress': h['progress'],
                    'completed': (h['progress'] ?? 0.0) >= 1.0,
                  },
                )
                .toList(),
            'overallProgress': overallProgress,
            'savedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error saving daily progress: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> resetDailyProgress() async {
    try {
      if (_userId.isNotEmpty) {
        final batch = _firestore.batch();
        for (final habit in _dailyHabits) {
          final docRef = _firestore
              .collection('habits')
              .doc(habit.id);
          batch.update(docRef, {
            'value': 0.0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
      for (int i = 0; i < _dailyHabits.length; i++) {
        _dailyHabits[i] = _dailyHabits[i].copyWith(value: 0.0);
      }
      _generateLegacyHabitsData();
      notifyListeners();
    } catch (e) {
      // Error resetting progress
    }
  }

  // ===== MÉTODOS PARA CALENDARIO =====
  /// Obtiene el progreso promedio de todos los hábitos para una fecha específica
  Future<double> getDayProgress(DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final selectedNormalized = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      if (normalizedDate.isAtSameMomentAs(selectedNormalized) && _habits.isNotEmpty) {
        final totalProgress = _habits.fold(0.0, (sum, habit) => sum + (habit['progress'] as double));
        return totalProgress / _habits.length;
      }
      final dayHabits = await _loadHabitsForDate(normalizedDate);
      if (dayHabits.isEmpty) {
        return 0.0;
      }
      double totalProgress = 0.0;
      int validHabits = 0;
      
      for (final habit in dayHabits) {
        try {
          final template = _habitTemplates.firstWhere(
            (t) => t.id == habit.idTemplate,
            orElse: () => throw 'Template not found'
          );
          if (template.deleted) {
            final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
            final habitDate = DateTime(habit.date.year, habit.date.month, habit.date.day);
            if (habitDate.isAfter(today) || habitDate.isAtSameMomentAs(today)) {
              continue;
            }
          }
          final progress = template.objetivo > 0 ? (habit.value / template.objetivo).clamp(0.0, 1.0) : 0.0;
          totalProgress += progress;
          validHabits++;
        } catch (e) {
          // Skip invalid habits
        }
      }
      return validHabits > 0 ? totalProgress / validHabits : 0.0;
    } catch (e) {
      return 0.0;
    }
  }
  /// Obtiene la fecha del hábito más antiguo para optimizar el rango del calendario
  DateTime getOldestHabitDate() {
    // Si ya se calculó la fecha más antigua, usarla
    if (_oldestHabitDate != null) {
      return _oldestHabitDate!;
    }
    
    // Fallback: usar fecha de hoy si no hay hábitos históricos
    return DateTime.now();
  }
  /// Carga hábitos para una fecha específica (sin cambiar _selectedDate)
  Future<List<Habit>> _loadHabitsForDate(DateTime date) async {
    if (_userId.isEmpty) return [];
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final timestamp = Timestamp.fromDate(normalizedDate);
      final querySnapshot = await _firestore
          .collection('habits')
          .where('idUser', isEqualTo: _userId)
          .where('date', isEqualTo: timestamp)
          .get();
      final habits = <Habit>[];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final habit = Habit.fromMap({...data, 'id': doc.id});
          habits.add(habit);
        } catch (e) {
          // Skip invalid documents
        }
      }
      return habits;
    } catch (e) {
      return [];
    }
  }
  // ===== MÉTODOS PARA DAILY PROGRESS =====
  /// Actualiza el progreso diario en la colección daily_progress
  Future<void> _updateDailyProgress(DateTime date) async {
    if (_userId.isEmpty) return;
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      double totalProgress = 0.0;
      int totalHabits = 0;
      int completedHabits = 0;
      
      for (final habit in _dailyHabits) {
        final template = _habitTemplates.firstWhere(
          (t) => t.id == habit.idTemplate && !t.deleted,
          orElse: () => throw 'Template not found'
        );
        final progress = template.objetivo > 0 
            ? (habit.value / template.objetivo).clamp(0.0, 1.0) 
            : 0.0;
        totalProgress += progress;
        totalHabits++;
        if (progress >= 1.0) {
          completedHabits++;
        }
      }
      final overallProgress = totalHabits > 0 ? totalProgress / totalHabits : 0.0;
      final progressId = '${_userId}_${normalizedDate.toIso8601String().split('T')[0]}';
      final now = DateTime.now();
      final dailyProgress = DailyProgress(
        id: progressId,
        idUser: _userId,
        date: normalizedDate,
        overallProgress: overallProgress,
        totalHabits: totalHabits,
        completedHabits: completedHabits,
        createdAt: now,
        updatedAt: now,
      );
      await _firestore
          .collection('daily_progress')
          .doc(progressId)
          .set(dailyProgress.toMap(), SetOptions(merge: true));
    } catch (e) {
      // Error updating daily progress
    }
  }
  /// Obtiene progresos diarios para un rango de fechas (para calendario)
  Future<Map<String, double>> getDailyProgressRange(DateTime startDate, DateTime endDate) async {
    if (_userId.isEmpty) return {};
    
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final querySnapshot = await _firestore
          .collection('daily_progress')
          .where('idUser', isEqualTo: _userId)
          .get();
      final progressMap = <String, double>{};
      
      for (final doc in querySnapshot.docs) {
        try {
          final progress = DailyProgress.fromMap({...doc.data(), 'id': doc.id});
          if (progress.date.isAfter(end) || progress.date.isBefore(start)) {
            continue;
          }
          final dateKey = '${progress.date.year}-${progress.date.month}-${progress.date.day}';
          progressMap[dateKey] = progress.overallProgress;
        } catch (e) {
          // Skip invalid documents
        }
      }
      return progressMap;
    } catch (e) {
      final progressMap = <String, double>{};
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      final endDate_norm = DateTime(endDate.year, endDate.month, endDate.day);

      while (currentDate.isBefore(endDate_norm) || currentDate.isAtSameMomentAs(endDate_norm)) {
        final progress = await getDayProgress(currentDate);
        final dateKey = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
        progressMap[dateKey] = progress;
        currentDate = currentDate.add(const Duration(days: 1));
        
        if (progressMap.length > 90) break;
      }
      return progressMap;
    }
  }
}
