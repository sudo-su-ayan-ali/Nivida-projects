import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import 'child_selector.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final books = child.library;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Library', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Books issued to ${child.student.name}.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        const ChildSelector(),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Issued Books',
          child: books.isEmpty
              ? const EmptyState(icon: Icons.local_library_outlined, message: 'No books currently issued.')
              : Column(children: [for (final b in books) _bookRow(b)]),
        ),
      ],
    );
  }

  Widget _bookRow(LibraryBook b) {
    final overdue = !b.returned && b.dueOn.isBefore(DateTime.now());
    final color = b.returned ? AppColors.success : (overdue ? AppColors.danger : AppColors.warning);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 52,
            decoration: BoxDecoration(color: AppColors.statBg(AppColors.primary), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.menu_book, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                Text('by ${b.author}', style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text('Due ${DateFormat('dd MMM yyyy').format(b.dueOn)}', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.statBg(color), borderRadius: BorderRadius.circular(8)),
            child: Text(
              b.returned ? 'Returned' : (overdue ? 'Overdue' : 'Issued'),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
