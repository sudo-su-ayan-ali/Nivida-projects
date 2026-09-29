import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

// ---------------------------------------------------------------------------
// Result Report Card Designer
// ---------------------------------------------------------------------------
class ReportCardTemplate {
  String name;
  Set<String> elements;
  ReportCardTemplate(this.name, this.elements);
}

const kReportCardElements = [
  'School Logo',
  'Student Info',
  'Subject Table',
  'Performance Summary',
  'Grade Scale',
  'Remarks',
  'Signature',
  'QR Code',
];

class ReportCardDesignerScreen extends StatefulWidget {
  const ReportCardDesignerScreen({super.key});
  @override
  State<ReportCardDesignerScreen> createState() => _ReportCardDesignerScreenState();
}

class _ReportCardDesignerScreenState extends State<ReportCardDesignerScreen> {
  final List<ReportCardTemplate> templates = [
    ReportCardTemplate('Default Report Card', {'School Logo', 'Student Info', 'Subject Table', 'Signature'}),
    ReportCardTemplate('Detailed Report Card', {'School Logo', 'Student Info', 'Subject Table', 'Performance Summary', 'Grade Scale', 'Remarks', 'Signature'}),
    ReportCardTemplate('Summary Report Card', {'Student Info', 'Subject Table', 'Signature'}),
  ];
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final student = store.students.first;
    final result = store.results.where((r) => r.studentId == student.id).isNotEmpty ? store.results.firstWhere((r) => r.studentId == student.id) : null;
    final template = templates[selected];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Result Report Card Designer', subtitle: 'Design and customize report card templates', actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Template'),
              onPressed: () {
                setState(() => templates.add(ReportCardTemplate('New Template ${templates.length + 1}', {'Student Info', 'Subject Table'})));
              },
            ),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Templates', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        ...templates.asMap().entries.map((e) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              selected: selected == e.key,
                              selectedTileColor: AppColors.primary.withOpacity(0.08),
                              leading: const Icon(Icons.description_outlined),
                              title: Text(e.value.name),
                              onTap: () => setState(() => selected = e.key),
                            )),
                        const Divider(height: 24),
                        const Text('Elements', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text('Drag & drop elements to customize', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        ...kReportCardElements.map((el) => CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(el, style: const TextStyle(fontSize: 13)),
                              value: template.elements.contains(el),
                              onChanged: (v) => setState(() => v == true ? template.elements.add(el) : template.elements.remove(el)),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('Preview', style: TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          ElevatedButton.icon(icon: const Icon(Icons.save_outlined, size: 16), label: const Text('Save Template'), onPressed: () => showAppSnack(context, 'Template "${template.name}" saved.')),
                        ]),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (template.elements.contains('School Logo')) Row(children: const [Icon(Icons.school_rounded, color: AppColors.primary), SizedBox(width: 8), Text('Sunrise Public School', style: TextStyle(fontWeight: FontWeight.w700))]),
                              const SizedBox(height: 10),
                              if (template.elements.contains('Student Info')) ...[
                                Text('Student Name: ${student.name}'),
                                Text('Class / Section: 10-${student.section}   Roll No: ${student.rollNo}'),
                                const SizedBox(height: 10),
                              ],
                              if (template.elements.contains('Subject Table') && result != null)
                                Table(
                                  border: TableBorder.all(color: AppColors.border),
                                  children: [
                                    const TableRow(children: [Padding(padding: EdgeInsets.all(6), child: Text('Subject', style: TextStyle(fontWeight: FontWeight.w700))), Padding(padding: EdgeInsets.all(6), child: Text('Marks', style: TextStyle(fontWeight: FontWeight.w700))), Padding(padding: EdgeInsets.all(6), child: Text('Grade', style: TextStyle(fontWeight: FontWeight.w700)))]),
                                    ...result.subjects.map((s) => TableRow(children: [
                                          Padding(padding: const EdgeInsets.all(6), child: Text(store.subjectById(s.subjectId)?.name ?? s.subjectId)),
                                          Padding(padding: const EdgeInsets.all(6), child: Text('${s.marksObtained}/${s.maxMarks}')),
                                          Padding(padding: const EdgeInsets.all(6), child: Text(s.grade)),
                                        ])),
                                  ],
                                )
                              else if (template.elements.contains('Subject Table'))
                                const Text('(No computed result yet for preview — Result Processing → Compute All Results)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              if (template.elements.contains('Performance Summary') && result != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text('Overall: ${result.percentage.toStringAsFixed(2)}%  •  Grade ${result.overallGrade}  •  Rank ${result.rank ?? "-"}')),
                              if (template.elements.contains('Remarks')) const Padding(padding: EdgeInsets.only(top: 10), child: Text('Remarks: _______________________')),
                              if (template.elements.contains('Signature')) const Padding(padding: EdgeInsets.only(top: 16), child: Text('Principal Signature: _______________________')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exam Reschedule / Cancellation
// ---------------------------------------------------------------------------
class RescheduleScreen extends StatelessWidget {
  const RescheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final exam = store.exams.first;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Exam Reschedule / Cancellation', subtitle: 'Reschedule or cancel scheduled exams'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<ExamSubjectSchedule>(
                rows: exam.schedule,
                columns: [
                  AppColumn(label: 'Exam', width: 150, cellBuilder: (s) => Text(exam.name)),
                  AppColumn(label: 'Subject', width: 130, cellBuilder: (s) => Text(store.subjectById(s.subjectId)?.name ?? s.subjectId)),
                  AppColumn(label: 'Date', width: 110, cellBuilder: (s) => Text(s.date.toString().split(' ').first)),
                  AppColumn(label: 'Time', width: 150, cellBuilder: (s) => Text('${s.startTime} - ${s.endTime}')),
                  AppColumn(label: 'Status', width: 110, cellBuilder: (s) => const StatusBadge('Scheduled', color: AppColors.info)),
                  AppColumn(
                    label: 'Action',
                    width: 200,
                    cellBuilder: (s) => Row(children: [
                      OutlinedButton(
                        onPressed: !store.can(Permission.manageExams) ? null : () => _reschedule(context, store, exam, s),
                        child: const Text('Reschedule', style: TextStyle(fontSize: 11.5)),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: !store.can(Permission.manageExams)
                            ? null
                            : () async {
                                if (await confirmDialog(context, title: 'Cancel exam', message: '${store.subjectById(s.subjectId)?.name} on ${s.date.toString().split(" ").first} will be marked cancelled and a notification queued. Continue?')) {
                                  store.audit.log(actor: store.currentUser!, action: 'Exam cancelled', module: 'Reschedule / Cancellation', referenceId: exam.id, newValue: s.subjectId);
                                  store.upsertNotification(NotificationItem(title: '${exam.name} exam cancelled', body: '${store.subjectById(s.subjectId)?.name} scheduled for ${s.date.toString().split(" ").first} has been cancelled.', audience: NotificationAudience.all, status: NotificationStatus.sent));
                                  if (context.mounted) showAppSnack(context, 'Exam cancelled and notification sent.');
                                }
                              },
                        child: const Text('Cancel', style: TextStyle(fontSize: 11.5, color: AppColors.danger)),
                      ),
                    ]),
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

  void _reschedule(BuildContext context, AppStore store, Examination exam, ExamSubjectSchedule s) {
    DateTime newDate = s.date.add(const Duration(days: 1));
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setD) {
        return AlertDialog(
          title: const Text('Reschedule Exam'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current date: ${s.date.toString().split(" ").first}'),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text('New date: ${newDate.toString().split(" ").first}'),
                onPressed: () async {
                  final picked = await showDatePicker(context: ctx, initialDate: newDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if (picked != null) setD(() => newDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final oldDate = s.date;
                final idx = exam.schedule.indexOf(s);
                exam.schedule[idx] = ExamSubjectSchedule(subjectId: s.subjectId, date: newDate, startTime: s.startTime, endTime: s.endTime, maxMarks: s.maxMarks, passingMarks: s.passingMarks);
                store.upsertExam(exam);
                store.audit.log(actor: store.currentUser!, action: 'Exam rescheduled', module: 'Reschedule / Cancellation', referenceId: exam.id, previousValue: oldDate.toString().split(' ').first, newValue: newDate.toString().split(' ').first);
                store.upsertNotification(NotificationItem(title: '${exam.name} rescheduled', body: '${store.subjectById(s.subjectId)?.name} moved to ${newDate.toString().split(" ").first}.', audience: NotificationAudience.all, status: NotificationStatus.sent));
                Navigator.pop(ctx);
                showAppSnack(context, 'Exam rescheduled.');
              },
              child: const Text('Confirm Reschedule'),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Substitute Invigilator Management
// ---------------------------------------------------------------------------
class SubstituteInvigilatorScreen extends StatelessWidget {
  const SubstituteInvigilatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final needSub = store.duties.where((d) => d.substituteNeeded).length;
    final assigned = store.duties.where((d) => d.substituteInvigilatorId != null).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Substitute Invigilator Management', subtitle: 'Manage substitute invigilators for absent duty staff'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(spacing: 14, runSpacing: 14, children: [
              StatCard(label: 'Total Duty', value: '${store.duties.length}', icon: Icons.event_seat_rounded),
              StatCard(label: 'Substitute Needed', value: '$needSub', icon: Icons.warning_amber_rounded, color: AppColors.warning),
              StatCard(label: 'Assigned', value: '$assigned', icon: Icons.check_circle_rounded, color: AppColors.success),
              StatCard(label: 'Pending', value: '${needSub - assigned}', icon: Icons.hourglass_bottom_rounded, color: AppColors.danger),
            ]),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<InvigilatorDuty>(
                rows: store.duties,
                columns: [
                  AppColumn(label: 'Room', width: 90, cellBuilder: (d) => Text(store.rooms.firstWhere((r) => r.id == d.roomId).name)),
                  AppColumn(label: 'Subject', width: 120, cellBuilder: (d) => Text(store.subjectById(d.subjectId)?.name ?? '-')),
                  AppColumn(label: 'Original Invigilator', width: 160, cellBuilder: (d) => Text(store.invigilators.firstWhere((i) => i.id == d.invigilatorId, orElse: () => Invigilator(userId: '', name: '-')).name)),
                  AppColumn(label: 'Substitute', width: 160, cellBuilder: (d) => Text(d.substituteInvigilatorId == null ? '—' : store.invigilators.firstWhere((i) => i.id == d.substituteInvigilatorId, orElse: () => Invigilator(userId: '', name: '-')).name)),
                  AppColumn(label: 'Status', width: 120, cellBuilder: (d) => StatusBadge(d.substituteInvigilatorId != null ? 'Assigned' : (d.substituteNeeded ? 'Pending' : 'Not Needed'), color: d.substituteInvigilatorId != null ? AppColors.success : (d.substituteNeeded ? AppColors.warning : AppColors.textSecondary))),
                  AppColumn(
                    label: 'Action',
                    width: 170,
                    cellBuilder: (d) => !store.can(Permission.assignInvigilators)
                        ? const Text('—')
                        : Row(children: [
                            if (!d.substituteNeeded)
                              TextButton(onPressed: () => _toggleNeeded(store, d, true), child: const Text('Mark Absent', style: TextStyle(fontSize: 11.5))),
                            if (d.substituteNeeded && d.substituteInvigilatorId == null)
                              ElevatedButton(
                                onPressed: () => _assignSubstitute(context, store, d),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                child: const Text('Assign', style: TextStyle(fontSize: 11.5)),
                              ),
                          ]),
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

  void _toggleNeeded(AppStore store, InvigilatorDuty d, bool needed) {
    d.substituteNeeded = needed;
    store.audit.log(actor: store.currentUser!, action: 'Invigilator marked absent — substitute needed', module: 'Substitute Invigilator Management', referenceId: d.id);
    store.upsertDuty(d);   // ← NAYA — Supabase me save
  }

  void _assignSubstitute(BuildContext context, AppStore store, InvigilatorDuty d) {
    final options = store.invigilators.where((i) => i.id != d.invigilatorId).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Substitute Invigilator'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((i) => ListTile(
                      title: Text(i.name),
                      leading: const Icon(Icons.person_outline),
                                        onTap: () {
                        d.substituteInvigilatorId = i.id;
                        store.audit.log(actor: store.currentUser!, action: 'Substitute invigilator assigned', module: 'Substitute Invigilator Management', referenceId: d.id, newValue: i.name);
                        store.upsertDuty(d);   // ← NAYA — Supabase me save
                        store.notifyListeners();
                        Navigator.pop(ctx);
                      },
                    ))
                .toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Digital Exam Instructions
// ---------------------------------------------------------------------------
class ExamInstructionSet {
  String category;
  List<String> items;
  ExamInstructionSet(this.category, this.items);
}

class DigitalInstructionsScreen extends StatefulWidget {
  const DigitalInstructionsScreen({super.key});
  @override
  State<DigitalInstructionsScreen> createState() => _DigitalInstructionsScreenState();
}

class _DigitalInstructionsScreenState extends State<DigitalInstructionsScreen> {
  final List<ExamInstructionSet> sets = [
    ExamInstructionSet('General Instructions', [
      'Students must reach the exam hall 30 minutes before the start.',
      'Carry your admit card and school ID card.',
      'Electronic devices are strictly prohibited.',
      'No talking or cheating is allowed.',
      'Follow all invigilator instructions.',
      'Use only black/blue pen unless specified.',
    ]),
    ExamInstructionSet('Before the Exam', [
      'Verify seating plan and room number in advance.',
      'Bring all required stationery.',
    ]),
    ExamInstructionSet('During the Exam', [
      'Read all questions carefully before answering.',
      'Raise your hand for any clarification.',
    ]),
    ExamInstructionSet('After the Exam', [
      'Hand over the answer book to the invigilator before leaving.',
      'Do not remove any pages from the answer book.',
    ]),
    ExamInstructionSet('Prohibited Items', [
      'Mobile phones, smartwatches, calculators (unless permitted).',
      'Chits, printed material, unauthorized notes.',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Digital Exam Instructions', subtitle: 'Create and manage exam instructions shown to students', actions: [
            ElevatedButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('Add Instruction'), onPressed: () => _addInstruction(context)),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: sets
                  .map((s) => SizedBox(
                        width: 340,
                        child: SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.category, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              ...s.items.asMap().entries.map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(s.category == 'Prohibited Items' ? Icons.block : Icons.check, size: 15, color: s.category == 'Prohibited Items' ? AppColors.danger : AppColors.success),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12.5))),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save Instructions'),
              onPressed: () {
                store.audit.log(actor: store.currentUser!, action: 'Digital exam instructions saved', module: 'Digital Exam Instructions');
                showAppSnack(context, 'Instructions saved and will show on the student portal.');
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _addInstruction(BuildContext context) {
    String category = sets.first.category;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setD) {
        return AlertDialog(
          title: const Text('Add Instruction'),
          content: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: sets.map((s) => DropdownMenuItem(value: s.category, child: Text(s.category))).toList(),
                onChanged: (v) => setD(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Instruction text'), maxLines: 2),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                setState(() => sets.firstWhere((s) => s.category == category).items.add(ctrl.text.trim()));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      }),
    );
  }
}
