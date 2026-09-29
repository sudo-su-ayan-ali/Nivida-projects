import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';



class PaperSecurityScreen extends StatelessWidget {
  const PaperSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Question Paper Security & Approval', subtitle: 'Access-controlled approval workflow for generated papers'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<QuestionPaperSet>(
                rows: store.paperSets,
                columns: [
                  AppColumn(label: 'Paper', width: 90, cellBuilder: (p) => Text('Set ${p.setLabel}')),
                  AppColumn(label: 'Subject', width: 130, cellBuilder: (p) => Text(store.subjectById(p.subjectId)?.name ?? '-')),
                  AppColumn(label: 'Questions', width: 90, cellBuilder: (p) => Text('${p.questionIds.length}')),
                  AppColumn(label: 'Marks', width: 70, cellBuilder: (p) => Text('${p.totalMarks}')),
                  AppColumn(label: 'Security', width: 170, cellBuilder: (p) => Wrap(spacing: 4, children: [
                        if (p.encryptionEnabled) const StatusBadge('Encrypted', color: AppColors.info),
                        if (p.watermarkEnabled) const StatusBadge('Watermarked', color: AppColors.primary),
                        if (p.downloadRestricted) const StatusBadge('Restricted', color: AppColors.warning),
                      ])),
                  AppColumn(label: 'Status', width: 100, cellBuilder: (p) => StatusBadge(p.status.name, color: _statusColor(p.status))),
                  AppColumn(
                    label: 'Action',
                    width: 140,
                    cellBuilder: (p) => store.can(Permission.approveQuestionPapers) && p.status != PaperStatus.published
                        ? ElevatedButton(
                            onPressed: () => store.setPaperStatus(p.id, _next(p.status)),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                            child: Text(_nextLabel(p.status), style: const TextStyle(fontSize: 12)),
                          )
                        : const Text('—'),
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

  PaperStatus _next(PaperStatus s) => switch (s) {
        PaperStatus.draft => PaperStatus.submitted,
        PaperStatus.submitted => PaperStatus.approved,
        PaperStatus.approved => PaperStatus.published,
        PaperStatus.published => PaperStatus.published,
      };

  String _nextLabel(PaperStatus s) => switch (s) {
        PaperStatus.draft => 'Submit',
        PaperStatus.submitted => 'Approve',
        PaperStatus.approved => 'Publish',
        PaperStatus.published => 'Published',
      };

  Color _statusColor(PaperStatus s) => switch (s) {
        PaperStatus.draft => AppColors.textSecondary,
        PaperStatus.submitted => AppColors.warning,
        PaperStatus.approved => AppColors.info,
        PaperStatus.published => AppColors.success,
      };
}
