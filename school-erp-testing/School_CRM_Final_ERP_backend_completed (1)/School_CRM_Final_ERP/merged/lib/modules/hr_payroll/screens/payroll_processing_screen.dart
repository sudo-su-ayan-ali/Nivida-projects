import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';

const months = ['January 2024', 'February 2024', 'March 2024', 'April 2024', 'May 2024', 'June 2024'];

class PayrollProcessingScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const PayrollProcessingScreen({super.key, this.args = const {}});

  @override
  State<PayrollProcessingScreen> createState() => _PayrollProcessingScreenState();
}

class _PayrollProcessingScreenState extends State<PayrollProcessingScreen> {
  String _month = 'May 2024';
  String _department = 'All Departments';
  bool _handledArgs = false;

  @override
  void initState() {
    super.initState();
    if (widget.args['month'] is String) {
      _month = widget.args['month'] as String;
    }
    if (widget.args['department'] is String) {
      _department = widget.args['department'] as String;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledArgs && widget.args['openProcess'] == true) {
      _handledArgs = true;
      final state = context.read<AppState>();
      WidgetsBinding.instance.addPostFrameCallback((_) => _process(state));
    }
  }

  @override
  void didUpdateWidget(PayrollProcessingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.args['openProcess'] == true && oldWidget.args != widget.args) {
      final state = context.read<AppState>();
      WidgetsBinding.instance.addPostFrameCallback((_) => _process(state));
    }
  }

  Future<void> _process(AppState state) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Process Payroll',
      message:
          'Process payroll for $_month${_department != 'All Departments' ? ' — $_department' : ' — all departments'}? This will finalize salary calculations.',
      confirmLabel: 'Process',
    );
    if (confirmed) {
      state.processPayrollForMonth(_month, department: _department);
      if (mounted) showAppToast(context, 'Payroll processed for $_month');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final records = state.payrollRecords.where((p) {
      final matchesMonth = p.month == _month;
      final matchesDept = _department == 'All Departments' || p.department == _department;
      return matchesMonth && matchesDept;
    }).toList();

    final totalGross = records.fold(0.0, (a, b) => a + b.gross);
    final totalNet = records.fold(0.0, (a, b) => a + b.net);
    final totalDeductions = records.fold(0.0, (a, b) => a + b.deductions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Payroll Processing',
          subtitle: 'Calculate and process monthly payroll',
          actions: [
            SecondaryButton(
                label: 'Calculate', icon: Icons.calculate_outlined, onPressed: () => setState(() {})),
            PrimaryButton(
                label: 'Process Payroll', icon: Icons.play_arrow_outlined, onPressed: () => _process(state)),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterDropdown<String>(
                hint: 'Month',
                value: _month,
                items: months,
                labelBuilder: (v) => v,
                onChanged: (v) => setState(() => _month = v ?? _month),
              ),
              FilterDropdown<String>(
                hint: 'Department',
                value: _department,
                items: ['All Departments', ...state.departments.map((d) => d.name)],
                labelBuilder: (v) => v,
                onChanged: (v) => setState(() => _department = v ?? _department),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 700 ? 3 : 1;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 3,
            children: [
              _SummaryCard(label: 'Gross Salary', value: totalGross, color: AppColors.primary),
              _SummaryCard(label: 'Total Deductions', value: totalDeductions, color: AppColors.danger),
              _SummaryCard(label: 'Net Payroll', value: totalNet, color: AppColors.success),
            ],
          );
        }),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const ['Employee', 'Department', 'Gross Salary', 'Allowances', 'Deductions', 'Net Salary', 'Status'],
            emptyMessage: 'No payroll records for this selection. Click Process Payroll to generate.',
            rows: [
              for (final p in records)
                DataRow(cells: [
                  DataCell(Text(p.employeeName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(p.department)),
                  DataCell(Text('₹${p.gross.toStringAsFixed(0)}')),
                  DataCell(Text('₹${p.allowances.toStringAsFixed(0)}')),
                  DataCell(Text('₹${p.deductions.toStringAsFixed(0)}')),
                  DataCell(Text('₹${p.net.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700))),
                  DataCell(StatusBadge.forStatus(_statusLabel(p.status))),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

String _statusLabel(PayrollStatus s) {
  switch (s) {
    case PayrollStatus.draft:
      return 'Draft';
    case PayrollStatus.processed:
      return 'Processed';
    case PayrollStatus.paid:
      return 'Paid';
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('₹${value.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
