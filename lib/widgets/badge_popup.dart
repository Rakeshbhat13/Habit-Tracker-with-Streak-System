import 'package:flutter/material.dart';
import '../models/habit_badge.dart';
import '../utils/app_theme.dart';

class BadgePopup extends StatelessWidget {
  final HabitBadge badge;
  const BadgePopup({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    Color c;
    try { c = Color(int.parse('FF${badge.color.replaceAll('#', '')}', radix: 16)); }
    catch (_) { c = AppColors.primary; }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(child: Text(badge.icon, style: const TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('Badge Unlocked!', style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Text(badge.title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(badge.description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: c),
              child: const Text('Awesome! 🎉'),
            ),
          ),
        ]),
      ),
    );
  }
}
