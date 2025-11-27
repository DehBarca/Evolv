import 'package:cloud_firestore/cloud_firestore.dart';

class DailyProgress {
  final String id;
  final String idUser;
  final DateTime date;
  final double overallProgress; // Progreso promedio de todos los hábitos del día (0.0 a 1.0)
  final int totalHabits; // Número total de hábitos activos en ese día
  final int completedHabits; // Número de hábitos completados (progreso >= 1.0)
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyProgress({
    required this.id,
    required this.idUser,
    required this.date,
    required this.overallProgress,
    required this.totalHabits,
    required this.completedHabits,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idUser': idUser,
      'date': Timestamp.fromDate(date),
      'overallProgress': overallProgress,
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DailyProgress fromMap(Map<String, dynamic> map) {
    return DailyProgress(
      id: map['id'] ?? '',
      idUser: map['idUser'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      overallProgress: (map['overallProgress'] ?? 0.0).toDouble(),
      totalHabits: map['totalHabits'] ?? 0,
      completedHabits: map['completedHabits'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  DailyProgress copyWith({
    String? id,
    String? idUser,
    DateTime? date,
    double? overallProgress,
    int? totalHabits,
    int? completedHabits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyProgress(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      date: date ?? this.date,
      overallProgress: overallProgress ?? this.overallProgress,
      totalHabits: totalHabits ?? this.totalHabits,
      completedHabits: completedHabits ?? this.completedHabits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailyProgress{id: $id, idUser: $idUser, date: $date, overallProgress: $overallProgress, totalHabits: $totalHabits, completedHabits: $completedHabits}';
  }
}