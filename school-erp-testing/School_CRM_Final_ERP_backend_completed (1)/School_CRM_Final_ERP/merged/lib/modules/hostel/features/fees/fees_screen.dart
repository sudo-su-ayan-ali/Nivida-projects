import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../data/hostel_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/pagination.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class FeesScreen extends ConsumerStatefulWidget {
  const FeesScreen({super.key});
  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> {
  String query = '';
  String statusFilter = 'All Status';
  int page = 1;
  final pageSize = 8;
@override
Widget build(BuildContext context) {
  final paymentsAsync = ref.watch(paymentsProvider);
  final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final df = DateFormat('d MMM yyyy');

  return paymentsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text('Error loading fees: $err')),
    data: (payments) {
    final totalCollected = payments.where((p) => p.status == 'Paid').fold(0.0, (s, p) => s + p.amount);
    final totalPending = payments.where((p) => p.status == 'Pending').fold(0.0, (s, p) => s + p.amount);
    final overdue = payments.where((p) => p.status == 'Failed').length;
    final thisMonth = payments.where((p) => p.date.month == DateTime.now().month && p.status == 'Paid').fold(0.0, (s, p) => s + p.amount);

    final filtered = payments.where((p) {
      final matchesQuery = query.isEmpty || p.studentName.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = statusFilter == 'All Status' || p.status == statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    final totalPages = (filtered.length / pageSize).ceil().clamp(1, 999999);
    if (page > totalPages) page = 1;
    final pageItems = filtered.skip((page - 1) * pageSize).take(pageSize).toList();

    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBreadcrumb(items: const ['Fees & Payments']),
          const SizedBox(height: 10),
          const Text('Fees & Payments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Track fee collection, pending dues, and payment history.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.statColumns(context).clamp(1, 4),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.5,
            children: [
              StatCard(icon: Icons.account_balance_wallet_rounded, color: AppColors.success, value: currency.format(totalCollected), label: 'Total Collected'),
              StatCard(icon: Icons.hourglass_bottom_rounded, color: AppColors.warning, value: currency.format(totalPending), label: 'Pending Fees'),
              StatCard(icon: Icons.error_outline_rounded, color: AppColors.danger, value: '$overdue', label: 'Overdue Payments'),
              StatCard(icon: Icons.calendar_month_rounded, color: AppColors.primary, value: currency.format(thisMonth), label: 'This Month Collection'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(width: 240, child: AppSearchField(hint: 'Search student...', onChanged: (v) => setState(() { query = v; page = 1; }))),
                        FilterDropdown(
                          label: 'Status',
                          value: statusFilter,
                          options: const ['All Status', 'Paid', 'Pending', 'Failed', 'Partial'],
                          onChanged: (v) => setState(() { statusFilter = v!; page = 1; }),
                        ),
                      ],
                    ),
                    PrimaryButton(
                      label: 'Collect Fee',
                      icon: Icons.add_rounded,
                      onPressed: () => _showCollectFeeDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppDataTable(
                  minWidth: 1000,
                  columns: const [
                    AppTableColumn('Student Name', width: 150),
                    AppTableColumn('Room No.', width: 90),
                    AppTableColumn('Amount', width: 100),
                    AppTableColumn('Payment Type', width: 120),
                    AppTableColumn('Date', width: 110),
                    AppTableColumn('Status', width: 100),
                    AppTableColumn('Actions', width: 90),
                  ],
                  rowCount: pageItems.length,
                  rowBuilder: (i) {
                    final p = pageItems[i];
                    return [
                      CellText(p.studentName, strong: true),
                      CellText(p.room),
                      CellText(currency.format(p.amount), strong: true, color: AppColors.textPrimary),
                      CellText(p.type),
                      CellText(df.format(p.date)),
                      StatusBadge(status: p.status),
                      IconButton(
                        tooltip: 'View Receipt',
                        icon: const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.textSecondary),
                        onPressed: () => showAppDialog(context, title: 'Payment Receipt', content: _receipt(p, currency, df)),
                      ),
                    ];
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPagination(currentPage: page, totalPages: totalPages, totalItems: filtered.length, pageSize: pageSize, onPageChanged: (p) => setState(() => page = p)),
              ],
            ),
          ),
          ],
      ),
      ),
    );
    },
  );
  }

  Widget _receipt(p, NumberFormat currency, DateFormat df) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Icon(Icons.home_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('HostelHub', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const Spacer(),
            Text(p.invoiceNo, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
          const Divider(height: 28, color: AppColors.divider),
          _row('Student Name', p.studentName),
          _row('Room No.', p.room),
          _row('Amount Paid', currency.format(p.amount)),
          _row('Payment Method', p.type),
          _row('Date', df.format(p.date)),
          _row('Status', p.status),
        ],
      ),
    );
  }

  void _showCollectFeeDialog(BuildContext context) {
    final students = ref.read(studentsProvider).value ?? [];
    if (students.isEmpty) {
      showAppSnackBar(context, 'No hostel students found to collect fee for.', isError: true);
      return;
    }

    String selectedHostelStudentId = students.first.id;
    final amountCtrl = TextEditingController(text: '15000');
    String paymentType = 'Boarding & Mess Fee';
    bool saving = false;

    showAppDialog(
      context,
      title: 'Collect Hostel Fee',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedHostelStudentId,
              decoration: const InputDecoration(labelText: 'Student', border: OutlineInputBorder()),
              items: students.map((s) => DropdownMenuItem<String>(value: s.id, child: Text('${s.name} (${s.room})'))).toList(),
              onChanged: (v) => setState(() => selectedHostelStudentId = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: paymentType,
              decoration: const InputDecoration(labelText: 'Fee Type', border: OutlineInputBorder()),
              items: const ['Boarding & Mess Fee', 'Room Rent', 'Security Deposit', 'Laundry Fee', 'Maintenance Surcharge']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => paymentType = v!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Recording...' : 'Collect Fee',
                  icon: Icons.check_rounded,
                  onPressed: saving ? null : () async {
                    final amt = double.tryParse(amountCtrl.text.trim());
                    if (amt == null || amt <= 0) {
                      showAppSnackBar(context, 'Please enter a valid amount.', isError: true);
                      return;
                    }
                    setState(() => saving = true);
                    try {
                      await HostelService().createFeePayment(
                        hostelStudentId: selectedHostelStudentId,
                        amount: amt,
                        paymentType: paymentType,
                      );
                      ref.invalidate(paymentsProvider);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        showAppSnackBar(context, 'Fee payment of ₹$amt recorded successfully.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showAppSnackBar(context, 'Failed to record fee: $e', isError: true);
                      }
                    } finally {
                      setState(() => saving = false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
          ],
        ),
      );
}
