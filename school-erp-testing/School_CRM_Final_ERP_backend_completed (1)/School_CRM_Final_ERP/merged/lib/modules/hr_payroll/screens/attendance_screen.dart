import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';
import 'employees_screen.dart' show attendanceStatusLabel;

const _uuid = Uuid();

class AttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const AttendanceScreen({super.key, required this.args});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _deptFilter;
  String? _statusFilter;
  String _search = '';
  bool _handledArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledArgs && widget.args['openMark'] == true) {
      _handledArgs = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _openMarkAttendance());
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _openMarkAttendance() async {
    final state = context.read<AppState>();
    final result = await showDialog<AttendanceRecord>(
      context: context,
      builder: (_) => _MarkAttendanceDialog(employees: state.employees, date: _selectedDate),
    );
    if (result != null) {
      state.markAttendance(result);
      if (mounted) showAppToast(context, 'Attendance marked for ${result.employeeName}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final df = DateFormat('dd MMM yyyy');

    var records = state.attendance.where((a) =>
        a.date.year == _selectedDate.year &&
        a.date.month == _selectedDate.month &&
        a.date.day == _selectedDate.day).toList();

    records = records.where((a) {
      final matchesDept = _deptFilter == null || a.department == _deptFilter;
      final matchesStatus = _statusFilter == null || attendanceStatusLabel(a.status) == _statusFilter;
      final matchesSearch = _search.isEmpty || a.employeeName.toLowerCase().contains(_search.toLowerCase());
      return matchesDept && matchesStatus && matchesSearch;
    }).toList();

    final present = records.where((a) => a.status == AttendanceStatus.present).length;
    final absent = records.where((a) => a.status == AttendanceStatus.absent).length;
    final lateCount = records.where((a) => a.status == AttendanceStatus.late).length;
    final onLeave = records.where((a) => a.status == AttendanceStatus.onLeave).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Attendance Management',
          subtitle: 'Track daily attendance and punctuality',
          actions: [PrimaryButton(label: 'Mark Attendance', icon: Icons.edit_calendar_outlined, onPressed: _openMarkAttendance)],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 900 ? 4 : (c.maxWidth > 500 ? 2 : 1);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 2.6,
            children: [
              _StatMini(label: 'Present', value: '$present', color: AppColors.success, icon: Icons.check_circle_outline),
              _StatMini(label: 'Absent', value: '$absent', color: AppColors.danger, icon: Icons.cancel_outlined),
              _StatMini(label: 'Late', value: '$lateCount', color: AppColors.warning, icon: Icons.access_time),
              _StatMini(label: 'On Leave', value: '$onLeave', color: AppColors.purple, icon: Icons.beach_access_outlined),
            ],
          );
        }),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 16),
                        const SizedBox(width: 8),
                        Text(df.format(_selectedDate)),
                      ]),
                    ),
                  ),
                  SearchField(hint: 'Search employee', onChanged: (v) => setState(() => _search = v)),
                  FilterDropdown<String>(
                    hint: 'Department',
                    value: _deptFilter,
                    items: state.departments.map((d) => d.name).toList(),
                    labelBuilder: (v) => v,
                    onChanged: (v) => setState(() => _deptFilter = v),
                  ),
                  FilterDropdown<String>(
                    hint: 'Status',
                    value: _statusFilter,
                    items: const ['Present', 'Absent', 'Late', 'Half Day', 'On Leave'],
                    labelBuilder: (v) => v,
                    onChanged: (v) => setState(() => _statusFilter = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTable(
                columns: const ['Employee', 'Department', 'Check In', 'Check Out', 'Status', 'Actions'],
                emptyMessage: 'No attendance records for this date',
                rows: [
                  for (final a in records)
                    DataRow(cells: [
                      DataCell(Text(a.employeeName, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(a.department)),
                      DataCell(Text(a.checkIn)),
                      DataCell(Text(a.checkOut)),
                      DataCell(StatusBadge.forStatus(attendanceStatusLabel(a.status))),
                      DataCell(PopupMenuButton<AttendanceStatus>(
                        tooltip: 'Change status',
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (s) {
                          state.updateAttendanceStatus(a.id, s);
                          showAppToast(context, 'Status updated to ${attendanceStatusLabel(s)}');
                        },
                        itemBuilder: (ctx) => AttendanceStatus.values
                            .map((s) => PopupMenuItem(value: s, child: Text(attendanceStatusLabel(s))))
                            .toList(),
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

class _MarkAttendanceDialog extends StatefulWidget {
  final List<Employee> employees;
  final DateTime date;
  const _MarkAttendanceDialog({required this.employees, required this.date});

  @override
  State<_MarkAttendanceDialog> createState() => _MarkAttendanceDialogState();
}

class _MarkAttendanceDialogState extends State<_MarkAttendanceDialog> {
  Employee? _employee;
  AttendanceStatus _status = AttendanceStatus.present;
  final _checkIn = TextEditingController(text: '09:00');
  final _checkOut = TextEditingController(text: '05:00');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Mark Attendance'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Employee>(
              value: _employee,
              decoration: const InputDecoration(labelText: 'Employee'),
              items: widget.employees
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (v) => setState(() => _employee = v),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<AttendanceStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: AttendanceStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(attendanceStatusLabel(s))))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checkIn,
                    decoration: const InputDecoration(labelText: 'Check In'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _checkOut,
                    decoration: const InputDecoration(labelText: 'Check Out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_employee == null) return;
            Navigator.pop(
              context,
              AttendanceRecord(
                id: _uuid.v4(),
                employeeId: _employee!.id,
                employeeName: _employee!.name,
                department: _employee!.department,
                date: widget.date,
                checkIn: _status == AttendanceStatus.absent ? '--' : _checkIn.text,
                checkOut: _status == AttendanceStatus.absent ? '--' : _checkOut.text,
                status: _status,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
