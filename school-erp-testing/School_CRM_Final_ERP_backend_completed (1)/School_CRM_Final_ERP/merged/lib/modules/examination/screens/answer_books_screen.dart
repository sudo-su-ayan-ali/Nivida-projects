import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

const List<BookStatus> kCustodyChain = [
  BookStatus.generated,
  BookStatus.printed,
  BookStatus.prepared,
  BookStatus.assigned,
  BookStatus.distributed,
  BookStatus.collected,
  BookStatus.received,
  BookStatus.evaluationQueue,
  BookStatus.assignedToExaminer,
  BookStatus.underEvaluation,
  BookStatus.evaluated,
  BookStatus.marksLocked,
  BookStatus.approved,
  BookStatus.identityRevealed,
  BookStatus.resultPublished,
  BookStatus.archived,
];

class AnswerBooksScreen extends StatelessWidget {
  const AnswerBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final books = store.books;
    final counts = {for (final s in kCustodyChain) s: books.where((b) => b.status == s).length};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Answer Book Inventory & Chain of Custody', subtitle: 'Full lifecycle: Generated → ... → Result Published → Archived'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: kCustodyChain
                    .map((s) => Container(
                          width: 130,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${counts[s]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              Text(s.label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<AnonymousBook>(
                rows: books,
                searchHint: 'Search anonymous ID...',
                searchMatcher: (b, q) => b.anonId.toLowerCase().contains(q),
                columns: [
                  AppColumn(label: 'Anon ID', width: 150, cellBuilder: (b) => Text(b.anonId, style: const TextStyle(fontWeight: FontWeight.w600))),
                  AppColumn(label: 'Subject', width: 110, cellBuilder: (b) => Text(store.subjectById(b.subjectId)?.name ?? '-')),
                  AppColumn(label: 'Status', width: 150, cellBuilder: (b) => StatusBadge(b.status.label, color: AppColors.info)),
                  AppColumn(label: 'History', width: 220, cellBuilder: (b) => Text(b.history.map((h) => h.toStatus.label).join(' → '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5))),
                  AppColumn(
                    label: 'Advance Status',
                    width: 160,
                    cellBuilder: (b) {
                      final idx = kCustodyChain.indexOf(b.status);
                      final next = idx >= 0 && idx < kCustodyChain.length - 1 ? kCustodyChain[idx + 1] : null;
                      if (next == null) return const Text('—');
                      if (next == BookStatus.identityRevealed) {
                        return OutlinedButton(
                          onPressed: !store.can(Permission.revealIdentity)
                              ? null
                              : () async {
                                  if (await confirmDialog(context, title: 'Reveal identity', message: 'This is a privileged action and will be recorded in the audit log. Continue?')) {
                                    final s = store.revealIdentity(b.id);
                                    if (context.mounted) {
                                      showAppSnack(context, s == null ? 'No mapping found.' : 'Identity revealed: ${s.name} (Roll ${s.rollNo})');
                                    }
                                  }
                                },
                          child: const Text('Reveal Identity', style: TextStyle(fontSize: 11.5)),
                        );
                      }
                      return OutlinedButton(
                        onPressed: () => store.transitionBook(b.id, next),
                        child: Text('→ ${next.label}', style: const TextStyle(fontSize: 11.5)),
                      );
                    },
                  ),
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
