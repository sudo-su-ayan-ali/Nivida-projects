import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';

const _uuid = Uuid();

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  Future<void> _openForm() async {
    final state = context.read<AppState>();
    final result = await showDialog<LoanAdvance>(
      context: context,
      builder: (_) => _LoanDialog(employees: state.employees),
    );
    if (result != null) {
      state.addLoan(result);
      showAppToast(context, 'Loan/advance recorded');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Loans & Advances',
          subtitle: 'Manage employee loans, salary advances and EMIs',
          actions: [PrimaryButton(label: 'New Loan', onPressed: _openForm)],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const [
              'Employee', 'Loan Type', 'Amount', 'Interest', 'Tenure', 'EMI', 'Remaining', 'Status'
            ],
            emptyMessage: 'No loans or advances recorded',
            rows: [
              for (final l in state.loans)
                DataRow(cells: [
                  DataCell(Text(l.employeeName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(l.loanType)),
                  DataCell(Text('₹${l.amount.toStringAsFixed(0)}')),
                  DataCell(Text('${l.interestPercent}%')),
                  DataCell(Text('${l.tenureMonths} months')),
                  DataCell(Text('₹${l.emi.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700))),
                  DataCell(Text('₹${l.remaining.toStringAsFixed(0)}')),
                  DataCell(StatusBadge.forStatus(l.status)),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoanDialog extends StatefulWidget {
  final List<Employee> employees;
  const _LoanDialog({required this.employees});

  @override
  State<_LoanDialog> createState() => _LoanDialogState();
}

class _LoanDialogState extends State<_LoanDialog> {
  Employee? _employee;
  String _type = 'Salary Advance';
  final _amount = TextEditingController();
  final _interest = TextEditingController(text: '0');
  final _tenure = TextEditingController(text: '6');

  double get _amountV => double.tryParse(_amount.text) ?? 0;
  double get _interestV => double.tryParse(_interest.text) ?? 0;
  int get _tenureV => int.tryParse(_tenure.text) ?? 1;

  double get _emi {
    if (_tenureV == 0) return 0;
    final withInterest = _amountV + (_amountV * _interestV / 100);
    return withInterest / _tenureV;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('New Loan / Advance'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Employee>(
                value: _employee,
                decoration: const InputDecoration(labelText: 'Employee'),
                items: widget.employees.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => _employee = v),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Loan Type'),
                items: const ['Salary Advance', 'Personal Loan', 'Emergency Loan', 'Festival Advance']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _interest,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Interest (%)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _tenure,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Tenure (months)'),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                width: double.infinity,
                child: Text('Estimated EMI: ₹${_emi.toStringAsFixed(0)} / month',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_employee == null || _amountV <= 0) return;
            Navigator.pop(
              context,
              LoanAdvance(
                id: _uuid.v4(),
                employeeId: _employee!.id,
                employeeName: _employee!.name,
                loanType: _type,
                amount: _amountV,
                interestPercent: _interestV,
                tenureMonths: _tenureV,
                startDate: DateTime.now(),
                remaining: _amountV + (_amountV * _interestV / 100),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
