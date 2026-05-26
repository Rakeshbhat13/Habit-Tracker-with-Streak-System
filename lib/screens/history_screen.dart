import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryEntry {
  final Habit habit;
  final String date;
  _HistoryEntry(this.habit, this.date);
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<_HistoryEntry> _allEntries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final habits = await HabitService.instance.getAllHabits();
    final List<_HistoryEntry> entries = [];
    
    for (final h in habits) {
      for (final dateStr in h.history) {
        entries.add(_HistoryEntry(h, dateStr));
      }
    }
    
    // Sort by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));
    
    if (mounted) {
      setState(() {
        _allEntries = entries;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group entries by date
    final Map<String, List<_HistoryEntry>> grouped = {};
    for (var entry in _allEntries) {
      grouped.putIfAbsent(entry.date, () => []).add(entry);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Completions History'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allEntries.isEmpty
              ? const Center(child: Text('No history available yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final dateStr = sortedDates[index];
                    final entries = grouped[dateStr]!;
                    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
                    final formattedDate = DateFormat('EEEE, MMM d').format(date);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            formattedDate,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                          ),
                        ),
                        ...entries.map((e) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Text(e.habit.icon, style: const TextStyle(fontSize: 20)),
                                title: Text(e.habit.title),
                                subtitle: Text(e.habit.category),
                                trailing: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
    );
  }
}
