import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kpi_card.dart';

class FeeCollectionScreen extends ConsumerStatefulWidget {
  final String? initialStudentId;
  const FeeCollectionScreen({super.key, this.initialStudentId});

  @override
  ConsumerState<FeeCollectionScreen> createState() => _FeeCollectionScreenState();
}

class _FeeCollectionScreenState extends ConsumerState<FeeCollectionScreen> {
  Student? _selected;
  final Set<String> _selectedHeadIds = {};
  String? _selectedInstallmentId;
  final _discountCtrl = TextEditingController(text: '0');
  PaymentMode _mode = PaymentMode.cash;
  final _searchCtrl = TextEditingController();
  bool _isCollecting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialStudentId != null) {
      Future.microtask(() {
        final s = ref.read(studentsProvider).where((s) => s.id == widget.initialStudentId).toList();
        if (s.isNotEmpty) _selectStudent(s.first);
      });
    }
  }

  void _selectStudent(Student s) {
    setState(() {
      _selected = s;
      _selectedHeadIds.clear();
      final nonOptional = s.feeHeads.where((h) => !h.optional).map((h) => h.id).toList();
      if (nonOptional.isNotEmpty) {
        _selectedHeadIds.addAll(nonOptional);
      } else if (s.feeHeads.isNotEmpty) {
        _selectedHeadIds.addAll(s.feeHeads.map((h) => h.id));
      }
      final firstUnpaid = s.installments.where((i) => i.status != InstallmentStatus.paid).toList();
      _selectedInstallmentId = firstUnpaid.isNotEmpty ? firstUnpaid.first.id : (s.installments.isNotEmpty ? s.installments.first.id : null);
      _discountCtrl.text = '0';
    });
  }

  double get _headsTotal {
    if (_selected == null) return 0;
    return _selected!.feeHeads.where((h) => _selectedHeadIds.contains(h.id)).fold(0.0, (a, b) => a + b.amount);
  }

  Installment? get _installment {
    if (_selected == null || _selectedInstallmentId == null) return null;
    return _selected!.installments.where((i) => i.id == _selectedInstallmentId).firstOrNull;
  }

  double get _lateFee {
    final inst = _installment;
    if (inst == null) return 0;
    if (inst.status != InstallmentStatus.overdue) return 0;
    final daysLate = DateTime.now().difference(inst.dueDate).inDays.clamp(0, 999);
    final gracePeriod = 7;
    final billableDays = (daysLate - gracePeriod).clamp(0, 999);
    final fee = billableDays * 25.0; // ₹25/day slab
    return fee.clamp(0, 1500); // capped
  }

  double get _discount => double.tryParse(_discountCtrl.text) ?? 0;

  double get _total => (_headsTotal - _discount + _lateFee).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final students = ref.watch(studentsProvider);
    final query = _searchCtrl.text.toLowerCase().trim();
    final results = query.isEmpty
        ? <Student>[]
        : students.where((s) =>
            s.name.toLowerCase().contains(query) ||
            s.admissionNo.toLowerCase().contains(query) ||
            s.rollNo.toLowerCase().contains(query) ||
            s.parentPhone.contains(query)).take(6).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 980;
        final left = _buildLeft(theme, results);
        final right = _buildRight(theme);
        if (!wide) {
          return SingleChildScrollView(child: Column(children: [left, const SizedBox(height: 16), right]));
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: SingleChildScrollView(child: left)),
            const SizedBox(width: 20),
            SizedBox(width: 360, child: right),
          ],
        );
      }),
    );
  }

  Widget _buildLeft(ThemeData theme, List<Student> results) {
    final query = _searchCtrl.text.toLowerCase().trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          title: 'Select Student',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Search by name or admission no…',
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
              if (query.isNotEmpty && results.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'No student found matching "$query"',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              if (results.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      for (final s in results)
                        ListTile(
                          dense: true,
                          title: Text(s.name),
                          subtitle: Text('${s.admissionNo} · Class ${s.className}-${s.section}'),
                          trailing: Text(Fmt.inr(s.totalDue)),
                          onTap: () {
                            _selectStudent(s);
                            _searchCtrl.clear();
                          },
                        ),
                    ],
                  ),
                ),
              if (_selected != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: AppColors.primary, child: Text(_selected!.name.isNotEmpty ? _selected!.name.substring(0, 1) : '?', style: const TextStyle(color: Colors.white))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selected!.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('${_selected!.admissionNo} · Class ${_selected!.className}-${_selected!.section} · Due: ${Fmt.inr(_selected!.totalDue)}',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/students/${_selected!.id}'),
                        icon: const Icon(Icons.badge_outlined, size: 16),
                        label: const Text('Full Profile'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: 16),
          SectionCard(
            title: 'Select Installment',
            child: _selected!.installments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No fee installments scheduled for this student.', style: theme.textTheme.bodyMedium),
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final i in _selected!.installments)
                        ChoiceChip(
                          label: Text('${i.label} · ${Fmt.inr(i.balance)}'),
                          selected: _selectedInstallmentId == i.id,
                          onSelected: i.status == InstallmentStatus.paid ? null : (_) => setState(() => _selectedInstallmentId = i.id),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Fee Heads',
            child: _selected!.feeHeads.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No fee heads configured for this student.', style: theme.textTheme.bodyMedium),
                  )
                : Column(
                    children: [
                      for (final h in _selected!.feeHeads)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _selectedHeadIds.contains(h.id),
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              _selectedHeadIds.add(h.id);
                            } else {
                              _selectedHeadIds.remove(h.id);
                            }
                          }),
                          title: Text(h.name),
                          subtitle: h.optional ? const Text('Optional head') : null,
                          secondary: Text(Fmt.inr(h.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildRight(ThemeData theme) {
    final inst = _installment;
    return SectionCard(
      title: 'Payment Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sumRow(theme, 'Selected Fee Heads', Fmt.inr(_headsTotal)),
          const SizedBox(height: 10),
          TextField(
            controller: _discountCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Discount / Concession (₹)', prefixIcon: Icon(Icons.local_offer_outlined)),
          ),
          const SizedBox(height: 12),
          if (inst?.status == InstallmentStatus.overdue)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Late fee auto-applied: ${Fmt.inr(_lateFee)} (₹25/day after 7-day grace, capped ₹1,500)', style: theme.textTheme.bodySmall)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text('Payment Mode', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in PaymentMode.values)
                ChoiceChip(
                  avatar: Icon(m.icon, size: 15),
                  label: Text(m.label),
                  selected: _mode == m,
                  onSelected: (_) => setState(() => _mode = m),
                ),
            ],
          ),
          const Divider(height: 32),
          _sumRow(theme, 'Fee Heads', Fmt.inr(_headsTotal)),
          _sumRow(theme, 'Discount', '- ${Fmt.inr(_discount)}'),
          _sumRow(theme, 'Late Fee', '+ ${Fmt.inr(_lateFee)}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Payable', style: theme.textTheme.titleLarge),
              Text(Fmt.inr(_total), style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_selected == null || _isCollecting) ? null : _collectPayment,
              icon: _isCollecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(_isCollecting ? 'Processing...' : 'Collect & Generate Receipt'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sumRow(ThemeData theme, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  void _collectPayment() async {
    if (_selected == null || _isCollecting) return;
    setState(() => _isCollecting = true);

    try {
      final student = _selected!;
      var headAmounts = <String, double>{
        for (final h in student.feeHeads.where((h) => _selectedHeadIds.contains(h.id))) h.name: h.amount,
      };

      // Fallback: If no head was explicitly selected, allocate to Tuition Fee or default head
      if (headAmounts.isEmpty) {
        if (student.feeHeads.isNotEmpty) {
          final first = student.feeHeads.first;
          headAmounts[first.name] = first.amount;
        } else {
          headAmounts['Tuition Fee'] = _total > 0 ? _total : 15000;
        }
      }

      final tx = await ref.read(transactionsProvider.notifier).collect(
            student: student,
            headAmounts: headAmounts,
            discount: _discount,
            lateFee: _lateFee,
            mode: _mode,
            collectedBy: '${ref.read(activeRoleProvider).label} (You)',
          );

      if (_selectedInstallmentId != null) {
        await ref.read(studentsProvider.notifier).applyPayment(
              studentId: student.id,
              installmentId: _selectedInstallmentId!,
              amount: _total,
              mode: _mode.name,
            );
      }

      ref.read(auditLogProvider.notifier).log(
            ref.read(activeRoleProvider).label,
            'Fee Collected',
            '${tx.receiptNo} · ${student.name} · ${Fmt.inr(tx.totalAmount)}',
          );

      if (mounted) {
        context.go('/receipt/${tx.receiptNo}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to collect fee: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCollecting = false);
      }
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}