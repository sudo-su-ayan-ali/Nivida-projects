import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kpi_card.dart';

class StudentProfileScreen extends ConsumerWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);
    final student = students.where((s) => s.id == studentId).firstOrNull;
    final theme = Theme.of(context);

    if (student == null) {
      return const Center(child: Text('Student not found'));
    }

    final transactions = ref.watch(transactionsProvider).where((t) => t.studentId == studentId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: () => context.go('/students'), icon: const Icon(Icons.arrow_back_rounded)),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                                child: Text(student.name.isNotEmpty ? student.name.substring(0, 1) : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: theme.textTheme.headlineSmall),
                    Text('${student.admissionNo} · Class ${student.className}-${student.section} · Roll ${student.rollNo} · ${student.feeCategory}',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/collect?student=${student.id}'),
                icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                label: const Text('Collect Fee'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _RequestWaiverDialog(
                    studentId: student.id,
                    studentName: student.name,
                    balanceDue: student.totalDue,
                  ),
                ),
                icon: const Icon(Icons.request_quote_rounded, size: 18),
                label: const Text('Request Waiver'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth > 900 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.3,
              children: [
                KpiCard(label: 'Total Fee', value: Fmt.inr(student.totalFee), icon: Icons.account_balance_wallet_outlined, accent: AppColors.primary),
                KpiCard(label: 'Paid', value: Fmt.inr(student.totalPaid), icon: Icons.check_circle_outline_rounded, accent: AppColors.success),
                KpiCard(label: 'Balance Due', value: Fmt.inr(student.totalDue), icon: Icons.pending_actions_rounded, accent: AppColors.warning),
                KpiCard(label: 'Scholarship', value: '${student.scholarshipPercent.toStringAsFixed(0)}%', icon: Icons.school_outlined, accent: AppColors.accent),
              ],
            );
          }),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 950;
            final heads = _FeeHeadsCard(student: student);
            final parent = _ParentInfoCard(student: student);
            if (!wide) return Column(children: [heads, const SizedBox(height: 16), parent]);
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: heads),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: parent),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 16),
          _InstallmentTimelineCard(student: student),
          const SizedBox(height: 16),
          _HistoryCard(transactions: transactions),
        ],
      ),
    );
  }
}
class _RequestWaiverDialog extends StatefulWidget {
  final String studentId;
  final String studentName;
  final double balanceDue;

  const _RequestWaiverDialog({
    required this.studentId,
    required this.studentName,
    required this.balanceDue,
  });

  @override
  State<_RequestWaiverDialog> createState() => _RequestWaiverDialogState();
}

class _RequestWaiverDialogState extends State<_RequestWaiverDialog> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0 || _reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount aur reason dono bharo')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      var institutionId = '00000000-0000-0000-0000-000000000001';
      if (userId != null) {
        final profile = await client.from('profiles').select('institution_id').eq('id', userId).maybeSingle();
        if (profile != null && profile['institution_id'] != null) {
          institutionId = profile['institution_id'] as String;
        }
      }

      await client.from('fee_waivers').insert({
        'institution_id': institutionId,
        'student_id': widget.studentId,
        'amount': amount,
        'reason': _reasonCtrl.text.trim(),
        'requested_by': userId,
        'requested_by_name': client.auth.currentUser?.email ?? 'Unknown',
        'status': 'pending',
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waiver request bhej di gayi — principal approval ka wait hai')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request Fee Waiver — ${widget.studentName}'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Balance Due: ₹${widget.balanceDue.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Waiver Amount (₹)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Request'),
        ),
      ],
    );
  }
}
extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _FeeHeadsCard extends StatelessWidget {
  final Student student;
  const _FeeHeadsCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Fee Head Breakdown',
      child: Column(
        children: [
          for (final h in student.feeHeads)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(h.name, style: Theme.of(context).textTheme.bodyMedium)),
                  if (h.optional) const Padding(padding: EdgeInsets.only(right: 8), child: StatusChip(label: 'Optional', color: AppColors.info)),
                  Text(Fmt.inr(h.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: Text('Total', style: Theme.of(context).textTheme.titleMedium)),
              Text(Fmt.inr(student.totalFee), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParentInfoCard extends StatelessWidget {
  final Student student;
  const _ParentInfoCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Parent / Guardian',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(context, Icons.person_outline_rounded, student.parentName),
          _infoRow(context, Icons.phone_outlined, student.parentPhone),
          _infoRow(context, Icons.email_outlined, student.parentEmail),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (student.transport) const StatusChip(label: 'Transport', color: AppColors.info),
              if (student.hostel) const StatusChip(label: 'Hostel', color: AppColors.accentAmber),
              StatusChip(label: student.feeCategory, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      );
}

class _InstallmentTimelineCard extends StatelessWidget {
  final Student student;
  const _InstallmentTimelineCard({required this.student});

  Color _statusColor(InstallmentStatus s) => switch (s) {
        InstallmentStatus.paid => AppColors.success,
        InstallmentStatus.pending => AppColors.warning,
        InstallmentStatus.upcoming => AppColors.info,
        InstallmentStatus.overdue => AppColors.danger,
      };

  String _statusLabel(InstallmentStatus s) => switch (s) {
        InstallmentStatus.paid => 'Paid',
        InstallmentStatus.pending => 'Partially Paid',
        InstallmentStatus.upcoming => 'Upcoming',
        InstallmentStatus.overdue => 'Overdue',
      };

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Installment Planner',
      child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 700;
        if (!wide) {
          return Column(children: [for (final i in student.installments) _instTile(context, i)]);
        }
        return Row(
          children: [for (final i in student.installments) Expanded(child: _instTile(context, i))],
        );
      }),
    );
  }

  Widget _instTile(BuildContext context, Installment i) {
    final color = _statusColor(i.status);
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(i.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Due: ${Fmt.date(i.dueDate)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(Fmt.inr(i.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
          if (i.paidAmount > 0) Text('Paid: ${Fmt.inr(i.paidAmount)}', style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 8),
          StatusChip(label: _statusLabel(i.status), color: color),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final List<FeeTransaction> transactions;
  const _HistoryCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Payment History',
      child: transactions.isEmpty
          ? const Padding(padding: EdgeInsets.all(12), child: Text('No payment history yet.'))
          : Column(
              children: [
                for (final t in transactions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(t.mode.icon, color: AppColors.primary),
                    title: Text('${t.receiptNo} · ${t.mode.label}'),
                    subtitle: Text(Fmt.dateTime(t.date)),
                    trailing: Text(Fmt.inr(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
    );
  }
  
}
