import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';
import 'employees_screen.dart' show leaveStatusLabel;

const _uuid = Uuid();
const leaveTypes = ['Casual Leave', 'Medical Leave', 'Earned Leave', 'Sick Leave', 'Maternity Leave', 'Paternity Leave'];

class LeaveScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const LeaveScreen({super.key, required this.args});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  String? _statusFilter;
  String? _typeFilter;
  bool _handledArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledArgs && widget.args['openApply'] == true) {
      _handledArgs = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _openApply());
    }
  }

  @override
  void didUpdateWidget(LeaveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.args['openApply'] == true && oldWidget.args != widget.args) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openApply());
    }
  }

  Future<void> _openApply() async {
    final state = context.read<AppState>();
    final result = await showDialog<LeaveRequest>(
      context: context,
      builder: (_) => _ApplyLeaveDialog(employees: state.employees),
    );
    if (result != null) {
      state.applyLeave(result);
      if (mounted) showAppToast(context, 'Leave request submitted');
    }
  }

  void _act(LeaveRequest l, LeaveStatus status) {
    context.read<AppState>().setLeaveStatus(l.id, status);
    showAppToast(context, 'Leave ${leaveStatusLabel(status).toLowerCase()}');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    var list = state.leaves.where((l) {
      final matchesStatus = _statusFilter == null || leaveStatusLabel(l.status) == _statusFilter;
      final matchesType = _typeFilter == null || l.leaveType == _typeFilter;
      return matchesStatus && matchesType;
    }).toList();

    final pending = state.leaves.where((l) => l.status == LeaveStatus.pending).length;
    final approved = state.leaves.where((l) => l.status == LeaveStatus.approved).length;
    final rejected = state.leaves.where((l) => l.status == LeaveStatus.rejected).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Leave Management',
          subtitle: 'Manage leave requests, approvals and balances',
          actions: [PrimaryButton(label: 'Apply Leave', icon: Icons.beach_access_outlined, onPressed: _openApply)],
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
              _StatMini(label: 'Pending Requests', value: '$pending', color: AppColors.warning, icon: Icons.pending_actions),
              _StatMini(label: 'Approved', value: '$approved', color: AppColors.success, icon: Icons.check_circle_outline),
              _StatMini(label: 'Rejected', value: '$rejected', color: AppColors.danger, icon: Icons.cancel_outlined),
            ],
          );
        }),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 12, runSpacing: 12, children: [
                FilterDropdown<String>(
                  hint: 'Leave Type',
                  value: _typeFilter,
                  items: leaveTypes,
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() => _typeFilter = v),
                ),
                FilterDropdown<String>(
                  hint: 'Status',
                  value: _statusFilter,
                  items: const ['Pending', 'Approved', 'Rejected', 'Cancelled'],
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ]),
              const SizedBox(height: 16),
              AppTable(
                columns: const ['Employee', 'Leave Type', 'Start Date', 'End Date', 'Days', 'Reason', 'Status', 'Actions'],
                emptyMessage: 'No leave requests found',
                rows: [
                  for (final l in list)
                    DataRow(cells: [
                      DataCell(Text(l.employeeName, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(l.leaveType)),
                      DataCell(Text(DateFormat('dd MMM yyyy').format(l.startDate))),
                      DataCell(Text(DateFormat('dd MMM yyyy').format(l.endDate))),
                      DataCell(Text('${l.days}')),
                      DataCell(SizedBox(width: 140, child: Text(l.reason, overflow: TextOverflow.ellipsis))),
                      DataCell(StatusBadge.forStatus(leaveStatusLabel(l.status))),
                      DataCell(
                        l.status == LeaveStatus.pending
                            ? Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(
                                  tooltip: 'Approve',
                                  icon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                                  onPressed: () => _act(l, LeaveStatus.approved),
                                ),
                                IconButton(
                                  tooltip: 'Reject',
                                  icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.danger),
                                  onPressed: () => _act(l, LeaveStatus.rejected),
                                ),
                              ])
                            : TextButton(
                                onPressed: () => _act(l, LeaveStatus.cancelled),
                                child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                              ),
                      ),
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

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatMini({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplyLeaveDialog extends StatefulWidget {
  final List<Employee> employees;
  const _ApplyLeaveDialog({required this.employees});

  @override
  State<_ApplyLeaveDialog> createState() => _ApplyLeaveDialogState();
}

class _ApplyLeaveDialogState extends State<_ApplyLeaveDialog> {
  Employee? _employee;
  String _type = leaveTypes.first;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 1));
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employees.isNotEmpty) {
      _employee = widget.employees.first;
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => isStart ? _start = picked : _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final days = _end.difference(_start).inDays + 1;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Apply Leave'),
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
                decoration: const InputDecoration(labelText: 'Leave Type'),
                items: leaveTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Date'),
                        child: Text(df.format(_start)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'End Date'),
                        child: Text(df.format(_end)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('$days day(s)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              const SizedBox(height: 8),
              TextField(
                controller: _reason,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_employee == null || _reason.text.trim().isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Please complete all fields')));
              return;
            }
            Navigator.pop(
              context,
              LeaveRequest(
                id: _uuid.v4(),
                employeeId: _employee!.id,
                employeeName: _employee!.name,
                leaveType: _type,
                startDate: _start,
                endDate: _end,
                days: days,
                reason: _reason.text.trim(),
              ),
            );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
