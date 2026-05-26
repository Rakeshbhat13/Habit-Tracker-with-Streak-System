import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../utils/app_theme.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;
  const EditHabitScreen({super.key, required this.habit});
  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _titleCtrl, _descCtrl;
  late String _cat, _color, _icon, _freq;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.habit.title);
    _descCtrl  = TextEditingController(text: widget.habit.description);
    _cat   = widget.habit.category;
    _color = widget.habit.color;
    _icon  = widget.habit.icon;
    _freq  = widget.habit.frequency;
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Color _hex(String h) { try { return Color(int.parse('FF${h.replaceAll('#', '')}', radix: 16)); } catch (_) { return AppColors.primary; } }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await HabitService.instance.updateHabit(widget.habit.copyWith(
        title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
        category: _cat, frequency: _freq, color: _color, icon: _icon,
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (_) { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Edit Habit'),
      actions: [
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
    body: Form(
      key: _form,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          GestureDetector(
            onTap: _pickIcon,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: _hex(_color).withOpacity(0.12), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _hex(_color), width: 2),
              ),
              child: Center(child: Text(_icon, style: const TextStyle(fontSize: 28))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Habit name'),
            textCapitalization: TextCapitalization.sentences,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          )),
        ]),
        const SizedBox(height: 14),
        TextFormField(controller: _descCtrl, maxLines: 2, textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Description (optional)')),
        const SizedBox(height: 20),
        Text('Category', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: kCategories.map((c) {
          final sel = _cat == c['name'];
          return ChoiceChip(
            label: Text('${c['icon']} ${c['name']}'), selected: sel,
            onSelected: (_) => setState(() => _cat = c['name']!),
            selectedColor: AppColors.primary.withOpacity(0.15),
            labelStyle: TextStyle(color: sel ? AppColors.primary : null, fontWeight: sel ? FontWeight.w600 : null),
            side: BorderSide(color: sel ? AppColors.primary : Theme.of(context).dividerColor),
            backgroundColor: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        }).toList()),
        const SizedBox(height: 20),
        Text('Frequency', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'daily', label: Text('Daily'), icon: Icon(Icons.today_rounded)),
            ButtonSegment(value: 'weekly', label: Text('Weekly'), icon: Icon(Icons.calendar_view_week_rounded)),
          ],
          selected: {_freq},
          onSelectionChanged: (s) => setState(() => _freq = s.first),
        ),
        const SizedBox(height: 20),
        Text('Color', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: kHabitColors.map((hex) {
          final sel = _color == hex; final c = _hex(hex);
          return GestureDetector(
            onTap: () => setState(() => _color = hex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(10),
                border: sel ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: sel ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : null,
              ),
              child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
            ),
          );
        }).toList()),
        const SizedBox(height: 40),
      ]),
    ),
  );

  void _pickIcon() => showModalBottomSheet(
    context: context, isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Choose Icon', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: kHabitIcons.map((icon) => GestureDetector(
          onTap: () { setState(() => _icon = icon); Navigator.pop(context); },
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _icon == icon ? AppColors.primary.withOpacity(0.12) : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _icon == icon ? AppColors.primary : Theme.of(context).dividerColor),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
        )).toList()),
        const SizedBox(height: 20),
      ]),
    ),
  );
}
