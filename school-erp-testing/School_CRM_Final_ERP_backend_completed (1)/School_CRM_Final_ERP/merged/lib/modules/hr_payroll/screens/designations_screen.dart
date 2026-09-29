import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';

const _uuid = Uuid();

class DesignationsScreen extends StatefulWidget {
  const DesignationsScreen({super.key});

  @override
  State<DesignationsScreen> createState() => _DesignationsScreenState();
}

class _DesignationsScreenState extends State<DesignationsScreen> {
  String _search = '';
  String? _deptFilter;

  Future<void> _openForm({Designation? existing}) async {
    final state = context.read<AppState>();
    final result = await showDialog<Designation>(
      context: context,
      builder: (_) => _DesignationDialog(
          existing: existing, departments: state.departments.map((d) => d.name).toList()),
    );
    if (result != null) {
      if (existing != null) {
        state.updateDesignation(result);
        showAppToast(context, 'Designation updated');
      } else {
        state.addDesignation(result);
        showAppToast(context, 'Designation added');
      }
    }
  }

  Future<void> _delete(Designation d) async {
    final confirmed = await showConfirmDialog(context,
        title: 'Delete Designation',
        message: 'Delete "${d.name}"?',
        confirmLabel: 'Delete',
        danger: true);
    if (confirmed) {
      context.read<AppState>().deleteDesignation(d.id);
      showAppToast(context, 'Designation deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.designations.where((d) {
      final matchesSearch = _search.isEmpty || d.name.toLowerCase().contains(_search.toLowerCase());
      final matchesDept = _deptFilter == null || d.department == _deptFilter;
      return matchesSearch && matchesDept;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Designations',
          subtitle: '${state.designations.length} job titles configured',
          actions: [PrimaryButton(label: 'Add Designation', onPressed: () => _openForm())],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 12, runSpacing: 12, children: [
                SearchField(hint: 'Search designations', onChanged: (v) => setState(() => _search = v)),
                FilterDropdown<String>(
                  hint: 'Department',
                  value: _deptFilter,
                  items: state.departments.map((d) => d.name).toList(),
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() => _deptFilter = v),
                ),
              ]),
              const SizedBox(height: 16),
              AppTable(
                columns: const ['Designation', 'Department', 'Description', 'Employees', 'Status', 'Actions'],
                emptyMessage: 'No designations found',
                rows: [
                  for (final d in list)
                    DataRow(cells: [
                      DataCell(Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(d.department)),
                      DataCell(SizedBox(
                          width: 220,
                          child: Text(d.description, overflow: TextOverflow.ellipsis))),
                      DataCell(Text('${state.employeeCountForDesignation(d.name)}')),
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

class _DesignationDialog extends StatefulWidget {
  final Designation? existing;
  final List<String> departments;
  const _DesignationDialog({this.existing, required this.departments});

  @override
  State<_DesignationDialog> createState() => _DesignationDialogState();
}

class _DesignationDialogState extends State<_DesignationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _description;
  String? _department;
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _description = TextEditingController(text: widget.existing?.description ?? '');
    _department = widget.existing?.department ??
        (widget.departments.isNotEmpty ? widget.departments.first : null);
    _status = widget.existing?.status ?? 'Active';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? 'Edit Designation' : 'Add Designation'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Designation Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _department,
                decoration: const InputDecoration(labelText: 'Department'),
                items: widget.departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _department = v),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
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
            if (!_formKey.currentState!.validate() || _department == null) return;
            Navigator.pop(
              context,
              Designation(
                id: widget.existing?.id ?? _uuid.v4(),
                name: _name.text.trim(),
                department: _department!,
                description: _description.text.trim(),
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
