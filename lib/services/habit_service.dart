import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_template.dart';
import '../models/habit.dart';

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
      // Cargar templates del usuario
      await _loadHabitTemplates();
      
      // Cargar hábitos del día seleccionado
      await _loadDailyHabits(_selectedDate);
      
      // Si no hay hábitos diarios, crear algunos de ejemplo
      if (_dailyHabits.isEmpty && _habitTemplates.isNotEmpty) {
        await _createMissingDailyHabits(_selectedDate);
      }
      
      // Obtener fecha del hábito más antiguo
      await _getOldestHabitDate();
      
      // Generar datos temporales para compatibilidad
      _generateLegacyHabitsData();
      
    } catch (e) {
      _error = 'Error al cargar hábitos: $e';
      debugPrint('Error initializing habits: $e');
      // Asegurar que tenemos datos mínimos para evitar crashes
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
        // Usuario nuevo, crear templates por defecto
        await _createDefaultTemplates();
      } else {
        _habitTemplates = snapshot.docs
            .map((doc) => HabitTemplate.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading habit templates: $e');
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
      debugPrint('Error creating default templates: $e');
      _habitTemplates = _getDefaultTemplates();
    }
  }

  // Cargar hábitos del día seleccionado
  Future<void> _loadDailyHabits(DateTime date) async {
    try {
      // Normalizar fecha para comparar solo día/mes/año sin hora
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
              debugPrint('Error parsing habit: $e');
              return null;
            }
          })
          .where((habit) => habit != null)
          .cast<Habit>()
          .toList();
          
      debugPrint('Loaded ${_dailyHabits.length} habits for ${normalizedDate.toIso8601String().split('T')[0]}');
    } catch (e) {
      debugPrint('Error loading daily habits: $e');
      _dailyHabits = [];
    }
  }

  // Obtener fecha del hábito más antiguo
  Future<void> _getOldestHabitDate() async {
    try {
      // Por ahora usar fecha actual hasta crear el índice en Firebase
      // TODO: Crear índice compuesto en Firebase Console para idUser + date
      _oldestHabitDate = DateTime.now().subtract(const Duration(days: 30));
      
      // Código para cuando se cree el índice:
      // final snapshot = await _firestore
      //     .collection('habits')
      //     .where('idUser', isEqualTo: _userId)
      //     .orderBy('date', descending: false)
      //     .limit(1)
      //     .get();
      //
      // if (snapshot.docs.isNotEmpty) {
      //   final oldestTimestamp = snapshot.docs.first.data()['date'] as Timestamp;
      //   _oldestHabitDate = oldestTimestamp.toDate();
      // } else {
      //   _oldestHabitDate = DateTime.now();
      // }
    } catch (e) {
      debugPrint('Error getting oldest habit date: $e');
      _oldestHabitDate = DateTime.now().subtract(const Duration(days: 30));
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
        
        if (template == null) {
          // No incluir hábitos con templates que no existen
          return null;
        }
        
        // Si el template está eliminado, solo mostrar hábitos anteriores a hoy
        if (template.deleted) {
          final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          final habitDate = DateTime(habit.date.year, habit.date.month, habit.date.day);
          
          if (habitDate.isAfter(today) || habitDate.isAtSameMomentAs(today)) {
            return null; // No mostrar hábitos de hoy en adelante para templates eliminados
          }
          // Continuar mostrando hábitos anteriores
        }
        
        final progress = template.objetivo > 0 ? (habit.value / template.objetivo).clamp(0.0, 1.0) : 0.0;
        
        return {
          'id': template.id,      // ✨ ID del template para edición
          'habitId': habit.id,    // ✨ ID del hábito para progreso
          'name': template.titulo,
          'icon': '📝', // Icono por defecto hasta que se agregue al modelo
          'current': habit.value.round(),
          'increment': template.increment,
          'objetivo': template.objetivo,
          'progress': progress,
          'category': template.category,
          'color': '#6B7280', // Color por defecto
        };
      }).whereType<Map<String, dynamic>>().toList(); // ✨ Filtrar nulls (templates eliminados)
    } catch (e) {
      debugPrint('Error generating legacy habits data: $e');
      _habits = [];
    }
  }

  // Crear hábitos diarios faltantes para el día especificado
  Future<void> _createMissingDailyHabits(DateTime date) async {
    try {
      final now = DateTime.now();
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dayOfWeek = date.weekday; // 1=Lunes, 7=Domingo
      
      debugPrint('Creating missing habits for ${normalizedDate.toIso8601String().split('T')[0]}, day of week: $dayOfWeek');
      
      // Filtrar templates que son activos para el día seleccionado Y NO eliminados
      final activeTemplates = _habitTemplates.where((template) {
        return template.activeDays.contains(dayOfWeek) && !template.deleted;
      }).toList();
      
      debugPrint('Found ${activeTemplates.length} active templates for this day');
      
      for (final template in activeTemplates) {
        // Verificar que no exista ya un hábito para este día y template
        final existingHabits = _dailyHabits.where((h) => h.idTemplate == template.id);
        if (existingHabits.isNotEmpty) {
          debugPrint('Habit for template ${template.titulo} already exists, skipping');
          continue; // Ya existe, saltar
        }
        
        debugPrint('Creating habit for template: ${template.titulo}');
        
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
          debugPrint('Created habit with ID: ${docRef.id}');
        } catch (e) {
          debugPrint('Error creating daily habit for template ${template.titulo}: $e');
        }
      }
      
      debugPrint('Final daily habits count: ${_dailyHabits.length}');
    } catch (e) {
      debugPrint('Error creating missing daily habits: $e');
    }
  }

  // Cambiar fecha seleccionada
  Future<void> changeSelectedDate(DateTime newDate) async {
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
        notifyListeners();
      } catch (e) {
        debugPrint('Error creating daily habit: $e');
      }
    }
  }

  // Actualizar template de hábito (para pantalla de edición)
  Future<void> updateHabitTemplate(String id, Map<String, dynamic> updates) async {
    try {
      // Primero verificar si el template existe localmente
      final templateIndex = _habitTemplates.indexWhere((t) => t.id == id);
      if (templateIndex == -1) {
        debugPrint('Template with ID $id not found locally');
        _error = 'Template de hábito no encontrado';
        notifyListeners();
        return;
      }

      final currentTemplate = _habitTemplates[templateIndex];
      
      // Verificar si el documento existe en Firestore antes de actualizar
      if (_userId.isNotEmpty) {
        try {
          final docSnapshot = await _firestore
              .collection('habit_templates')
              .doc(id)
              .get();

          if (!docSnapshot.exists) {
            debugPrint('Template document $id does not exist in Firestore, creating it');
            // Si no existe, crear el template en Firestore
            await _firestore
                .collection('habit_templates')
                .doc(id)
                .set(currentTemplate.toMap());
          }

          // Ahora sí actualizar con los nuevos datos
          final updatedData = {
            ...updates,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await _firestore
              .collection('habit_templates')
              .doc(id)
              .update(updatedData);
              
        } catch (firestoreError) {
          debugPrint('Error with Firestore operation: $firestoreError');
          // Si hay error de Firestore, continuar con actualización local
        }
      }

      // Actualizar localmente en templates
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
        deleted: updates['deleted'] ?? currentTemplate.deleted, // ✨ Agregar campo deleted
        createdAt: currentTemplate.createdAt,
        updatedAt: DateTime.now(),
      );

      _habitTemplates[templateIndex] = updatedTemplate;
      _generateLegacyHabitsData();
      notifyListeners();
      
    } catch (e) {
      _error = 'Error al actualizar template de hábito: $e';
      debugPrint('Error updating habit template: $e');
      notifyListeners();
    }
  }

  Future<void> addHabit(Map<String, dynamic> habitData) async {
    try {
      final now = DateTime.now();
      final templateId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Crear template de hábito
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
        // Guardar template en Firestore
        await _firestore
            .collection('habit_templates')
            .doc(templateId)
            .set(newTemplate.toMap());
      }

      // Agregar a la lista local
      _habitTemplates.add(newTemplate);
      
      // Crear instancia diaria si el template es activo para el día seleccionado
      final selectedDayOfWeek = _selectedDate.weekday;
      if (newTemplate.activeDays.contains(selectedDayOfWeek)) {
        await _createDailyHabitIfNotExists(templateId, _selectedDate);
      }
      
      // Regenerar datos legacy
      _generateLegacyHabitsData();
      notifyListeners();
      
    } catch (e) {
      _error = 'Error al agregar hábito: $e';
      debugPrint('Error adding habit: $e');
      notifyListeners();
    }
  }

  // Actualizar progreso de hábito diario
  Future<void> updateHabit(String id, int newValue) async {
    if (_userId.isEmpty) return;

    try {
      // Buscar en hábitos diarios
      final habitIndex = _dailyHabits.indexWhere((h) => h.id == id);
      if (habitIndex != -1) {
        // Actualizar en Firestore
        await _firestore
            .collection('habits')
            .doc(id)
            .update({
          'value': newValue.toDouble(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Actualizar localmente
        _dailyHabits[habitIndex] = _dailyHabits[habitIndex].copyWith(
          value: newValue.toDouble(),
          updatedAt: DateTime.now(),
        );
        _generateLegacyHabitsData();
        notifyListeners();
        return;
      }

      // Si no existe como hábito diario, intentar crear desde template
      final legacyHabitIndex = _habits.indexWhere((h) => h['id'] == id);
      if (legacyHabitIndex != -1) {
        // Buscar template correspondiente
        final templateId = id; // Para compatibilidad temporal
        await _createDailyHabitIfNotExists(templateId, _selectedDate);
        
        // Intentar actualizar nuevamente
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
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Error al actualizar hábito: $e';
      debugPrint('Error updating habit: $e');
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      // Soft delete: marcar template como eliminado
      await updateHabitTemplate(habitId, {
        'deleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Regenerar datos legacy sin incluir templates eliminados
      _generateLegacyHabitsData();
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar hábito: $e';
      debugPrint('Error deleting habit: $e');
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
      
      // Regenerar datos y crear hábitos para días activos
      _generateLegacyHabitsData();
      await _createMissingDailyHabits(_selectedDate);
      notifyListeners();
    } catch (e) {
      _error = 'Error al restaurar hábito: $e';
      debugPrint('Error restoring habit: $e');
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

      // Actualizar localmente
      for (int i = 0; i < _dailyHabits.length; i++) {
        _dailyHabits[i] = _dailyHabits[i].copyWith(value: 0.0);
      }
      
      _generateLegacyHabitsData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting daily progress: $e');
    }
  }

  // ===== MÉTODOS PARA CALENDARIO =====
  
  /// Obtiene el progreso promedio de todos los hábitos para una fecha específica
  /// Usa exactamente la misma lógica que el home screen
  Future<double> getDayProgress(DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final selectedNormalized = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      
      debugPrint('=== CALENDAR DEBUG for ${normalizedDate.toIso8601String().split('T')[0]} ===');
      
      // Si es el día actualmente seleccionado, usar directamente los datos de _habits
      if (normalizedDate.isAtSameMomentAs(selectedNormalized) && _habits.isNotEmpty) {
        debugPrint('✅ Using current UI data for selected date: ${_habits.length} habits');
        final totalProgress = _habits.fold(0.0, (sum, habit) => sum + (habit['progress'] as double));
        final result = totalProgress / _habits.length;
        debugPrint('📊 Result from UI data: ${(result * 100).toStringAsFixed(1)}%');
        return result;
      }
      
      // Para otros días, cargar hábitos y generar datos usando la misma lógica del home
      debugPrint('📅 Loading daily habits for other date...');
      final dayHabits = await _loadHabitsForDate(normalizedDate);
      
      if (dayHabits.isEmpty) {
        debugPrint('❌ No habits found for date');
        return 0.0;
      }
      
      // Aplicar la misma lógica de _generateLegacyHabitsData pero solo para cálculo
      double totalProgress = 0.0;
      int validHabits = 0;
      
      for (final habit in dayHabits) {
        try {
          // Buscar template correspondiente
          final template = _habitTemplates.firstWhere(
            (t) => t.id == habit.idTemplate,
            orElse: () => throw 'Template not found'
          );
          
          // Aplicar la misma lógica de filtrado del home
          if (template.deleted) {
            final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
            final habitDate = DateTime(habit.date.year, habit.date.month, habit.date.day);
            
            if (habitDate.isAfter(today) || habitDate.isAtSameMomentAs(today)) {
              continue; // Skip habits de templates eliminados para hoy en adelante
            }
          }
          
          // Calcular progreso igual que en _generateLegacyHabitsData
          final progress = template.objetivo > 0 ? (habit.value / template.objetivo).clamp(0.0, 1.0) : 0.0;
          totalProgress += progress;
          validHabits++;
          
          debugPrint('✓ ${template.titulo}: ${(progress * 100).toStringAsFixed(1)}% (${habit.value}/${template.objetivo})');
        } catch (e) {
          debugPrint('⚠️ Skipping habit ${habit.id}: $e');
        }
      }
      
      final result = validHabits > 0 ? totalProgress / validHabits : 0.0;
      debugPrint('📊 Final result: ${(result * 100).toStringAsFixed(1)}% (${validHabits} valid habits)');
      return result;
      
    } catch (e) {
      debugPrint('❌ Error getting day progress: $e');
      return 0.0;
    }
  }
  
  /// Obtiene la fecha del hábito más antiguo para optimizar el rango del calendario
  DateTime getOldestHabitDate() {
    if (_habitTemplates.isEmpty) {
      return DateTime.now(); // Si no hay hábitos, empezar desde hoy
    }
    
    // Encontrar el template más antiguo (que no esté eliminado)
    final activeTemplates = _habitTemplates.where((t) => !t.deleted);
    if (activeTemplates.isEmpty) {
      return DateTime.now();
    }
    
    final oldestTemplate = activeTemplates.reduce((a, b) => 
      a.createdAt.isBefore(b.createdAt) ? a : b
    );
    
    return DateTime(oldestTemplate.createdAt.year, oldestTemplate.createdAt.month, oldestTemplate.createdAt.day);
  }
  
  /// Carga hábitos para una fecha específica (sin cambiar _selectedDate)
  Future<List<Habit>> _loadHabitsForDate(DateTime date) async {
    if (_userId.isEmpty) {
      debugPrint('❌ UserId is empty, cannot load habits');
      return [];
    }
    
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final timestamp = Timestamp.fromDate(normalizedDate);
      
      debugPrint('🔍 Querying Firestore:');
      debugPrint('   Collection: habits');
      debugPrint('   idUser: $_userId');
      debugPrint('   date: ${normalizedDate.toIso8601String().split('T')[0]}');
      debugPrint('   timestamp: $timestamp');
      
      final querySnapshot = await _firestore
          .collection('habits')
          .where('idUser', isEqualTo: _userId)
          .where('date', isEqualTo: timestamp)
          .get();

      debugPrint('🔍 Firestore query returned ${querySnapshot.docs.length} documents');
      
      final habits = <Habit>[];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          debugPrint('   Document ${doc.id}: $data');
          final habit = Habit.fromMap({...data, 'id': doc.id});
          habits.add(habit);
        } catch (e) {
          debugPrint('❌ Error parsing document ${doc.id}: $e');
        }
      }
      
      debugPrint('✅ Successfully parsed ${habits.length} habits');
      return habits;
    } catch (e) {
      debugPrint('❌ Error loading habits for date $date: $e');
      return [];
    }
  }
}
