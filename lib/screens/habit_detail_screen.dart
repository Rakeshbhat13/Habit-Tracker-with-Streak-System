import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/habit_badge.dart';
import '../services/habit_service.dart';
import '../utils/app_theme.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});
  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late Habit _habit;
  Map<DateTime, int> _completionMap = {};
  List<HabitBadge> _badges = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final habits = await HabitService.instance.getAllHabits();
      final refreshed = habits.firstWhere((h) => h.id == _habit.id, orElse: () => _habit);
      
      final allBadges = await HabitService.instance.getAllBadges();
      final badges = allBadges.where((b) => b.habitId == _habit.id).toList();

      Map<DateTime, int> map = {};
      for (String dateStr in refreshed.history) {
        final d = DateTime.parse(dateStr);
        map[DateTime(d.year, d.month, d.day)] = 1;
      }
      if (mounted) setState(() { _completionMap = map; _badges = badges; _habit = refreshed; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  int get _longestStreak {
    if (_habit.history.isEmpty) return 0;
    final sorted = List<String>.from(_habit.history)..sort();
    int longest = 0;
    int current = 0;
    String? prev;
    for (String s in sorted) {
      if (prev == null) {
        current = 1;
      } else {
        final d1 = DateTime.parse(prev);
        final d2 = DateTime.parse(s);
        if (d2.difference(d1).inDays == 1) {
          current++;
        } else {
          current = 1;
        }
      }
      if (current > longest) longest = current;
      prev = s;
    }
    return longest;
  }

  DateTime get _createdAt {
    if (_habit.history.isEmpty) return DateTime.now().subtract(const Duration(days: 10));
    final sorted = List<String>.from(_habit.history)..sort();
    return DateTime.parse(sorted.first);
  }

  DateTime? get _lastCompletedAt {
    if (_habit.history.isEmpty) return null;
    final sorted = List<String>.from(_habit.history)..sort();
    return DateTime.parse(sorted.last);
  }

  Color get _c { try { return Color(int.parse('FF${_habit.color.replaceAll('#', '')}', radix: 16)); } catch (_) { return AppColors.primary; } }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_c.withOpacity(0.3), Theme.of(context).scaffoldBackgroundColor],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    ),
                    child: SafeArea(child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                      child: Row(children: [
                        Container(width: 56, height: 56,
                          decoration: BoxDecoration(color: _c.withOpacity(0.15), borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _c.withOpacity(0.3), width: 1.5)),
                          child: Center(child: Text(_habit.icon, style: const TextStyle(fontSize: 28)))),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_habit.title, style: Theme.of(context).textTheme.headlineMedium),
                          if (_habit.description.isNotEmpty)
                            Text(_habit.description, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ])),
                      ]),
                    )),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabs,
                  indicatorColor: _c,
                  labelColor: _c,
                  unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                  tabs: const [Tab(text: 'Overview'), Tab(text: 'Calendar'), Tab(text: 'Badges')],
                ),
              ),
            ],
            body: TabBarView(controller: _tabs, children: [
              _buildOverview(),
              _buildCalendar(),
              _buildBadgesTab(),
            ]),
          ),
  );

  Widget _buildOverview() => ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [
      _statCard('🔥', '${_habit.streak}', 'Current Streak', _c),
      const SizedBox(width: 12),
      _statCard('🏆', '$_longestStreak', 'Longest Streak', AppColors.warning),
    ]),
    const SizedBox(height: 14),
    _buildBarChart(),
    const SizedBox(height: 14),
    _infoCard(),
  ]);

  Widget _statCard(String icon, String val, String label, Color c) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(val, style: TextStyle(color: c, fontSize: 32, fontWeight: FontWeight.w800)),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ]),
    ),
  );

  Widget _buildBarChart() {
    final last7 = List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      final key = DateTime(day.year, day.month, day.day);
      return (_completionMap[key] ?? 0) > 0 ? 1.0 : 0.0;
    });
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Last 7 Days', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        SizedBox(height: 100, child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround, maxY: 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              final day = DateTime.now().subtract(Duration(days: 6 - v.toInt()));
              return Padding(padding: const EdgeInsets.only(top: 4),
                  child: Text(DateFormat('E').format(day)[0], style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)));
            })),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: last7[i], width: 22, borderRadius: BorderRadius.circular(6),
              color: last7[i] > 0 ? _c : Theme.of(context).dividerColor,
            ),
          ])),
        ))),
      ]),
    );
  }

  Widget _infoCard() => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(children: [
      _row('Category', '${kCategories.firstWhere((c) => c['name'] == _habit.category, orElse: () => {'icon':'⭐'})['icon']} ${_habit.category}'),
      _row('Frequency', _habit.frequency == 'daily' ? '📅 Daily' : '📆 Weekly'),
      _row('Started', DateFormat('MMM d, yyyy').format(_createdAt)),
      if (_lastCompletedAt != null) _row('Last done', DateFormat('MMM d, yyyy').format(_lastCompletedAt!)),
      _row('Badges', '🏅 ${_badges.length}'),
    ]),
  );

  Widget _row(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      Text(val, style: Theme.of(context).textTheme.titleMedium),
    ]),
  );

  Widget _buildCalendar() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: TableCalendar(
      firstDay: _createdAt.isBefore(DateTime.now().subtract(const Duration(days: 30))) ? _createdAt : DateTime.now().subtract(const Duration(days: 30)), lastDay: DateTime.now(), focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: _c.withOpacity(0.3), shape: BoxShape.circle),
        defaultTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        weekendTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false, titleCentered: true,
        titleTextStyle: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.w700),
        leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).textTheme.bodyLarge?.color),
        rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
      calendarBuilders: CalendarBuilders(defaultBuilder: (ctx, day, _) {
        final key = DateTime(day.year, day.month, day.day);
        if ((_completionMap[key] ?? 0) == 0) return null;
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: _c, shape: BoxShape.circle),
          child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        );
      }),
    ),
  );

  Widget _buildBadgesTab() {
    if (_badges.isEmpty) return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🏅', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        Text('No badges yet', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Keep your streak going to earn badges!', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ...kBadgeDefinitions.where((d) => _habit.streak < d.requiredStreak).take(3).map((d) => ListTile(
          leading: Text(d.icon, style: const TextStyle(fontSize: 24)),
          title: Text(d.title),
          subtitle: Text('${d.requiredStreak}-day streak needed'),
          trailing: Text('${_habit.streak}/${d.requiredStreak}',
              style: TextStyle(color: _c, fontWeight: FontWeight.w700)),
        )),
      ]),
    ));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _badges.length,
      itemBuilder: (ctx, i) {
        final b = _badges[i];
        Color c; try { c = Color(int.parse('FF${b.color.replaceAll('#', '')}', radix: 16)); } catch (_) { c = AppColors.primary; }
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.withOpacity(0.06), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withOpacity(0.2)),
          ),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: c.withOpacity(0.15), shape: BoxShape.circle),
                child: Center(child: Text(b.icon, style: const TextStyle(fontSize: 26)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.title, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 15)),
              Text(b.description, style: Theme.of(context).textTheme.bodyMedium),
              Text(DateFormat('MMM d, yyyy').format(b.unlockedAt), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
            ])),
          ]),
        );
      },
    );
  }
}
