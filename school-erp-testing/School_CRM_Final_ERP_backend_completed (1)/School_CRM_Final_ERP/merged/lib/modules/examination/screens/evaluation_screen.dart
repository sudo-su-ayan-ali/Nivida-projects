import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

/// Examiner-facing evaluation screen. CRITICAL: this screen must only ever
/// read from AppStore.evaluationViewFor(), which strips identity fields.
/// It must never call store.studentById() or read AnonymousBook.studentId.
class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});
  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  AnonymousBook? current;
  EvaluationRecord? record;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final user = store.currentUser!;
    final myQueue = store.books.where((b) => b.examinerId == user.id && (b.status == BookStatus.assignedToExaminer || b.status == BookStatus.underEvaluation)).toList();

    if (!store.can(Permission.enterMarks)) {
      return const Center(child: Text('You do not have evaluation permission for this account.'));
    }

    current ??= myQueue.isNotEmpty ? myQueue.first : null;
    if (current != null) {
      record ??= store.startEvaluation(current!.id);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Anonymous Evaluation', subtitle: 'Blind evaluation — no student identity is ever shown here', actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.skip_next_rounded, size: 18),
              label: const Text('Next Book'),
              onPressed: myQueue.length > 1
                  ? () => setState(() {
                        final idx = myQueue.indexOf(current!);
                        current = myQueue[(idx + 1) % myQueue.length];
                        record = null;
                      })
                  : null,
            ),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.info.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.info.withOpacity(0.3))),
              child: Row(children: const [
                Icon(Icons.shield_outlined, color: AppColors.info, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('You are viewing an anonymized script. Student name, roll number, photo, and class are never shown to examiners.', style: TextStyle(fontSize: 12.5, color: AppColors.info))),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: current == null
                ? const SectionCard(child: EmptyState(message: 'No scripts currently allocated to you. Ask the Exam Controller to run random allocation.'))
                : _EvaluationCard(book: current!, view: store.evaluationViewFor(current!), record: record!),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _EvaluationCard extends StatefulWidget {
  final AnonymousBook book;
  final Map<String, dynamic> view;
  final EvaluationRecord record;
  const _EvaluationCard({required this.book, required this.view, required this.record});

  @override
  State<_EvaluationCard> createState() => _EvaluationCardState();
}

class _EvaluationCardState extends State<_EvaluationCard> {
  late List<QuestionMark> marks;

  @override
  void initState() {
    super.initState();
    marks = widget.record.marks.isNotEmpty
        ? widget.record.marks
        : List.generate(6, (i) => QuestionMark(questionNo: '${i + 1}', maxMarks: i < 3 ? 10 : 15));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppStore>();
    final total = marks.fold<int>(0, (s, m) => s + (m.awarded ?? 0));
    final maxTotal = marks.fold<int>(0, (s, m) => s + m.maxMarks);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.view['anonId'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(height: 3),
                  Text('${widget.view['examName']}  •  ${widget.view['subjectName']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$total / $maxTotal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                Text('Total Marks', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ]),
          const Divider(height: 30),
          ...marks.map((m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(width: 90, child: Text('Q${m.questionNo} (max ${m.maxMarks})')),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        key: ValueKey('q_${m.questionNo}'),
                        initialValue: m.awarded?.toString() ?? '',
                        decoration: const InputDecoration(isDense: true, hintText: 'Marks'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          setState(() => m.awarded = (n != null && n <= m.maxMarks) ? n : m.awarded);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: m.comment ?? '',
                        decoration: const InputDecoration(isDense: true, hintText: 'Examiner comment (optional)'),
                        onChanged: (v) => m.comment = v,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Row(children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save Draft'),
              onPressed: () {
                widget.record.marks = marks;
                store.saveEvaluationDraft(widget.record);
                showAppSnack(context, 'Draft saved.');
              },
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_outline_rounded, size: 18),
              label: const Text('Submit & Lock Marks'),
              onPressed: () async {
                if (await confirmDialog(context, title: 'Submit marks', message: 'Once submitted, marks will be locked. Any change afterwards requires a correction request. Continue?')) {
                  widget.record.marks = marks;
                  store.submitEvaluation(widget.record);
                  if (context.mounted) showAppSnack(context, 'Marks submitted and locked.');
                }
              },
            ),
          ]),
        ],
      ),
    );
  }
}
