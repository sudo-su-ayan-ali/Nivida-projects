import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import 'child_selector.dart';

class ExaminationsScreen extends StatelessWidget {
  const ExaminationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final exams = [...child.exams]..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Examinations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Upcoming exam schedule for ${child.student.name}.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        const ChildSelector(),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Exam Schedule',
          child: exams.isEmpty
              ? const EmptyState(icon: Icons.fact_check_outlined, message: 'No exams scheduled right now.')
              : Column(
                  children: [
                    for (final e in exams) ...[
                      Row(
                        children: [
                          Container(
                            width: 52,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(color: AppColors.statBg(AppColors.warning), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                Text(DateFormat('MMM').format(e.date).toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
                                Text(DateFormat('dd').format(e.date),
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.warning)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.subject, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 3),
                                Text('${e.time} · ${e.room}', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

