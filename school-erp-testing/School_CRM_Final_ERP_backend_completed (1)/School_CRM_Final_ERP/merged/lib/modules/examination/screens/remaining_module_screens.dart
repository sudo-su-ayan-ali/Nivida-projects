import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../services/security_services.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

// ---------------------------------------------------------------------------
// Admit Card Management
// ---------------------------------------------------------------------------
class AdmitCardsScreen extends StatelessWidget {
  const AdmitCardsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final exam = store.exams.first;
    final subjects = exam.schedule.map((s) => store.subjectById(s.subjectId)).whereType<Subject>().toList();
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Admit Card Management', subtitle: 'Generate, preview, print & export admit cards'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: AppDataTable<Student>(
              rows: store.students,
              searchHint: 'Search student...',
              searchMatcher: (s, q) => s.name.toLowerCase().contains(q) || s.rollNo.contains(q),
              columns: [
                AppColumn(label: 'Roll No.', width: 70, cellBuilder: (s) => Text(s.rollNo)),
                AppColumn(label: 'Student', width: 180, cellBuilder: (s) => Text(s.name)),
                AppColumn(label: 'Class', width: 90, cellBuilder: (s) => Text('10-${s.section}')),
                AppColumn(
                  label: 'Action',
                  width: 160,
                  cellBuilder: (s) => OutlinedButton.icon(
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('Download PDF', style: TextStyle(fontSize: 11.5)),
                    onPressed: () => PdfService.printAdmitCard(s, exam, subjects),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Certificates & Transcripts
// ---------------------------------------------------------------------------
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final published = store.results.where((r) => r.stage == ResultStage.published || r.stage == ResultStage.locked).toList();
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Certificate & Transcript Management', subtitle: 'Marksheets, certificates and transcripts (published results only)'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: published.isEmpty
                ? const EmptyState(message: 'Publish results first — certificates can only be issued for published results.')
                : AppDataTable<ResultRecord>(
                    rows: published,
                    columns: [
                      AppColumn(label: 'Student', width: 170, cellBuilder: (r) => Text(store.studentById(r.studentId).name)),
                      AppColumn(label: 'Grade', width: 80, cellBuilder: (r) => Text(r.overallGrade)),
                      AppColumn(label: 'Verification ID', width: 160, cellBuilder: (r) => Text('CERT-${r.id.substring(0, 8).toUpperCase()}')),
                                            AppColumn(
                        label: 'Action',
                        width: 140,
                        cellBuilder: (r) => OutlinedButton(
                          onPressed: () => _generateCertificate(context, store, r),
                          child: const Text('Generate', style: TextStyle(fontSize: 11.5)),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
Future<void> _generateCertificate(BuildContext context, AppStore store, ResultRecord r) async {
  final exam = store.examById(r.examId);
  if (exam == null) return;
  final student = store.studentById(r.studentId);
  final subjects = r.subjects
      .map((s) => store.subjectById(s.subjectId))
      .whereType<Subject>()
      .toList();

  // 1. Persist the issuance in Supabase and get a stable verification ID.
  final verificationId = await store.recordCertificateIssued(r);

  // 2. Build and open the PDF with that verification ID embedded (QR code).
  await PdfService.printCertificate(
    student,
    exam,
    r,
    subjects,
    verificationId: verificationId,
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Certificate generated: $verificationId')),
    );
  }
}
// ---------------------------------------------------------------------------
// Special Accommodation
// ---------------------------------------------------------------------------
class AccommodationScreen extends StatelessWidget {
  const AccommodationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Special Examination Accommodation', subtitle: 'Approved arrangements for students with additional needs — visible only to authorized roles'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: store.accommodations.isEmpty
                ? const EmptyState(message: 'No accommodation records.')
                : Column(
                    children: store.accommodations
                        .map((a) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.accessible_rounded, color: AppColors.primary),
                              title: Text(store.studentById(a.studentId).name),
                              subtitle: Text('${a.type.name} — ${a.details}'),
                              trailing: StatusBadge(a.approved ? 'Approved' : 'Pending', color: a.approved ? AppColors.success : AppColors.warning),
                            ))
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: 'Notifications / Alerts Center', subtitle: 'Automated and manual notifications', actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Notification'),
            onPressed: () => _openForm(context, store),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: store.notifications.isEmpty
                ? const EmptyState(message: 'No notifications yet.')
                : Column(
                    children: store.notifications
                        .map((n) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.notifications_none_rounded),
                              title: Text(n.title),
                              subtitle: Text('${n.body}  •  Audience: ${n.audience.name}'),
                              trailing: StatusBadge(n.status.name, color: n.status == NotificationStatus.sent ? AppColors.success : AppColors.warning),
                            ))
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  void _openForm(BuildContext context, AppStore store) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    NotificationAudience audience = NotificationAudience.all;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setD) {
        return AlertDialog(
          title: const Text('Create Notification'),
          content: SizedBox(
            width: 400,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
              const SizedBox(height: 12),
              DropdownButtonFormField<NotificationAudience>(
                initialValue: audience,
                decoration: const InputDecoration(labelText: 'Audience'),
                items: NotificationAudience.values.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                onChanged: (v) => setD(() => audience = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                store.upsertNotification(NotificationItem(title: titleCtrl.text.trim(), body: bodyCtrl.text.trim(), audience: audience, status: NotificationStatus.sent));
                Navigator.pop(ctx);
              },
              child: const Text('Send Now'),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Student / Parent Portal (role-scoped, read-only view)
// ---------------------------------------------------------------------------
class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final exam = store.exams.first;
    final student = store.students.first; // demo binding
    final result = store.results.where((r) => r.studentId == student.id).firstOrNull;
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: 'Student & Parent Portal', subtitle: 'Portal preview for ${student.name} (Roll ${student.rollNo})'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(spacing: 14, runSpacing: 14, children: [
            StatCard(label: 'Next Exam', value: exam.name, icon: Icons.event_rounded),
            StatCard(label: 'Latest Result', value: result == null ? 'Pending' : '${result.percentage.toStringAsFixed(1)}%', icon: Icons.grade_rounded, color: AppColors.success),
            StatCard(label: 'Overall Grade', value: result?.overallGrade ?? '-', icon: Icons.workspace_premium_rounded, color: AppColors.primary),
          ]),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Recent Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...store.notifications.where((n) => n.audience == NotificationAudience.all || n.audience == NotificationAudience.students).map((n) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.circle_notifications_outlined, color: AppColors.primary),
                    title: Text(n.title),
                    subtitle: Text(n.body),
                  )),
            ]),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Archive
// ---------------------------------------------------------------------------
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final archived = store.exams.where((e) => e.status == ExamStatus.archived || e.status == ExamStatus.completed).toList();
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Archive / Previous Examinations', subtitle: 'Completed examinations, searchable and immutable'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: archived.isEmpty
                ? const EmptyState(message: 'No archived examinations yet. Completed exams will appear here automatically.')
                : Column(children: archived.map((e) => ListTile(title: Text(e.name), trailing: const StatusBadge('Locked / Immutable', color: AppColors.textSecondary))).toList()),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Backup & Data Security
// ---------------------------------------------------------------------------
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final List<Map<String, String>> history = [
    {'date': DateTime.now().subtract(const Duration(days: 1)).toString().split('.').first, 'type': 'Automatic', 'status': 'Success'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Backup / Recovery & Data Security', subtitle: 'Data protection and backup management'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.backup_outlined, size: 18),
                label: const Text('Backup Now'),
                onPressed: () => setState(() => history.insert(0, {'date': DateTime.now().toString().split('.').first, 'type': 'Manual', 'status': 'Success'})),
              ),
              const SizedBox(height: 16),
              const Text('Backup History', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...history.map((h) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
                    title: Text('${h['type']} backup'),
                    subtitle: Text(h['date']!),
                    trailing: const StatusBadge('Success', color: AppColors.success),
                  )),
            ]),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Roles & Permissions matrix (read-only visualization of RbacService)
// ---------------------------------------------------------------------------
class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Roles & Permission Management', subtitle: 'Enforced at the service/repository layer — never UI-only'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bg),
                columns: [
                  const DataColumn(label: Text('Permission', style: TextStyle(fontWeight: FontWeight.w700))),
                  ...AppRole.values.map((r) => DataColumn(label: Text(r.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)))),
                ],
                rows: Permission.values
                    .map((p) => DataRow(cells: [
                          DataCell(Text(p.name, style: const TextStyle(fontSize: 12))),
                          ...AppRole.values.map((r) => DataCell(Icon(
                                RbacService.permissionsFor(r).contains(p) ? Icons.check_circle : Icons.remove_circle_outline,
                                size: 16,
                                color: RbacService.permissionsFor(r).contains(p) ? AppColors.success : AppColors.border,
                              ))),
                        ]))
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Audit Logs
// ---------------------------------------------------------------------------
class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Security & Audit Center', subtitle: 'Immutable log of every sensitive action across the system'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionCard(
            child: AppDataTable<AuditLogEntry>(
              rows: store.audit.entries,
              searchHint: 'Search action or module...',
              searchMatcher: (e, q) => e.action.toLowerCase().contains(q) || e.module.toLowerCase().contains(q),
              columns: [
                AppColumn(label: 'User', width: 120, cellBuilder: (e) => Text(e.actorUserId)),
                AppColumn(label: 'Role', width: 130, cellBuilder: (e) => Text(e.actorRole)),
                AppColumn(label: 'Action', width: 220, cellBuilder: (e) => Text(e.action)),
                AppColumn(label: 'Module', width: 160, cellBuilder: (e) => Text(e.module)),
                AppColumn(label: 'Reference', width: 140, cellBuilder: (e) => Text(e.referenceId ?? '-', overflow: TextOverflow.ellipsis)),
                AppColumn(label: 'Timestamp', width: 160, cellBuilder: (e) => Text(e.timestamp.toString().split('.').first)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

extension _FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
