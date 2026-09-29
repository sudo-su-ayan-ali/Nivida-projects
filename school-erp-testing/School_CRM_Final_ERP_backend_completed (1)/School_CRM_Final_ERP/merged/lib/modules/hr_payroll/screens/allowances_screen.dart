import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';

const _uuid = Uuid();

class AllowancesScreen extends StatefulWidget {
  const AllowancesScreen({super.key});

  @override
  State<AllowancesScreen> createState() => _AllowancesScreenState();
}

class _AllowancesScreenState extends State<AllowancesScreen> {
  Future<void> _openForm() async {
    final result = await showDialog<AllowanceDeduction>(
      context: context,
      builder: (_) => const _AllowanceDialog(),
    );
    if (result != null) {
      context.read<AppState>().addAllowanceDeduction(result);
      showAppToast(context, '${result.type} added');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Allowances & Deductions',
          subtitle: 'Manage salary components applied across payroll',
          actions: [PrimaryButton(label: 'Add New', onPressed: _openForm)],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const ['Name', 'Type', 'Calculation', 'Value', 'Applies To', 'Status', 'Actions'],
            emptyMessage: 'No allowances or deductions configured',
            rows: [
              for (final a in state.allowanceDeductions)
                DataRow(cells: [
                  DataCell(Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(StatusBadge(
                      label: a.type,
                      color: a.type == 'Allowance' ? AppColors.success : AppColors.danger)),
                  DataCell(Text(a.calcType)),
                  DataCell(Text(a.calcType == 'Percentage' ? '${a.value}%' : '₹${a.value.toStringAsFixed(0)}')),
                  DataCell(Text(a.appliesTo)),
                  DataCell(Switch(
                    value: a.enabled,
                    onChanged: (_) => state.toggleAllowanceDeduction(a.id),
                  )),
                  DataCell(RowActions(
                    onDelete: () async {
                      final confirmed = await showConfirmDialog(context,
                          title: 'Delete', message: 'Delete "${a.name}"?', confirmLabel: 'Delete', danger: true);
                      if (confirmed) {
                        state.deleteAllowanceDeduction(a.id);
                        showAppToast(context, 'Deleted');
                      }
                    },
                  )),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _AllowanceDialog extends StatefulWidget {
  const _AllowanceDialog();

  @override
  State<_AllowanceDialog> createState() => _AllowanceDialogState();
}

class _AllowanceDialogState extends State<_AllowanceDialog> {
  final _name = TextEditingController();
  final _value = TextEditingController();
  String _type = 'Allowance';
  String _calcType = 'Fixed';
  String _appliesTo = 'All Employees';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Allowance / Deduction'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const ['Allowance', 'Deduction'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _calcType,
              decoration: const InputDecoration(labelText: 'Calculation Type'),
              items: const ['Fixed', 'Percentage'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _calcType = v!),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _value,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: _calcType == 'Percentage' ? 'Percentage (%)' : 'Amount (₹)'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _appliesTo,
              decoration: const InputDecoration(labelText: 'Applies To'),
              items: const ['All Employees', 'Teaching', 'Non-Teaching', 'Administration']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _appliesTo = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              AllowanceDeduction(
                id: _uuid.v4(),
                name: _name.text.trim(),
                type: _type,
                calcType: _calcType,
                value: double.tryParse(_value.text.trim()) ?? 0,
                appliesTo: _appliesTo,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
