import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

class ExamManagementScreen extends StatelessWidget {
  const ExamManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Exam Management',
            subtitle: 'Create and manage examinations, subjects & schedules',
            actions: [
              ElevatedButton.icon(
                onPressed:
                    (store.can(Permission.manageExams) &&
                        store.classes.isNotEmpty)
                    ? () => _openExamForm(context, store)
                    : null,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Examination'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<Examination>(
                rows: store.exams,
                searchHint: 'Search exam...',
                searchMatcher: (e, q) => e.name.toLowerCase().contains(q),
                columns: [
                  AppColumn(
                    label: 'Exam Name',
                    width: 220,
                    cellBuilder: (e) => Text(
                      e.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  AppColumn(
                    label: 'Type',
                    cellBuilder: (e) => Text(e.type.label),
                  ),
                  AppColumn(
                    label: 'Class',
                    cellBuilder: (e) => Text(
                      '${store.classes.firstWhere(
                        (c) => c.id == e.classId,
                        orElse: () => SchoolClass(id: '', name: e.classId, sections: []),
                      ).name} (${e.sections.join(", ")})',
                    ),
                  ),
                  AppColumn(
                    label: 'Subjects',
                    cellBuilder: (e) => Text('${e.schedule.length}'),
                  ),
                  AppColumn(
                    label: 'Status',
                    cellBuilder: (e) => StatusBadge(
                      e.status.name,
                      color: _statusColor(e.status),
                    ),
                  ),
                  AppColumn(
                    label: 'Actions',
                    width: 140,
                    cellBuilder: (e) => Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () =>
                              _openExamForm(context, store, existing: e),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          onPressed: () async {
                            if (await confirmDialog(
                              context,
                              title: 'Delete exam',
                              message:
                                  'Delete "${e.name}"? This cannot be undone.',
                            )) {
                              store.deleteExam(e.id);
                            }
                          },
                        ),
                      ],
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

  Color _statusColor(ExamStatus s) => switch (s) {
    ExamStatus.draft => AppColors.textSecondary,
    ExamStatus.scheduled => AppColors.info,
    ExamStatus.ongoing => AppColors.warning,
    ExamStatus.completed => AppColors.success,
    ExamStatus.resultDeclared => AppColors.primary,
    ExamStatus.archived => AppColors.textSecondary,
  };

  void _openExamForm(
    BuildContext context,
    AppStore store, {
    Examination? existing,
  }) {
    showDialog(
      context: context,
      builder: (_) => _ExamFormDialog(store: store, existing: existing),
    );
  }
}

class _ExamFormDialog extends StatefulWidget {
  final AppStore store;
  final Examination? existing;
  const _ExamFormDialog({required this.store, this.existing});

  @override
  State<_ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends State<_ExamFormDialog> {
  late TextEditingController nameCtrl;
  late ExamType type;
  late String classId;
  late List<String> chosenSubjects;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    type = widget.existing?.type ?? ExamType.annual;
    classId =
        widget.existing?.classId ??
        (widget.store.classes.isNotEmpty ? widget.store.classes.first.id : '');
    chosenSubjects =
        widget.existing?.schedule.map((s) => s.subjectId).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final subjectsForClass = widget.store.subjects
        .where((s) => s.classId == classId)
        .toList();
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Create Examination' : 'Edit Examination',
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Exam Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExamType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Exam Type'),
                items: ExamType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => type = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: classId,
                decoration: const InputDecoration(labelText: 'Class'),
                items: widget.store.classes
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  classId = v!;
                  chosenSubjects = [];
                }),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Subjects',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Wrap(
                spacing: 8,
                children: subjectsForClass.map((s) {
                  final selected = chosenSubjects.contains(s.id);
                  return FilterChip(
                    label: Text(s.name),
                    selected: selected,
                    onSelected: (v) => setState(
                      () => v
                          ? chosenSubjects.add(s.id)
                          : chosenSubjects.remove(s.id),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (nameCtrl.text.trim().isEmpty || chosenSubjects.isEmpty) {
              showAppSnack(
                context,
                'Enter a name and choose at least one subject.',
                error: true,
              );
              return;
            }
            final baseDate = DateTime.now().add(const Duration(days: 30));
            final exam = Examination(
              id: widget.existing?.id,
              name: nameCtrl.text.trim(),
              type: type,
              sessionId: widget.store.sessions.isNotEmpty
                  ? widget.store.sessions.first.id
                  : '',
              classId: classId,
              sections:
                  widget.store.classes
                      .where((c) => c.id == classId)
                      .map((c) => c.sections)
                      .firstOrNull ??
                  [],
              schedule: chosenSubjects
                  .asMap()
                  .entries
                  .map(
                    (e) => ExamSubjectSchedule(
                      subjectId: e.value,
                      date: baseDate.add(Duration(days: e.key)),
                      startTime: '09:00 AM',
                      endTime: '12:00 PM',
                      maxMarks: 100,
                      passingMarks: 33,
                    ),
                  )
                  .toList(),
              status: widget.existing?.status ?? ExamStatus.scheduled,
            );
            await widget.store.upsertExam(exam, isNew: widget.existing == null);

            Navigator.pop(context);
            showAppSnack(context, 'Examination saved.');
          },
          child: const Text('Save Exam'),
        ),
      ],
    );
  }
}
