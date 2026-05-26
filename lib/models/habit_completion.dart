class HabitCompletion {
  final String id;
  final String habitId;
  final DateTime completedAt;
  final String note;

  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completedAt': completedAt.toIso8601String(),
      'note': note,
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'],
      habitId: map['habitId'],
      completedAt: DateTime.parse(map['completedAt']),
      note: map['note'] ?? '',
    );
  }
}
