import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';

const _uuid = Uuid();

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  Future<void> _openForm({Shift? existing}) async {
    final result = await showDialog<Shift>(
      context: context,
      builder: (_) => _ShiftDialog(existing: existing),
    );
    if (result != null) {
      final state = context.read<AppState>();
      if (existing != null) {
        await state.updateShift(result);
        if (context.mounted) showAppToast(context, 'Shift updated');
      } else {
        await state.addShift(result);
        if (context.mounted) showAppToast(context, 'Shift added');
      }
    }
  }

  Future<void> _delete(Shift s) async {
    final confirmed = await showConfirmDialog(context,
        title: 'Delete Shift', message: 'Delete "${s.name}"?', confirmLabel: 'Delete', danger: true);
    if (confirmed) {
      await context.read<AppState>().deleteShift(s.id);
      if (context.mounted) showAppToast(context, 'Shift deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Shift Management',
          subtitle: 'Configure work shifts and assign employees',
          actions: [PrimaryButton(label: 'Add Shift', onPressed: () => _openForm())],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const ['Shift Name', 'Start Time', 'End Time', 'Grace Period', 'Assigned Employees', 'Actions'],
            emptyMessage: 'No shifts configured',
            rows: [
              for (final s in state.shifts)
                DataRow(cells: [
                  DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(s.startTime)),
                  DataCell(Text(s.endTime)),
                  DataCell(Text('${s.graceMinutes} mins')),
                  DataCell(Text('${s.assignedEmployees}')),
                  DataCell(RowActions(
                    onEdit: () => _openForm(existing: s),
                    onDelete: () => _delete(s),
                  )),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShiftDialog extends StatefulWidget {
  final Shift? existing;
  const _ShiftDialog({this.existing});

  @override
  State<_ShiftDialog> createState() => _ShiftDialogState();
}

class _ShiftDialogState extends State<_ShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _start;
  late TextEditingController _end;
  late TextEditingController _grace;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _start = TextEditingController(text: widget.existing?.startTime ?? '09:00 AM');
    _end = TextEditingController(text: widget.existing?.endTime ?? '05:00 PM');
    _grace = TextEditingController(text: '${widget.existing?.graceMinutes ?? 10}');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? 'Edit Shift' : 'Add Shift'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Shift Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _start,
                    decoration: const InputDecoration(labelText: 'Start Time'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _end,
                    decoration: const InputDecoration(labelText: 'End Time'),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              TextFormField(
                controller: _grace,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Grace Period (minutes)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              Shift(
                id: widget.existing?.id ?? _uuid.v4(),
                name: _name.text.trim(),
                startTime: _start.text.trim(),
                endTime: _end.text.trim(),
                graceMinutes: int.tryParse(_grace.text.trim()) ?? 10,
                assignedEmployees: widget.existing?.assignedEmployees ?? 0,
              ),
            );
          },
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}