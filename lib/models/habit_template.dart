import 'package:cloud_firestore/cloud_firestore.dart';

class HabitTemplate {
  final String id;
  final String userId;
  final String titulo;
  final String description;
  final String type; // 'time' o 'count'
  final int objetivo;
  final int increment;
  final String category;
  final List<int> activeDays; // 1=Lunes, 2=Martes, ..., 7=Domingo
  final bool deleted; // Para soft delete
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitTemplate({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.description,
    required this.type,
    required this.objetivo,
    required this.increment,
    required this.category,
    required this.activeDays,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'titulo': titulo,
      'description': description,
      'type': type,
      'objetivo': objetivo,
      'increment': increment,
      'category': category,
      'activeDays': activeDays,
      'deleted': deleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static HabitTemplate fromMap(Map<String, dynamic> map) {
    return HabitTemplate(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      titulo: map['titulo'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'count',
      objetivo: map['objetivo'] ?? 1,
      increment: map['increment'] ?? 1,
      category: map['category'] ?? '',
      activeDays: List<int>.from(map['activeDays'] ?? []),
      deleted: map['deleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  HabitTemplate copyWith({
    String? id,
    String? userId,
    String? titulo,
    String? description,
    String? type,
    int? objetivo,
    int? increment,
    String? category,
    List<int>? activeDays,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitTemplate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titulo: titulo ?? this.titulo,
      description: description ?? this.description,
      type: type ?? this.type,
      objetivo: objetivo ?? this.objetivo,
      increment: increment ?? this.increment,
      category: category ?? this.category,
      activeDays: activeDays ?? this.activeDays,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}