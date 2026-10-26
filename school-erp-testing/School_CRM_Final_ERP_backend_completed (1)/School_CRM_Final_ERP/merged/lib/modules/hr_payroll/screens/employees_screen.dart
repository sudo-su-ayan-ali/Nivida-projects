import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/hr_export_service.dart';
import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';
import 'employee_form.dart';

class EmployeesScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  final void Function(String, [Map<String, dynamic>]) onNavigate;
  const EmployeesScreen({super.key, required this.args, required this.onNavigate});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _search = '';
  String? _deptFilter;
  String? _desigFilter;
  String? _statusFilter;
  int _page = 0;
  static const _pageSize = 8;
  bool _sortAsc = true;
  bool _handledArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledArgs && widget.args['openAdd'] == true) {
      _handledArgs = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAdd());
    }
  }

  @override
  void didUpdateWidget(EmployeesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.args['openAdd'] == true && oldWidget.args != widget.args) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAdd());
    }
  }

  Future<void> _openAdd() async {
    final state = context.read<AppState>();
    final result = await showEmployeeFormDialog(
      context,
      departments: state.departments.map((d) => d.name).toList(),
      designations: state.designations.map((d) => d.name).toList(),
    );
    if (result != null) {
      state.addEmployee(result);
      if (mounted) showAppToast(context, 'Employee added successfully');
    }
  }

  Future<void> _openEdit(Employee e) async {
    final state = context.read<AppState>();
    final result = await showEmployeeFormDialog(
      context,
      existing: e,
      departments: state.departments.map((d) => d.name).toList(),
      designations: state.designations.map((d) => d.name).toList(),
    );
    if (result != null) {
      state.updateEmployee(result);
      if (mounted) showAppToast(context, 'Employee updated successfully');
    }
  }

  Future<void> _openImport() async {
    final state = context.read<AppState>();
    final controller = TextEditingController(
      text: 'Name,Department,Designation,Email,Phone,Salary\n'
          'Sunil Sharma,Teaching,Physics Teacher,sunil.sharma@brightfuture.edu.in,9876543210,48000\n'
          'Rekha Joshi,Accounts,Accountant,rekha.joshi@brightfuture.edu.in,9876543211,38000',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Employees from CSV'),
        content: SizedBox(
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste CSV data or edit below. Headers must be:\nName, Department, Designation, Email, Phone, Salary',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name,Department,Designation,Email,Phone,Salary',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Import Records'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      final lines = controller.text.trim().split('\n');
      int imported = 0;
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final parts = line.split(',').map((p) => p.trim()).toList();
        if (parts.length >= 3) {
          final name = parts[0];
          final dept = parts.length > 1 ? parts[1] : 'Teaching';
          final desig = parts.length > 2 ? parts[2] : 'Teacher';
          final email = parts.length > 3 ? parts[3] : '${name.toLowerCase().replaceAll(' ', '.')}@brightfuture.edu.in';
          final phone = parts.length > 4 ? parts[4] : '9800000000';
          final sal = parts.length > 5 ? (double.tryParse(parts[5]) ?? 40000.0) : 40000.0;
          await state.addEmployee(Employee(
            id: const Uuid().v4(),
            empCode: 'EMP${(1100 + state.employees.length + imported)}',
            name: name,
            gender: 'Male',
            dob: DateTime(1990, 1, 1),
            email: email,
            phone: phone,
            address: 'Jodhpur, Rajasthan',
            department: dept,
            designation: desig,
            joiningDate: DateTime.now(),
            employmentType: EmploymentType.fullTime,
            salary: sal,
            bankAccount: 'SBIN0001234',
            pan: 'ABCDE1234F',
            aadhaar: '123456789012',
            emergencyContact: '9800000001',
            status: EmployeeStatus.active,
            avatarColor: 'blue',
          ));
          imported++;
        }
      }
      if (mounted) {
        showAppToast(context, 'Successfully imported $imported employee(s)');
      }
    }
  }

  Future<void> _delete(Employee e) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Employee',
      message: 'Are you sure you want to delete ${e.name}? This cannot be undone.',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (confirmed) {
      context.read<AppState>().deleteEmployee(e.id);
      if (mounted) showAppToast(context, 'Employee deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    var list = state.employees.where((e) {
      final matchesSearch = _search.isEmpty ||
          e.name.toLowerCase().contains(_search.toLowerCase()) ||
          e.empCode.toLowerCase().contains(_search.toLowerCase()) ||
          e.email.toLowerCase().contains(_search.toLowerCase());
      final matchesDept = _deptFilter == null || e.department == _deptFilter;
      final matchesDesig = _desigFilter == null || e.designation == _desigFilter;
      final matchesStatus =
          _statusFilter == null || employeeStatusLabel(e.status) == _statusFilter;
      return matchesSearch && matchesDept && matchesDesig && matchesStatus;
    }).toList();

    list.sort((a, b) => _sortAsc ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

    final totalPages = (list.length / _pageSize).ceil().clamp(1, 999);
    if (_page >= totalPages) _page = 0;
    final pageItems = list.skip(_page * _pageSize).take(_pageSize).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Employees',
          subtitle: '${state.employees.length} total employees',
          actions: [
            SecondaryButton(
              label: 'Import',
              icon: Icons.upload_file_outlined,
              onPressed: _openImport,
            ),
            SecondaryButton(
              label: 'Export',
              icon: Icons.download_outlined,
              onPressed: () async {
                await HrExportService.exportEmployeesCsv(list);
                if (context.mounted) {
                  showAppToast(context, 'Exported ${list.length} employees to CSV');
                }
              },
            ),
            PrimaryButton(label: 'Add Employee', onPressed: _openAdd),
          ],
        ),
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
                  SearchField(
                      hint: 'Search by name, ID, or email',
                      onChanged: (v) => setState(() { _search = v; _page = 0; })),
                  FilterDropdown<String>(
                    hint: 'Department',
                    value: _deptFilter,
                    items: state.departments.map((d) => d.name).toList(),
                    labelBuilder: (v) => v,
                    onChanged: (v) => setState(() { _deptFilter = v; _page = 0; }),
                  ),
                  FilterDropdown<String>(
                    hint: 'Designation',
                    value: _desigFilter,
                    items: state.designations.map((d) => d.name).toList(),
                    labelBuilder: (v) => v,
                    onChanged: (v) => setState(() { _desigFilter = v; _page = 0; }),
                  ),
                  FilterDropdown<String>(
                    hint: 'Status',
                    value: _statusFilter,
                    items: const ['Active', 'Inactive', 'On Leave'],
                    labelBuilder: (v) => v,
                    onChanged: (v) => setState(() { _statusFilter = v; _page = 0; }),
                  ),
                  if (_deptFilter != null || _desigFilter != null || _statusFilter != null || _search.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _deptFilter = null;
                        _desigFilter = null;
                        _statusFilter = null;
                        _search = '';
                        _page = 0;
                      }),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear'),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: _sortAsc ? 'Sort Z-A' : 'Sort A-Z',
                    icon: Icon(_sortAsc ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined),
                    onPressed: () => setState(() => _sortAsc = !_sortAsc),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTable(
                emptyMessage: 'No employees match your filters',
                columns: const [
                  'Employee',
                  'Emp ID',
                  'Department',
                  'Designation',
                  'Joining Date',
                  'Salary',
                  'Status',
                  'Actions'
                ],
                rows: [
                  for (final e in pageItems)
                    DataRow(cells: [
                      DataCell(
                        Row(
                          children: [
                            InitialsAvatar(name: e.name, size: 30),
                            const SizedBox(width: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(e.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        onTap: () => widget.onNavigate(Routes.employeeDetail, {'id': e.id}),
                      ),
                      DataCell(Text(e.empCode)),
                      DataCell(Text(e.department)),
                      DataCell(Text(e.designation)),
                      DataCell(Text(DateFormat('dd MMM yyyy').format(e.joiningDate))),
                      DataCell(Text('₹${e.salary.toStringAsFixed(0)}')),
                      DataCell(StatusBadge.forStatus(employeeStatusLabel(e.status))),
                      DataCell(RowActions(
                        onView: () => widget.onNavigate(Routes.employeeDetail, {'id': e.id}),
                        onEdit: () => _openEdit(e),
                        onDelete: () => _delete(e),
                      )),
                    ]),
                ],
              ),
              TablePagination(
                page: _page,
                totalPages: totalPages,
                onPageChange: (p) => setState(() => _page = p),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- Employee detail (profile) screen ----------------

class EmployeeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  final void Function(String, [Map<String, dynamic>]) onNavigate;
  const EmployeeDetailScreen({super.key, required this.args, required this.onNavigate});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final id = widget.args['id'] as String?;
    final employee = state.employees.where((e) => e.id == id).firstOrNull;

    if (employee == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Employee Not Found'),
          const SizedBox(height: 20),
          const EmptyState(message: 'This employee record could not be found.'),
          TextButton(
              onPressed: () => widget.onNavigate(Routes.employees),
              child: const Text('Back to Employees')),
        ],
      );
    }

    final structure = state.structureFor(employee.id);
    final leaveCount = state.leaves.where((l) => l.employeeId == employee.id).length;
    final presentDays =
        state.attendance.where((a) => a.employeeId == employee.id && a.status == AttendanceStatus.present).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => widget.onNavigate(Routes.employees),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: PageHeader(
                title: employee.name,
                subtitle: '${employee.empCode} · ${employee.designation}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Row(
            children: [
              InitialsAvatar(name: employee.name, size: 64),
              const SizedBox(width: 18),
              Expanded(
                child: Wrap(
                  spacing: 26,
                  runSpacing: 10,
                  children: [
                    _InfoChip(icon: Icons.apartment_outlined, label: employee.department),
                    _InfoChip(icon: Icons.badge_outlined, label: employee.designation),
                    _InfoChip(
                        icon: Icons.event_outlined,
                        label: 'Joined ${DateFormat('dd MMM yyyy').format(employee.joiningDate)}'),
                    _InfoChip(icon: Icons.email_outlined, label: employee.email),
                    _InfoChip(icon: Icons.phone_outlined, label: employee.phone),
                  ],
                ),
              ),
              StatusBadge.forStatus(employeeStatusLabel(employee.status)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Personal Information'),
                  Tab(text: 'Employment'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Leave'),
                  Tab(text: 'Payroll'),
                ],
              ),
              const Divider(height: 1),
              SizedBox(
                height: 360,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(employee: employee, presentDays: presentDays, leaveCount: leaveCount, net: structure.net),
                    _PersonalTab(employee: employee),
                    _EmploymentTab(employee: employee),
                    _AttendanceTab(employee: employee, records: state.attendance.where((a) => a.employeeId == employee.id).toList()),
                    _LeaveTab(employee: employee, leaves: state.leaves.where((l) => l.employeeId == employee.id).toList()),
                    _PayrollTab(structure: structure),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Employee employee;
  final int presentDays;
  final int leaveCount;
  final double net;
  const _OverviewTab(
      {required this.employee, required this.presentDays, required this.leaveCount, required this.net});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 1,
        childAspectRatio: 2.6,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: [
          _MetricCard(label: 'Attendance (recent)', value: '$presentDays days present', color: AppColors.success),
          _MetricCard(label: 'Leave Requests', value: '$leaveCount total', color: AppColors.warning),
          _MetricCard(label: 'Net Monthly Salary', value: '₹${net.toStringAsFixed(0)}', color: AppColors.primary),
          _MetricCard(label: 'Employment Type', value: empTypeLabel(employee.employmentType), color: AppColors.purple),
          _MetricCard(label: 'Gender', value: employee.gender, color: AppColors.teal),
          _MetricCard(label: 'Status', value: employeeStatusLabel(employee.status), color: AppColors.danger),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PersonalTab extends StatelessWidget {
  final Employee employee;
  const _PersonalTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 40,
        runSpacing: 16,
        children: [
          _kv('Date of Birth', DateFormat('dd MMM yyyy').format(employee.dob)),
          _kv('Gender', employee.gender),
          _kv('Email', employee.email),
          _kv('Phone', employee.phone),
          _kv('Address', employee.address),
          _kv('Emergency Contact', employee.emergencyContact),
          _kv('PAN', employee.pan),
          _kv('Aadhaar', employee.aadhaar),
        ],
      ),
    );
  }
}

class _EmploymentTab extends StatelessWidget {
  final Employee employee;
  const _EmploymentTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 40,
        runSpacing: 16,
        children: [
          _kv('Employee ID', employee.empCode),
          _kv('Department', employee.department),
          _kv('Designation', employee.designation),
          _kv('Employment Type', empTypeLabel(employee.employmentType)),
          _kv('Joining Date', DateFormat('dd MMM yyyy').format(employee.joiningDate)),
          _kv('Bank Account', employee.bankAccount),
          _kv('Status', employeeStatusLabel(employee.status)),
        ],
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  final Employee employee;
  final List<AttendanceRecord> records;
  const _AttendanceTab({required this.employee, required this.records});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AppTable(
        columns: const ['Date', 'Check In', 'Check Out', 'Status'],
        emptyMessage: 'No attendance records',
        rows: [
          for (final r in records)
            DataRow(cells: [
              DataCell(Text(DateFormat('dd MMM yyyy').format(r.date))),
              DataCell(Text(r.checkIn)),
              DataCell(Text(r.checkOut)),
              DataCell(StatusBadge.forStatus(attendanceStatusLabel(r.status))),
            ]),
        ],
      ),
    );
  }
}

class _LeaveTab extends StatelessWidget {
  final Employee employee;
  final List<LeaveRequest> leaves;
  const _LeaveTab({required this.employee, required this.leaves});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AppTable(
        columns: const ['Leave Type', 'Start', 'End', 'Days', 'Status'],
        emptyMessage: 'No leave requests',
        rows: [
          for (final l in leaves)
            DataRow(cells: [
              DataCell(Text(l.leaveType)),
              DataCell(Text(DateFormat('dd MMM').format(l.startDate))),
              DataCell(Text(DateFormat('dd MMM').format(l.endDate))),
              DataCell(Text('${l.days}')),
              DataCell(StatusBadge.forStatus(leaveStatusLabel(l.status))),
            ]),
        ],
      ),
    );
  }
}

class _PayrollTab extends StatelessWidget {
  final SalaryStructure structure;
  const _PayrollTab({required this.structure});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 40,
        runSpacing: 16,
        children: [
          _kv('Basic', '₹${structure.basic.toStringAsFixed(0)}'),
          _kv('HRA', '₹${structure.hra.toStringAsFixed(0)}'),
          _kv('Conveyance', '₹${structure.conveyance.toStringAsFixed(0)}'),
          _kv('Medical', '₹${structure.medical.toStringAsFixed(0)}'),
          _kv('Special Allowance', '₹${structure.specialAllowance.toStringAsFixed(0)}'),
          _kv('PF', '₹${structure.pf.toStringAsFixed(0)}'),
          _kv('Professional Tax', '₹${structure.professionalTax.toStringAsFixed(0)}'),
          _kv('Net Salary', '₹${structure.net.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}

Widget _kv(String k, String v) {
  return SizedBox(
    width: 220,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        const SizedBox(height: 3),
        Text(v, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

String attendanceStatusLabel(AttendanceStatus s) {
  switch (s) {
    case AttendanceStatus.present:
      return 'Present';
    case AttendanceStatus.absent:
      return 'Absent';
    case AttendanceStatus.late:
      return 'Late';
    case AttendanceStatus.halfDay:
      return 'Half Day';
    case AttendanceStatus.onLeave:
      return 'On Leave';
  }
}

String leaveStatusLabel(LeaveStatus s) {
  switch (s) {
    case LeaveStatus.pending:
      return 'Pending';
    case LeaveStatus.approved:
      return 'Approved';
    case LeaveStatus.rejected:
      return 'Rejected';
    case LeaveStatus.cancelled:
      return 'Cancelled';
  }
}
