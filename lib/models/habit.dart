class Habit {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String frequency;
  final String time;
  final double progress;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.frequency,
    required this.time,
    this.progress = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'frequency': frequency,
      'time': time,
      'progress': progress,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      frequency: map['frequency'] ?? 'Diario',
      time: map['time'] ?? '00:00',
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }
}
