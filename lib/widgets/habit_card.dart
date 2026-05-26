import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key, required this.habit, required this.isCompleted,
    required this.onToggle, required this.onTap, required this.onEdit, required this.onDelete,
  });

  Color get _color {
    try { return Color(int.parse('FF${habit.color.replaceAll('#', '')}', radix: 16)); }
    catch (_) { return AppColors.primary; }
  }

  void _showMenu(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(margin: const EdgeInsets.only(bottom: 8), width: 36, height: 4,
              decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(2))),
          ListTile(
            leading: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 20))),
            ),
            title: Text(habit.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(habit.category, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
            title: const Text('Edit Habit'),
            onTap: () { Navigator.pop(context); onEdit(); },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            title: const Text('Delete Habit', style: TextStyle(color: AppColors.danger)),
            onTap: () { Navigator.pop(context); onDelete(); },
          ),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showMenu(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isCompleted
                ? _color.withOpacity(isDark ? 0.15 : 0.08)
                : (isDark ? AppColors.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted ? _color.withOpacity(0.4) : Theme.of(context).dividerColor,
              width: isCompleted ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted ? _color.withOpacity(0.1) : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 8, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Icon
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(habit.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Theme.of(context).textTheme.bodyMedium?.color : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  if (habit.streak > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('🔥', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text('${habit.streak}',
                            style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(habit.category,
                        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ])),
              const SizedBox(width: 10),
              // Checkbox
              GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); onToggle(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted ? _color : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted ? _color : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: isCompleted ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
