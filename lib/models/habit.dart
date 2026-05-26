class Habit {
  final String id;
  String title;
  String description;
  String category;
  String frequency;
  String color;
  String icon;
  int streak;
  List<String> history; // YYYY-MM-DD

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'General',
    this.frequency = 'daily',
    this.color = '#6366F1',
    this.icon = '⭐',
    this.streak = 0,
    this.history = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'frequency': frequency,
      'color': color,
      'icon': icon,
      'streak': streak,
      'history': history,
    };
  }

  factory Habit.fromMap(Map<dynamic, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      frequency: map['frequency'] ?? 'daily',
      color: map['color'] ?? '#6366F1',
      icon: map['icon'] ?? '⭐',
      streak: map['streak'] ?? 0,
      history: List<String>.from(map['history'] ?? []),
    );
  }

  Habit copyWith({
    String? title,
    String? description,
    String? category,
    String? frequency,
    String? color,
    String? icon,
    int? streak,
    List<String>? history,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      streak: streak ?? this.streak,
      history: history ?? this.history,
    );
  }
}
