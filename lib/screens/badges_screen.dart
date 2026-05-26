import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_badge.dart';
import '../services/habit_service.dart';
import '../utils/app_theme.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});
  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<HabitBadge> _badges = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final b = await HabitService.instance.getAllBadges();
      if (mounted) setState(() { _badges = b; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Badges')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                if (_badges.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _buildGrid(),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(child: _buildHowToEarnSection()),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.emoji_events_rounded, size: 44, color: AppColors.warning),
          ),
          const SizedBox(height: 20),
          Text('No badges yet!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Keep streaks going to earn badges!', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          final b = _badges[i];
          Color c; 
          try { 
            c = Color(int.parse('FF${b.color.replaceAll('#', '')}', radix: 16)); 
          } catch (_) { 
            c = AppColors.primary; 
          }
          
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: c.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 48, height: 48,
                  decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
                  child: Center(child: Text(b.icon, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(height: 8),
                Text(b.title, textAlign: TextAlign.center,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(DateFormat('MMM d, yyyy').format(b.unlockedAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10)),
              ]),
            ),
          );
        },
        childCount: _badges.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1,
      ),
    );
  }

  Widget _buildHowToEarnSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How to Earn Badges', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Available Badges', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.lightSubtext)),
          const SizedBox(height: 16),
          ...kBadgeDefinitions.map((d) {
            final isEarned = _badges.any((b) => b.title == d.title);
            return Opacity(
              opacity: isEarned ? 0.6 : 1.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Center(child: Text(d.icon, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (isEarned) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                              ]
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(d.description, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 2),
                          Text('Requirement: Complete a habit for ${d.requiredStreak} consecutive days', 
                            style: TextStyle(fontSize: 12, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
