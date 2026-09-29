import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

class ModerationScreen extends StatelessWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lockedBooks = store.books.where((b) => b.status.index >= BookStatus.marksLocked.index || b.status == BookStatus.evaluated).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Moderation & Marks Lock', subtitle: 'Review discrepancies between evaluators and approve corrections'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<AnonymousBook>(
                rows: lockedBooks,
                columns: [
                  AppColumn(label: 'Book ID', width: 150, cellBuilder: (b) => Text(b.anonId, style: const TextStyle(fontWeight: FontWeight.w600))),
                  AppColumn(label: 'Subject', width: 120, cellBuilder: (b) => Text(store.subjectById(b.subjectId)?.name ?? '-')),
                  AppColumn(
                    label: 'Marks Awarded',
                    width: 120,
                    cellBuilder: (b) {
                      final ev = store.evaluations.where((e) => e.bookId == b.id).toList();
                      final total = ev.isEmpty ? 0 : ev.first.total;
                      return Text('$total');
                    },
                  ),
                  AppColumn(label: 'Status', width: 130, cellBuilder: (b) => StatusBadge(b.status.label, color: AppColors.info)),
                  AppColumn(
                    label: 'Action',
                    width: 150,
                    cellBuilder: (b) => store.can(Permission.lockMarks) && b.status == BookStatus.evaluated
                        ? ElevatedButton(
                            onPressed: () => store.transitionBook(b.id, BookStatus.marksLocked),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                            child: const Text('Lock Marks', style: TextStyle(fontSize: 12)),
                          )
                        : (store.can(Permission.approveResults) && b.status == BookStatus.marksLocked
                            ? OutlinedButton(
                                onPressed: () => store.transitionBook(b.id, BookStatus.approved),
                                child: const Text('Approve', style: TextStyle(fontSize: 12)),
                              )
                            : const Text('—')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Marks Correction Requests', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (store.corrections.isEmpty) const EmptyState(message: 'No correction requests pending.'),
                  ...store.corrections.map((c) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Book (internal ref ${c.bookId.substring(0, 6)}...) — ${c.originalValue} → ${c.newValue}'),
                        subtitle: Text('Reason: ${c.reason}'),
                        trailing: c.status == CorrectionStatus.pending && store.can(Permission.approveMarksCorrection)
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                TextButton(onPressed: () => store.decideCorrection(c.id, false), child: const Text('Reject')),
                                FilledButton(onPressed: () => store.decideCorrection(c.id, true), child: const Text('Approve')),
                              ])
                            : StatusBadge(c.status.name, color: c.status == CorrectionStatus.approved ? AppColors.success : (c.status == CorrectionStatus.rejected ? AppColors.danger : AppColors.warning)),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
