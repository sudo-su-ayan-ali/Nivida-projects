import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/erp_backup_service.dart';
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
// Backup & Security Screen
// ---------------------------------------------------------------------------
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  static const String _prefKey = 'edusmart_backup_history';
  List<Map<String, String>> history = [];
  bool _isBackingUp = false;
  String _progressMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        if (mounted) {
          setState(() {
            history = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
          });
        }
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        history = [
          {
            'date': DateTime.now().subtract(const Duration(days: 1)).toString().split('.').first,
            'type': 'Automatic',
            'status': 'Success',
            'details': 'System scheduled snapshot',
          },
        ];
      });
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(history));
    } catch (_) {}
  }

  Future<void> _runBackup() async {
    if (_isBackingUp) return;
    setState(() {
      _isBackingUp = true;
      _progressMessage = 'Preparing tables...';
    });

    final nowStr = DateTime.now().toString().split('.').first;
    try {
      final service = ErpBackupService();
      final outcome = await service.exportAllToExcel(
        onProgress: (table, done, total) {
          if (mounted) {
            setState(() {
              _progressMessage = 'Exporting $table ($done/$total)';
            });
          }
        },
      );

      final failedCount = outcome.failed.length;
      final totalRows = outcome.totalRows;
      final status = failedCount == 0 ? 'Success' : (totalRows > 0 ? 'Partial' : 'Failed');
      final details = 'Processed ${outcome.tables.length} tables, $totalRows rows' +
          (failedCount > 0 ? ' ($failedCount failed)' : '');

      final newEntry = {
        'date': nowStr,
        'type': 'Manual',
        'status': status,
        'details': details,
      };

      if (mounted) {
        setState(() {
          history.insert(0, newEntry);
          _isBackingUp = false;
          _progressMessage = '';
        });
        await _saveHistory();

        // Also record in audit trail if store is available
        try {
          final store = context.read<AppStore>();
          if (store.currentUser != null) {
            store.audit.log(
              actor: store.currentUser!,
              action: 'Manual System Backup Generated',
              module: 'Data Security / Backup',
              newValue: 'Rows: $totalRows, Status: $status',
            );
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup complete! $details. File downloaded to your device.'),
            backgroundColor: status == 'Failed' ? AppColors.danger : AppColors.success,
          ),
        );
      }
    } catch (e) {
      final errEntry = {
        'date': nowStr,
        'type': 'Manual',
        'status': 'Failed',
        'details': e.toString(),
      };
      if (mounted) {
        setState(() {
          history.insert(0, errEntry);
          _isBackingUp = false;
          _progressMessage = '';
        });
        await _saveHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(
          title: 'Backup / Recovery & Data Security',
          subtitle: 'Institutional data protection, live Excel export & security audit management',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Institutional Master Backup',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Generates a comprehensive multi-sheet Excel (.xlsx) backup across all ERP tables.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: _isBackingUp
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.download_rounded, size: 18),
                        label: Text(_isBackingUp ? 'Exporting...' : 'Backup Now'),
                        onPressed: _isBackingUp ? null : _runBackup,
                      ),
                    ],
                  ),
                  if (_isBackingUp) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      _progressMessage,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 20),
              SectionCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Backup History & Snapshots',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      if (history.isNotEmpty)
                        TextButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Clear Backup History?'),
                                content: const Text('Are you sure you want to clear the local backup history log?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                                ],
                              ),
                            );
                            if (confirmed == true && mounted) {
                              setState(() => history.clear());
                              await _saveHistory();
                            }
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear History', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('No backup logs found. Click "Backup Now" to create your first backup.'),
                      ),
                    )
                  else
                    ...history.map((h) {
                      final isSuccess = h['status'] == 'Success';
                      final isPartial = h['status'] == 'Partial';
                      final badgeColor = isSuccess
                          ? AppColors.success
                          : (isPartial ? AppColors.warning : AppColors.danger);
                      final icon = isSuccess
                          ? Icons.check_circle_outline
                          : (isPartial ? Icons.warning_amber_rounded : Icons.error_outline);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Icon(icon, color: badgeColor),
                          title: Row(
                            children: [
                              Text('${h['type']} Backup', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              StatusBadge(h['status'] ?? 'Unknown', color: badgeColor),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Created: ${h['date']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              if (h['details'] != null) ...[
                                const SizedBox(height: 2),
                                Text(h['details']!, style: const TextStyle(fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                ]),
              ),
            ],
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
