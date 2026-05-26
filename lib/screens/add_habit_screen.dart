import 'package:flutter/material.dart';
import '../services/habit_service.dart';
import '../utils/app_theme.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});
  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Custom'), Tab(text: 'Templates')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _CustomTab(),
          _TemplatesTab(),
        ],
      ),
    );
  }
}

class _CustomTab extends StatefulWidget {
  const _CustomTab();
  @override
  State<_CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<_CustomTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Health';
  String _selectedColor = '#6366F1';
  String _selectedIcon = '⭐';
  String _frequency = 'daily';
  bool _loading = false;

  final List<String> _suggestions = ['Drink Water', 'Exercise', 'Read', 'Meditate', 'Journal'];
  final List<String> _categories = ['Health', 'Fitness', 'Study', 'Mindfulness', 'General'];
  final List<String> _colors = ['#6366F1', '#EC4899', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6'];
  final List<String> _icons = ['💧', '🏃', '📚', '🧘', '✏️', '🥗', '🍎', '💪', '🧠', '✨'];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await HabitService.instance.createHabit(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      category: _selectedCategory,
      color: _selectedColor,
      icon: _selectedIcon,
      frequency: _frequency,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              hintText: 'Habit Title',
              filled: true,
              fillColor: Colors.grey.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            validator: (v) => v!.isEmpty ? 'Title required' : null,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _suggestions.map((s) => ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  onPressed: () => setState(() => _titleCtrl.text = s),
                )).toList(),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Category'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((c) => ChoiceChip(
                  label: Text(c),
                  selected: _selectedCategory == c,
                  onSelected: (_) => setState(() => _selectedCategory = c),
                )).toList(),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Icon & Color'),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _showIconPicker,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(_selectedIcon, style: const TextStyle(fontSize: 30))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colors.map((hex) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = hex),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16)),
                            shape: BoxShape.circle,
                            border: _selectedColor == hex ? Border.all(color: Colors.white, width: 3) : null,
                            boxShadow: [if (_selectedColor == hex) BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        ),
                      )).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading ? const CircularProgressIndicator() : const Text('Create Habit'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 5,
          children: _icons.map((i) => Center(
                child: IconButton(
                  icon: Text(i, style: const TextStyle(fontSize: 24)),
                  onPressed: () { setState(() => _selectedIcon = i); Navigator.pop(context); },
                ),
              )).toList(),
        ),
      ),
    );
  }
}

class _TemplatesTab extends StatelessWidget {
  const _TemplatesTab();

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> templates = {
      'Fitness': [
        {'title': 'Morning Run', 'icon': '🏃', 'color': '#EF4444'},
        {'title': 'Workout', 'icon': '💪', 'color': '#8B5CF6'},
      ],
      'Health': [
        {'title': 'Drink Water', 'icon': '💧', 'color': '#6366F1'},
        {'title': 'Eat Fruits', 'icon': '🍎', 'color': '#10B981'},
      ],
      'Mindfulness': [
        {'title': 'Meditation', 'icon': '🧘', 'color': '#EC4899'},
        {'title': 'Journal', 'icon': '✏️', 'color': '#F59E0B'},
      ],
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: templates.entries.map((entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              ...entry.value.map((t) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Text(t['icon']!, style: const TextStyle(fontSize: 24)),
                      title: Text(t['title']!),
                      onTap: () async {
                        await HabitService.instance.createHabit(
                          title: t['title']!,
                          icon: t['icon']!,
                          color: t['color']!,
                          category: entry.key,
                        );
                        Navigator.pop(context, true);
                      },
                    ),
                  )),
            ],
          )).toList(),
    );
  }
}
