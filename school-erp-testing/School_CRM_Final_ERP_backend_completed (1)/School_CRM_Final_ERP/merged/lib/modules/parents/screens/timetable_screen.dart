import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import 'child_selector.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedDay = _days[DateTime.now().weekday - 1 < 6 ? DateTime.now().weekday - 1 : 0];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final slots = child.timetable.where((s) => s.day == _selectedDay).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Timetable', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Weekly class schedule for ${child.student.name}.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        const ChildSelector(),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final d in _days)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(d),
                    selected: _selectedDay == d,
                    onSelected: (_) => setState(() => _selectedDay = d),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedDay == d ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: AppColors.card,
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: '$_selectedDay Schedule',
          child: slots.isEmpty
              ? const EmptyState(icon: Icons.calendar_view_week_outlined, message: 'No classes scheduled for this day.')
              : Column(children: [for (final s in slots) _slotRow(s)]),
        ),
      ],
    );
  }

  Widget _slotRow(TimetableSlot s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(color: AppColors.statBg(AppColors.primary), borderRadius: BorderRadius.circular(10)),
            child: Text(s.time, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.subject, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(s.teacher, style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
