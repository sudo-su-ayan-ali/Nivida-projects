import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

class RevaluationScreen extends StatelessWidget {
  const RevaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Revaluation / Rechecking', subtitle: 'Create, assign, and approve revaluation requests post-publication', actions: [
            ElevatedButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('New Request'), onPressed: () => _openForm(context, store)),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<RevaluationRequest>(
                rows: store.revaluations,
                columns: [
                  AppColumn(label: 'Student', width: 150, cellBuilder: (r) => Text(store.studentById(r.studentId).name)),
                  AppColumn(label: 'Subject', width: 110, cellBuilder: (r) => Text(store.subjectById(r.subjectId)?.name ?? '-')),
                  AppColumn(label: 'Original', width: 80, cellBuilder: (r) => Text('${r.originalMarks}')),
                  AppColumn(label: 'Revised', width: 80, cellBuilder: (r) => Text(r.revisedMarks?.toString() ?? '-')),
                  AppColumn(label: 'Reason', width: 180, cellBuilder: (r) => Text(r.reason, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  AppColumn(label: 'Status', width: 130, cellBuilder: (r) => StatusBadge(r.status.name, color: AppColors.info)),
                  AppColumn(
                    label: 'Action',
                    width: 190,
                    cellBuilder: (r) => r.status == RevaluationStatus.requested
                        ? OutlinedButton(onPressed: () => store.decideRevaluation(r.id, RevaluationStatus.assigned), child: const Text('Assign for Recheck', style: TextStyle(fontSize: 11.5)))
                        : (r.status == RevaluationStatus.assigned
                            ? OutlinedButton(
                                onPressed: () => store.decideRevaluation(r.id, RevaluationStatus.reevaluated, revisedMarks: r.originalMarks + 3),
                                child: const Text('Record Re-evaluation', style: TextStyle(fontSize: 11.5)),
                              )
                            : (r.status == RevaluationStatus.reevaluated
                                ? Row(mainAxisSize: MainAxisSize.min, children: [
                                    TextButton(onPressed: () => store.decideRevaluation(r.id, RevaluationStatus.rejected), child: const Text('Reject')),
                                    FilledButton(onPressed: () => store.decideRevaluation(r.id, RevaluationStatus.approved), child: const Text('Approve')),
                                  ])
                                : const Text('—'))),
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

  void _openForm(BuildContext context, AppStore store) {
    String studentId = store.students.first.id;
    String subjectId = store.subjects.first.id;
    final reasonCtrl = TextEditingController();
    final marksCtrl = TextEditingController(text: '60');
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setD) {
        return AlertDialog(
          title: const Text('New Revaluation Request'),
          content: SizedBox(
            width: 400,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: studentId,
                decoration: const InputDecoration(labelText: 'Student'),
                items: store.students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setD(() => studentId = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: subjectId,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setD(() => subjectId = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: marksCtrl, decoration: const InputDecoration(labelText: 'Original Marks'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason'), maxLines: 2),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                store.createRevaluation(RevaluationRequest(
                  studentId: studentId,
                  bookId: 'manual-ref',
                  subjectId: subjectId,
                  originalMarks: int.tryParse(marksCtrl.text) ?? 0,
                  reason: reasonCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Submit Request'),
            ),
          ],
        );
      }),
    );
  }
}
