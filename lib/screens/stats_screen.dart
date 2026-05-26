import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_badge.dart';
import '../services/habit_service.dart';
import '../utils/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _loading = true;
  int _totalHabits = 0;
  int _activeDays = 0;
  int _bestStreak = 0;
  int _totalBadges = 0;
  List<Habit> _habits = [];
  List<HabitBadge> _badges = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stats = await HabitService.instance.getGlobalStats();
    if (mounted) {
      setState(() {
        _totalHabits = stats['totalHabits'];
        _activeDays = stats['activeDays'];
        _bestStreak = stats['bestStreak'];
        _totalBadges = stats['totalBadges'];
        _habits = stats['habits'] as List<Habit>;
        _badges = stats['badges'] as List<HabitBadge>;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildLeaderboard(),
                  const SizedBox(height: 24),
                  _buildCategoryBreakdown(),
                  const SizedBox(height: 24),
                  _buildRecentBadges(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('Total Habits', '$_totalHabits', Icons.list_alt_rounded, AppColors.primary),
        _statCard('Active Days', '$_activeDays', Icons.calendar_today_rounded, AppColors.success),
        _statCard('Best Streak', '$_bestStreak', Icons.local_fire_department_rounded, Colors.orange),
        _statCard('Total Badges', '$_totalBadges', Icons.emoji_events_rounded, AppColors.warning),
      ],
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    final sorted = List<Habit>.from(_habits)..sort((a, b) => b.streak.compareTo(a.streak));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Streak Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...sorted.take(5).map((h) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Text(h.icon, style: const TextStyle(fontSize: 20)),
                title: Text(h.title),
                subtitle: Text(h.category),
                trailing: Text('${h.streak} 🔥', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            )),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    final Map<String, int> cats = {};
    for (var h in _habits) {
      cats[h.category] = (cats[h.category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cats.entries.map((e) => Chip(
                label: Text('${e.key}: ${e.value}'),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentBadges() {
    final recent = List<HabitBadge>.from(_badges)..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recent.take(5).length,
            itemBuilder: (context, index) {
              final b = recent[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(b.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(b.title, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
