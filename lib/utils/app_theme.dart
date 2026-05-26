import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const primary    = Color(0xFF6366F1); // Indigo
  static const secondary  = Color(0xFF8B5CF6); // Violet  
  static const accent     = Color(0xFF06B6D4); // Cyan
  static const success    = Color(0xFF10B981); // Emerald
  static const warning    = Color(0xFFF59E0B); // Amber
  static const danger     = Color(0xFFEF4444); // Red

  // Dark surfaces
  static const darkBg      = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkCard    = Color(0xFF1E293B);
  static const darkCardAlt = Color(0xFF273549);
  static const darkBorder  = Color(0xFF334155);
  static const darkText    = Color(0xFFF1F5F9);
  static const darkSubtext = Color(0xFF94A3B8);

  // Light surfaces
  static const lightBg      = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard    = Color(0xFFFFFFFF);
  static const lightBorder  = Color(0xFFE2E8F0);
  static const lightText    = Color(0xFF0F172A);
  static const lightSubtext = Color(0xFF64748B);
}

class AppTheme {
  static ThemeData get dark  => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final bg     = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final surf   = isDark ? AppColors.darkSurface  : AppColors.lightSurface;
    final card   = isDark ? AppColors.darkCard     : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder   : AppColors.lightBorder;
    final text   = isDark ? AppColors.darkText     : AppColors.lightText;
    final sub    = isDark ? AppColors.darkSubtext  : AppColors.lightSubtext;

    final textTheme = GoogleFonts.interTextTheme(TextTheme(
      displayLarge:  TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: text),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: text),
      headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: text),
      titleLarge:    TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: text),
      titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: text),
      bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: text),
      bodyMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: sub),
      labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: text),
    ));

    return ThemeData(
      brightness: b,
      scaffoldBackgroundColor: bg,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme(
        brightness: b,
        primary: AppColors.primary, onPrimary: Colors.white,
        secondary: AppColors.secondary, onSecondary: Colors.white,
        error: AppColors.danger, onError: Colors.white,
        background: bg, onBackground: text,
        surface: surf, onSurface: text,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: text),
        iconTheme: IconThemeData(color: text),
      ),
      cardTheme: CardThemeData(
        color: card, elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        elevation: 0,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.resolveWith((s) => GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: s.contains(MaterialState.selected) ? AppColors.primary : sub,
        )),
        iconTheme: MaterialStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(MaterialState.selected) ? AppColors.primary : sub, size: 22,
        )),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 4,
        extendedTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.danger)),
        labelStyle: TextStyle(color: sub),
        hintStyle: TextStyle(color: sub),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      )),
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 0),
    );
  }
}

// Habit categories
const List<Map<String, String>> kCategories = [
  {'name': 'Health',      'icon': '🏃'},
  {'name': 'Study',       'icon': '📚'},
  {'name': 'Mindfulness', 'icon': '🧘'},
  {'name': 'Fitness',     'icon': '💪'},
  {'name': 'Nutrition',   'icon': '🥗'},
  {'name': 'Sleep',       'icon': '😴'},
  {'name': 'Finance',     'icon': '💰'},
  {'name': 'Social',      'icon': '👥'},
  {'name': 'Creativity',  'icon': '🎨'},
  {'name': 'General',     'icon': '⭐'},
];

const List<String> kHabitColors = [
  '#6366F1','#8B5CF6','#EC4899','#EF4444',
  '#F59E0B','#10B981','#06B6D4','#3B82F6',
  '#84CC16','#F97316',
];

const List<String> kHabitIcons = [
  '⭐','🏃','📚','🧘','💪','🥗','😴','💰',
  '👥','🎨','🎯','🔥','💧','🌱','🎵','🏋️',
  '🧠','✍️','🚴','🤸',
];

class HabitTemplate {
  final String title, description, icon, color, category;
  const HabitTemplate({required this.title, required this.description, required this.icon, required this.color, required this.category});
}

const List<HabitTemplate> kHabitTemplates = [
  HabitTemplate(title: 'Morning Run',    description: 'Go for a run every morning',    icon: '🏃', color: '#10B981', category: 'Fitness'),
  HabitTemplate(title: 'Read 30 mins',   description: 'Read a book for 30 minutes',    icon: '📚', color: '#6366F1', category: 'Study'),
  HabitTemplate(title: 'Drink Water',    description: 'Drink 8 glasses of water',      icon: '💧', color: '#06B6D4', category: 'Health'),
  HabitTemplate(title: 'Meditate',       description: '10 minutes of mindfulness',     icon: '🧘', color: '#8B5CF6', category: 'Mindfulness'),
  HabitTemplate(title: 'No Junk Food',   description: 'Avoid junk food today',         icon: '🥗', color: '#10B981', category: 'Nutrition'),
  HabitTemplate(title: 'Sleep by 11pm',  description: 'Get to bed before 11 PM',       icon: '😴', color: '#EC4899', category: 'Sleep'),
  HabitTemplate(title: 'Workout',        description: '30 min gym or home workout',    icon: '🏋️', color: '#EF4444', category: 'Fitness'),
  HabitTemplate(title: 'Journal',        description: 'Write in your journal',         icon: '✍️', color: '#F59E0B', category: 'Mindfulness'),
  HabitTemplate(title: 'Study 1 hour',   description: 'Focused study session',         icon: '🧠', color: '#3B82F6', category: 'Study'),
  HabitTemplate(title: 'Save Money',     description: 'Avoid unnecessary spending',    icon: '💰', color: '#10B981', category: 'Finance'),
  HabitTemplate(title: 'Cycling',        description: 'Go for a bike ride',            icon: '🚴', color: '#F97316', category: 'Fitness'),
  HabitTemplate(title: 'Practice Music', description: 'Practice your instrument',      icon: '🎵', color: '#EC4899', category: 'Creativity'),
];
