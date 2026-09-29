import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String? _monthFilter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final events = [...state.events]..sort((a, b) => a.date.compareTo(b.date));
    final months = events.map((e) => DateFormat('MMMM yyyy').format(e.date)).toSet().toList();
    final filtered = _monthFilter == null
        ? events
        : events.where((e) => DateFormat('MMMM yyyy').format(e.date) == _monthFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Events', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('School calendar and upcoming events.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _monthChip('All', _monthFilter == null, () => setState(() => _monthFilter = null)),
              for (final m in months) _monthChip(m, _monthFilter == m, () => setState(() => _monthFilter = m)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Upcoming Events',
          child: filtered.isEmpty
              ? const EmptyState(icon: Icons.event_outlined, message: 'No events found for this filter.')
              : Column(
                  children: [
                    for (final e in filtered) ...[
                      _eventRow(e),
                      const Divider(height: 28),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _monthChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
        backgroundColor: AppColors.card,
        side: BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _eventRow(SchoolEvent e) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: AppColors.statBg(AppColors.primary), borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Text(DateFormat('MMM').format(e.date).toUpperCase(),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text(DateFormat('dd').format(e.date), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Text(e.description, style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
              const SizedBox(height: 4),
              Text(DateFormat('EEEE, dd MMMM yyyy').format(e.date), style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
            ],
          ),
        ),
      ],
    );
  }
}
