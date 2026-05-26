import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../utils/app_theme.dart';
import 'add_habit_screen.dart';
import '../widgets/badge_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await HabitService.instance.generatePastData(10);
    final stats = await HabitService.instance.getGlobalStats();
    if (mounted) {
      setState(() {
        _habits = stats['habits'] as List<Habit>;
        _stats = stats;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(Habit habit) async {
    final res = await HabitService.instance.toggleHabit(habit);
    final badges = res['badges'] as List;
    
    await _load(); // Refresh all
    
    if (badges.isNotEmpty && mounted) {
      for (final b in badges) {
        await showDialog(
          context: context,
          builder: (_) => BadgePopup(badge: b),
        );
      }
    }
  }

  int get _completedToday => _habits.where((h) => 
    h.history.contains(DateFormat('yyyy-MM-dd').format(DateTime.now()))
  ).length;

  Future<void> _confirmDelete(Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HabitService.instance.deleteHabit(habit.id);
      if (mounted) {
        _load();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildProgressCard(),
                  _buildHabitList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen()),
          );
          if (ok == true) _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit'),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning ☀️' : hour < 17 ? 'Good Afternoon 🌤️' : 'Good Evening 🌙';
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
            IconButton(
              onPressed: () async {
                await HabitService.instance.generatePastData(10, force: true);
                _load();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulated 10 days of past activity!'))
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Simulate Past Data',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final total = _habits.length;
    final done = _completedToday;
    final pct = total == 0 ? 0.0 : done / total;
    final score = total == 0 ? 0 : (pct * 100).toInt();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Progress',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$done/$total',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem('🏆', '${_stats['bestStreak']}', 'Best Streak'),
                  _statItem('⚡', '$score%', 'Score'),
                  _statItem('✅', '$done', 'Done Today'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String icon, String val, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              val,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildHabitList() {
    if (_habits.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No habits yet! Click + to start.')),
      );
    }

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final habit = _habits[index];
            final isDone = habit.history.contains(todayStr);
            Color c;
            try {
              c = Color(int.parse('FF${habit.color.replaceAll('#', '')}', radix: 16));
            } catch (_) {
              c = AppColors.primary;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(habit.icon, style: const TextStyle(fontSize: 24))),
                ),
                title: Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(habit.category, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: isDone,
                      onChanged: (_) => _toggle(habit),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(habit),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: _habits.length,
        ),
      ),
    );
  }
}
