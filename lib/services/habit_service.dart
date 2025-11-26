import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitService extends ChangeNotifier {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _habits = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Datos por defecto para usuarios nuevos
  final List<Map<String, dynamic>> _defaultHabits = [
    {
      "id": "habit_1",
      "name": "Correr",
      "progress": 0.0,
      "type": "time",
      "target": 30,
      "increment": 5,
      "description": "Ejercicio cardiovascular diario",
      "category": "Salud",
    },
    {
      "id": "habit_2",
      "name": "Leer 20 min",
      "progress": 0.0,
      "type": "time",
      "target": 20,
      "increment": 5,
      "description": "Lectura diaria para crecimiento personal",
      "category": "Educación",
    },
    {
      "id": "habit_3",
      "name": "Meditar",
      "progress": 0.0,
      "type": "time",
      "target": 15,
      "increment": 5,
      "description": "Meditación mindfulness",
      "category": "Bienestar",
    },
    {
      "id": "habit_4",
      "name": "Beber agua",
      "progress": 0.0,
      "type": "count",
      "target": 8,
      "increment": 1,
      "description": "Mantener hidratación adecuada",
      "category": "Salud",
    },
    {
      "id": "habit_5",
      "name": "Estudiar",
      "progress": 0.0,
      "type": "time",
      "target": 60,
      "increment": 15,
      "description": "Estudio académico o profesional",
      "category": "Educación",
    },
    {
      "id": "habit_6",
      "name": "3 obras buenas",
      "progress": 0.0,
      "type": "count",
      "target": 3,
      "increment": 1,
      "description": "Actos de bondad diarios",
      "category": "Personal",
    },
    {
      "id": "habit_7",
      "name": "Ejercicio",
      "progress": 0.0,
      "type": "count",
      "target": 1,
      "increment": 1,
      "description": "Rutina de ejercicios",
      "category": "Salud",
    },
  ];

  Future<void> initializeHabits() async {
    if (_userId.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('habits')
          .get();

      if (docSnapshot.docs.isEmpty) {
        // Usuario nuevo, crear hábitos por defecto
        await _createDefaultHabits();
      } else {
        // Cargar hábitos existentes
        _habits = docSnapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      }
    } catch (e) {
      _error = 'Error al cargar hábitos: $e';
      debugPrint('Error initializing habits: $e');
      // En caso de error, usar datos locales
      _habits = List.from(_defaultHabits);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createDefaultHabits() async {
    try {
      final batch = _firestore.batch();

      for (final habit in _defaultHabits) {
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('habits')
            .doc(habit['id']);

        batch.set(docRef, {
          ...habit,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      _habits = List.from(_defaultHabits);
    } catch (e) {
      debugPrint('Error creating default habits: $e');
      _habits = List.from(_defaultHabits);
    }
  }

  Future<void> addHabit(Map<String, dynamic> habitData) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final newHabit = {
        ...habitData,
        'id': id,
        'progress': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_userId.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('habits')
            .doc(id)
            .set(newHabit);
      }

      _habits.add(newHabit);
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar hábito: $e';
      debugPrint('Error adding habit: $e');
      notifyListeners();
    }
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> updates) async {
    try {
      final updatedData = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_userId.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('habits')
            .doc(habitId)
            .update(updatedData);
      }

      final habitIndex = _habits.indexWhere((h) => h['id'] == habitId);
      if (habitIndex != -1) {
        _habits[habitIndex] = {..._habits[habitIndex], ...updates};
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar hábito: $e';
      debugPrint('Error updating habit: $e');
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      if (_userId.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('habits')
            .doc(habitId)
            .delete();
      }

      _habits.removeWhere((h) => h['id'] == habitId);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar hábito: $e';
      debugPrint('Error deleting habit: $e');
      notifyListeners();
    }
  }

  void incrementHabit(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h['id'] == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final double currentProgress = habit['progress'] ?? 0.0;
    final int target = habit['target'] ?? 1;
    final int increment = habit['increment'] ?? 1;

    if (currentProgress < 1.0) {
      final double progressIncrement = increment / target;
      final newProgress = (currentProgress + progressIncrement).clamp(0.0, 1.0);

      updateHabit(habitId, {'progress': newProgress});
    }
  }

  void decrementHabit(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h['id'] == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final double currentProgress = habit['progress'] ?? 0.0;
    final int target = habit['target'] ?? 1;
    final int increment = habit['increment'] ?? 1;

    if (currentProgress > 0.0) {
      final double progressDecrement = increment / target;
      final newProgress = (currentProgress - progressDecrement).clamp(0.0, 1.0);

      updateHabit(habitId, {'progress': newProgress});
    }
  }

  double get overallProgress {
    if (_habits.isEmpty) return 0.0;

    final totalProgress = _habits.fold(
      0.0,
      (total, habit) => total + (habit['progress'] ?? 0.0),
    );
    return totalProgress / _habits.length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetDailyProgress() {
    for (int i = 0; i < _habits.length; i++) {
      _habits[i]['progress'] = 0.0;
    }

    // Actualizar en Firestore si es necesario
    if (_userId.isNotEmpty) {
      final batch = _firestore.batch();

      for (final habit in _habits) {
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('habits')
            .doc(habit['id']);

        batch.update(docRef, {
          'progress': 0.0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      batch.commit().catchError((e) {
        debugPrint('Error resetting daily progress: $e');
      });
    }

    notifyListeners();
  }
}
