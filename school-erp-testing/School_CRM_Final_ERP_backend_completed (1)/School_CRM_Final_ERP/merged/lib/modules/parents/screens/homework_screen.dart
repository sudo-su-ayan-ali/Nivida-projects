import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import 'child_selector.dart';

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final pending = child.homework.where((h) => !h.submitted).toList();
    final done = child.homework.where((h) => h.submitted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Homework', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Assignments for ${child.student.name}.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        const ChildSelector(),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Pending (${pending.length})',
          child: pending.isEmpty
              ? const EmptyState(icon: Icons.menu_book_outlined, message: 'No pending homework. Great job!')
              : Column(children: [for (final h in pending) _homeworkTile(h)]),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Submitted (${done.length})',
          child: done.isEmpty
              ? const EmptyState(icon: Icons.menu_book_outlined, message: 'Nothing submitted yet.')
              : Column(children: [for (final h in done) _homeworkTile(h)]),
        ),
      ],
    );
  }

  Widget _homeworkTile(HomeworkItem h) {
    final overdue = !h.submitted && h.dueDate.isBefore(DateTime.now());
    final color = h.submitted ? AppColors.success : (overdue ? AppColors.danger : AppColors.warning);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: AppColors.statBg(color), borderRadius: BorderRadius.circular(10)),
            child: Icon(
              h.submitted ? Icons.check_circle_outline : Icons.pending_actions_outlined,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                Text(h.subject, style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
              ],
            ),
          ),
          Text(
            h.submitted ? 'Submitted' : (overdue ? 'Overdue' : 'Due ${DateFormat('dd MMM').format(h.dueDate)}'),
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
