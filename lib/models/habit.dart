import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String idUser;
  final String idTemplate;
  final DateTime date;
  final double value; // progreso de 0.0 a 1.0
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    required this.id,
    required this.idUser,
    required this.idTemplate,
    required this.date,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idUser': idUser,
      'idTemplate': idTemplate,
      'date': Timestamp.fromDate(date),
      'value': value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static Habit fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      idUser: map['idUser'] ?? '',
      idTemplate: map['idTemplate'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      value: (map['value'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Habit copyWith({
    String? id,
    String? idUser,
    String? idTemplate,
    DateTime? date,
    double? value,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      idTemplate: idTemplate ?? this.idTemplate,
      date: date ?? this.date,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
