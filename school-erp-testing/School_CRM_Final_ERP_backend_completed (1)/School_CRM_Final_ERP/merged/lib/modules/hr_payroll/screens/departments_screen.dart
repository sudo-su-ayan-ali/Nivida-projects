import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';

const _uuid = Uuid();

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  String _search = '';

  Future<void> _openForm({Department? existing}) async {
    final result = await showDialog<Department>(
      context: context,
      builder: (_) => _DepartmentDialog(existing: existing),
    );
    if (result != null) {
      final state = context.read<AppState>();
      if (existing != null) {
        state.updateDepartment(result);
        showAppToast(context, 'Department updated');
      } else {
        state.addDepartment(result);
        showAppToast(context, 'Department added');
      }
    }
  }

  Future<void> _delete(Department d) async {
    final confirmed = await showConfirmDialog(context,
        title: 'Delete Department',
        message: 'Delete "${d.name}"? Employees in this department will be unaffected.',
        confirmLabel: 'Delete',
        danger: true);
    if (confirmed) {
      context.read<AppState>().deleteDepartment(d.id);
      showAppToast(context, 'Department deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.departments
        .where((d) => _search.isEmpty || d.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Departments',
          subtitle: '${state.departments.length} departments · organize your teams',
          actions: [PrimaryButton(label: 'Add Department', onPressed: () => _openForm())],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchField(hint: 'Search departments', onChanged: (v) => setState(() => _search = v)),
              const SizedBox(height: 16),
              AppTable(
                columns: const ['Department', 'Head', 'Employees', 'Status', 'Actions'],
                emptyMessage: 'No departments found',
                rows: [
                  for (final d in list)
                    DataRow(cells: [
                      DataCell(Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(d.head)),
                      DataCell(Text('${state.employeeCountForDepartment(d.name)}')),
                      DataCell(StatusBadge.forStatus(d.status)),
                      DataCell(RowActions(
                        onEdit: () => _openForm(existing: d),
                        onDelete: () => _delete(d),
                      )),
                    ]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DepartmentDialog extends StatefulWidget {
  final Department? existing;
  const _DepartmentDialog({this.existing});

  @override
  State<_DepartmentDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<_DepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _head;
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _head = TextEditingController(text: widget.existing?.head ?? '');
    _status = widget.existing?.status ?? 'Active';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? 'Edit Department' : 'Add Department'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Department Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _head,
                decoration: const InputDecoration(labelText: 'Department Head'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['Active', 'Inactive']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
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
              Department(
                id: widget.existing?.id ?? _uuid.v4(),
                name: _name.text.trim(),
                head: _head.text.trim(),
                status: _status,
              ),
            );
          },
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
