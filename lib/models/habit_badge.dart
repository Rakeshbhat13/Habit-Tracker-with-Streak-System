class HabitBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final DateTime unlockedAt;
  final String habitId;

  HabitBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlockedAt,
    required this.habitId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'unlockedAt': unlockedAt.toIso8601String(),
      'habitId': habitId,
    };
  }

  factory HabitBadge.fromMap(Map<dynamic, dynamic> map) {
    return HabitBadge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
      color: map['color'],
      unlockedAt: DateTime.parse(map['unlockedAt']),
      habitId: map['habitId'],
    );
  }
}

// Predefined badge definitions
class BadgeDefinition {
  final String title;
  final String description;
  final String icon;
  final String color;
  final int requiredStreak;

  const BadgeDefinition({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredStreak,
  });
}

const List<BadgeDefinition> kBadgeDefinitions = [
  BadgeDefinition(
    title: 'First Step',
    description: 'Completed a habit for the first time',
    icon: '👣',
    color: '#4CAF50',
    requiredStreak: 1,
  ),
  BadgeDefinition(
    title: 'On a Roll',
    description: '3-day streak achieved!',
    icon: '🔥',
    color: '#FF5722',
    requiredStreak: 3,
  ),
  BadgeDefinition(
    title: 'Week Warrior',
    description: '7-day streak — a full week!',
    icon: '⚔️',
    color: '#2196F3',
    requiredStreak: 7,
  ),
  BadgeDefinition(
    title: 'Fortnight Force',
    description: '14 days straight!',
    icon: '💪',
    color: '#9C27B0',
    requiredStreak: 14,
  ),
  BadgeDefinition(
    title: 'Monthly Master',
    description: '30-day streak — incredible!',
    icon: '🏆',
    color: '#FFD700',
    requiredStreak: 30,
  ),
  BadgeDefinition(
    title: 'Unstoppable',
    description: '60-day streak — you\'re a machine!',
    icon: '🚀',
    color: '#FF4081',
    requiredStreak: 60,
  ),
  BadgeDefinition(
    title: 'Legend',
    description: '100-day streak — absolute legend!',
    icon: '👑',
    color: '#FF6D00',
    requiredStreak: 100,
  ),
];
