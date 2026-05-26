import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/habit_badge.dart';

class HabitService {
  static final HabitService instance = HabitService._init();
  HabitService._init();

  final _uuid = const Uuid();

  // Box names
  static const String habitsBoxName = 'habits';
  static const String badgesBoxName = 'badges';

  // Helper to ensure box is open and retrieval is fresh
  Box<dynamic> _hBox() {
    if (!Hive.isBoxOpen(habitsBoxName)) {
      throw Exception('Habits box is not open. Call openBoxes first.');
    }
    return Hive.box(habitsBoxName);
  }

  Box<dynamic> _bBox() {
    if (!Hive.isBoxOpen(badgesBoxName)) {
      throw Exception('Badges box is not open. Call openBoxes first.');
    }
    return Hive.box(badgesBoxName);
  }

  // ─────────────────────────────────────────────────────────────────
  // HABITS
  // ─────────────────────────────────────────────────────────────────

  Future<Habit> createHabit({
    required String title,
    String description = '',
    String category = 'General',
    String frequency = 'daily',
    String color = '#6366F1',
    String icon = '⭐',
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      frequency: frequency,
      color: color,
      icon: icon,
      streak: 0,
      history: [],
    );
    
    final map = habit.toMap();
    print('DEBUG: Saving habit to Hive: ${habit.title} (ID: ${habit.id})');
    await _hBox().put(habit.id, map);
    
    // Verify save
    final saved = _hBox().get(habit.id);
    print('DEBUG: Verification - Habit in Hive: ${saved != null ? "SUCCESS" : "FAILED"}');
    
    return habit;
  }

  Future<List<Habit>> getAllHabits() async {
    print('DEBUG: Reading all habits from Hive box: $habitsBoxName');
    final values = _hBox().values;
    final habits = values.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return Habit.fromMap(map);
    }).toList();
    print('DEBUG: Loaded ${habits.length} habits from Hive.');
    return habits;
  }

  Future<void> deleteHabit(String id) async {
    print('DEBUG: Deleting habit $id from Hive.');
    await _hBox().delete(id);
  }

  Future<void> updateHabit(Habit habit) async {
    await _hBox().put(habit.id, habit.toMap());
    print('DEBUG: Updated habit ${habit.title} via updateHabit.');
  }

  Future<Map<String, dynamic>> toggleHabit(Habit habit) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final newHistory = List<String>.from(habit.history);

    bool completedNow;
    if (newHistory.contains(today)) {
      newHistory.remove(today);
      completedNow = false;
      print('DEBUG: Unmarking habit as done for today: ${habit.title}');
    } else {
      newHistory.add(today);
      completedNow = true;
      print('DEBUG: Marking habit as done for today: ${habit.title}');
    }

    final streak = _calculateStreak(newHistory);
    final updated = habit.copyWith(history: newHistory, streak: streak);

    await _hBox().put(updated.id, updated.toMap());
    print('DEBUG: Updated habit ${updated.title} in Hive. New streak: $streak');
    
    final awarded = await _checkBadges(updated);

    return {
      'completed': completedNow,
      'habit': updated,
      'badges': awarded,
    };
  }

  int _calculateStreak(List<String> history) {
    if (history.isEmpty) return 0;
    
    final sorted = List<String>.from(history)..sort((a, b) => b.compareTo(a));
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

    if (!sorted.contains(today) && !sorted.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime current = sorted.contains(today) 
        ? DateTime.now() 
        : DateTime.now().subtract(const Duration(days: 1));

    while (true) {
      final dateStr = DateFormat('yyyy-MM-dd').format(current);
      if (sorted.contains(dateStr)) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // ─────────────────────────────────────────────────────────────────
  // BADGES
  // ─────────────────────────────────────────────────────────────────

  Future<List<HabitBadge>> _checkBadges(Habit habit) async {
    final awarded = <HabitBadge>[];
    final milestones = {
      1: {'title': 'First Step', 'icon': '👣', 'desc': 'Completed a habit for the first time'},
      3: {'title': '3 Day Streak', 'icon': '🔥', 'desc': '3 days of consistency!'},
      7: {'title': '7 Day Streak', 'icon': '🏆', 'desc': 'A full week achieved!'},
      10: {'title': '10 Day Legend', 'icon': '👑', 'desc': '10 days of non-stop progress!'},
    };

    for (final m in milestones.entries) {
      if (habit.streak >= m.key) {
        final badgeId = '${habit.id}_${m.key}';
        if (!_bBox().containsKey(badgeId)) {
          final badge = HabitBadge(
            id: badgeId,
            title: m.value['title']!,
            description: m.value['desc']!,
            icon: m.value['icon']!,
            color: habit.color,
            unlockedAt: DateTime.now(),
            habitId: habit.id,
          );
          print('DEBUG: Awarding new badge: ${badge.title} for habit ${habit.title}');
          await _bBox().put(badgeId, badge.toMap());
          awarded.add(badge);
        }
      }
    }
    return awarded;
  }

  Future<List<HabitBadge>> getAllBadges() async {
    print('DEBUG: Reading all badges from Hive box: $badgesBoxName');
    final values = _bBox().values;
    final badges = values.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return HabitBadge.fromMap(map);
    }).toList();
    print('DEBUG: Loaded ${badges.length} badges from Hive.');
    return badges;
  }

  // ─────────────────────────────────────────────────────────────────
  // STATS & SEED DATA
  // ─────────────────────────────────────────────────────────────────

  Future<void> generatePastData(int days, {bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasGenerated = prefs.getBool('past_data_generated') ?? false;

    if (hasGenerated && !force) {
      print('DEBUG: Past data already generated. Skipping.');
      return;
    }

    var habits = await getAllHabits();
    
    // 1. Create habits if none exist
    if (habits.isEmpty) {
      await createHabit(title: 'Workout', icon: '🏋️‍♂️', color: '#EF4444', category: 'Health'); // Red
      await createHabit(title: 'Read', icon: '📚', color: '#3B82F6', category: 'Learning'); // Blue
      await createHabit(title: 'Drink Water', icon: '💧', color: '#06B6D4', category: 'Health'); // Cyan
      await createHabit(title: 'Meditate', icon: '🧘‍♂️', color: '#8B5CF6', category: 'Mindfulness'); // Purple
      await createHabit(title: 'Study', icon: '📖', color: '#F59E0B', category: 'Learning'); // Orange
      await createHabit(title: 'Sleep Early', icon: '😴', color: '#10B981', category: 'Health'); // Green
      
      habits = await getAllHabits();
    }

    final now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final random = Random();

    // Assign base probabilities to create realistic patterns: consistent, inconsistent, skipping
    final probabilities = <double>[];
    for (int i = 0; i < habits.length; i++) {
      if (i == 0 || i == 1) { probabilities.add(0.9); } // Highly consistent
      else if (i == 2 || i == 4) { probabilities.add(0.5); } // Inconsistent
      else { probabilities.add(0.2); } // Low streak/skips days
    }

    for (int i = days; i >= 1; i--) {
      final date = now.subtract(Duration(days: i));
      String formatted = formatter.format(date);

      // We want ~2-4 habits completed per day
      int completedToday = 0;
      
      for (int hIndex = 0; hIndex < habits.length; hIndex++) {
        var h = habits[hIndex];
        final newHistory = List<String>.from(h.history);
        
        // Use probability, but enforce max 4 per day
        if (completedToday < 4 && (random.nextDouble() < probabilities[hIndex] || completedToday < 2)) {
          // If we haven't reached 2 by the later habits, force complete it to meet the 2-4 requirement
          if (!newHistory.contains(formatted)) {
            newHistory.add(formatted);
            h = h.copyWith(history: newHistory);
            habits[hIndex] = h;
            completedToday++;
          }
        }
      }
    }

    // Now recalculate streaks, save to Hive, and generate badges
    for (var h in habits) {
      final streak = _calculateStreak(h.history);
      final updated = h.copyWith(streak: streak);
      
      print('DEBUG: Injecting past data for ${updated.title}, Streak: $streak');
      await _hBox().put(updated.id, updated.toMap());

      await _checkBadgesWithHistory(updated, updated.history);
    }

    await prefs.setBool('past_data_generated', true);
    print('DEBUG: Generated history and badges for the past $days days.');
  }

  Future<void> _checkBadgesWithHistory(Habit habit, List<String> history) async {
    final milestones = {
      1: {'title': 'First Step', 'icon': '👣', 'desc': 'Completed a habit for the first time'},
      3: {'title': '3 Day Streak', 'icon': '🔥', 'desc': '3 days of consistency!'},
      7: {'title': '7 Day Streak', 'icon': '🏆', 'desc': 'A full week achieved!'},
      10: {'title': '10 Day Legend', 'icon': '👑', 'desc': '10 days of non-stop progress!'},
    };

    final sorted = List<String>.from(history)..sort((a, b) => a.compareTo(b));
    int tempStreak = 0;
    String? prevDateStr;

    for (String dateStr in sorted) {
      final date = DateTime.parse(dateStr);
      if (prevDateStr == null) {
        tempStreak = 1;
      } else {
        final prevDate = DateTime.parse(prevDateStr);
        final diff = date.difference(prevDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
      }
      prevDateStr = dateStr;

      for (final m in milestones.entries) {
        if (tempStreak == m.key) { // Hit milestone on this specific date
          final badgeId = '${habit.id}_${m.key}';
          if (!_bBox().containsKey(badgeId)) {
            final badge = HabitBadge(
              id: badgeId,
              title: m.value['title']!,
              description: m.value['desc']!,
              icon: m.value['icon']!,
              color: habit.color,
              unlockedAt: date,
              habitId: habit.id,
            );
            await _bBox().put(badgeId, badge.toMap());
          }
        }
      }
    }
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final habits = await getAllHabits();
    final badges = await getAllBadges();

    final allDates = <String>{};
    int bestStreak = 0;

    for (final h in habits) {
      allDates.addAll(h.history);
      if (h.streak > bestStreak) bestStreak = h.streak;
    }

    return {
      'totalHabits': habits.length,
      'activeDays': allDates.length,
      'bestStreak': bestStreak,
      'totalBadges': badges.length,
      'habits': habits,
      'badges': badges,
    };
  }
}

