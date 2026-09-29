import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

class EligibilityScreen extends StatelessWidget {
  const EligibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final exam = store.exams.isNotEmpty ? store.exams.first : null;
    final rows = exam == null
        ? <MapEntry<Student, EligibilityRecord>>[]
        : store.students.map((s) {
            final rec = store.eligibility.firstWhere(
              (e) => e.studentId == s.id && e.examId == exam.id,
              orElse: () => EligibilityRecord(studentId: s.id, examId: exam.id, status: EligibilityStatus.eligible),
            );
            return MapEntry(s, rec);
          }).toList();

    final eligible = rows.where((r) => r.value.status == EligibilityStatus.eligible).length;
    final notEligible = rows.where((r) => r.value.status == EligibilityStatus.notEligible).length;
    final conditional = rows.where((r) => r.value.status == EligibilityStatus.conditional).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Student Eligibility', subtitle: 'Review exam eligibility for every student'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(spacing: 14, runSpacing: 14, children: [
              StatCard(label: 'Total Students', value: '${rows.length}', icon: Icons.groups_rounded),
              StatCard(label: 'Eligible', value: '$eligible', icon: Icons.check_circle_rounded, color: AppColors.success),
              StatCard(label: 'Not Eligible', value: '$notEligible', icon: Icons.cancel_rounded, color: AppColors.danger),
              StatCard(label: 'Conditional', value: '$conditional', icon: Icons.info_rounded, color: AppColors.warning),
            ]),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<MapEntry<Student, EligibilityRecord>>(
                rows: rows,
                searchHint: 'Search student...',
                searchMatcher: (r, q) => r.key.name.toLowerCase().contains(q) || r.key.rollNo.contains(q),
                columns: [
                  AppColumn(label: 'Roll No.', width: 70, cellBuilder: (r) => Text(r.key.rollNo)),
                  AppColumn(label: 'Student Name', width: 180, cellBuilder: (r) => Text(r.key.name)),
                  AppColumn(label: 'Class', width: 90, cellBuilder: (r) => Text('10-${r.key.section}')),
                  AppColumn(label: 'Status', cellBuilder: (r) => StatusBadge(r.value.status.name, color: _color(r.value.status))),
                  AppColumn(label: 'Reason', width: 180, cellBuilder: (r) => Text(r.value.reason.isEmpty ? '—' : r.value.reason)),
                  AppColumn(
                    label: 'Action',
                    width: 130,
                    cellBuilder: (r) => exam == null || !store.can(Permission.manageEligibility)
                        ? const SizedBox()
                        : PopupMenuButton<EligibilityStatus>(
                            onSelected: (v) => store.setEligibility(EligibilityRecord(studentId: r.key.id, examId: exam.id, status: v, reason: r.value.reason)),
                            itemBuilder: (_) => EligibilityStatus.values.map((s) => PopupMenuItem(value: s, child: Text(s.name))).toList(),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Update'), Icon(Icons.arrow_drop_down, size: 18)]),
                          ),
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

  Color _color(EligibilityStatus s) => switch (s) {
        EligibilityStatus.eligible => AppColors.success,
        EligibilityStatus.notEligible => AppColors.danger,
        EligibilityStatus.conditional => AppColors.warning,
      };
}
