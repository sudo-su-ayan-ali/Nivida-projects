import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../theme.dart';

const _uuid = Uuid();

/// Shows the Add/Edit employee dialog. Returns the created/updated Employee,
/// or null if cancelled.
Future<Employee?> showEmployeeFormDialog(
  BuildContext context, {
  Employee? existing,
  required List<String> departments,
  required List<String> designations,
}) {
  return showDialog<Employee>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _EmployeeFormDialog(
      existing: existing,
      departments: departments,
      designations: designations,
    ),
  );
}

class _EmployeeFormDialog extends StatefulWidget {
  final Employee? existing;
  final List<String> departments;
  final List<String> designations;
  const _EmployeeFormDialog(
      {this.existing, required this.departments, required this.designations});

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _address;
  late TextEditingController _salary;
  late TextEditingController _bank;
  late TextEditingController _pan;
  late TextEditingController _aadhaar;
  late TextEditingController _emergency;

  String _gender = 'Male';
  DateTime _dob = DateTime(1995, 1, 1);
  DateTime _joiningDate = DateTime.now();
  String? _department;
  String? _designation;
  EmploymentType _employmentType = EmploymentType.fullTime;
  EmployeeStatus _status = EmployeeStatus.active;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _address = TextEditingController(text: e?.address ?? 'Jodhpur, Rajasthan');
    _salary = TextEditingController(text: e != null ? e.salary.toStringAsFixed(0) : '');
    _bank = TextEditingController(text: e?.bankAccount ?? '');
    _pan = TextEditingController(text: e?.pan ?? '');
    _aadhaar = TextEditingController(text: e?.aadhaar ?? '');
    _emergency = TextEditingController(text: e?.emergencyContact ?? '');
    if (e != null) {
      _gender = e.gender;
      _dob = e.dob;
      _joiningDate = e.joiningDate;
      _department = e.department;
      _designation = e.designation;
      _employmentType = e.employmentType;
      _status = e.status;
    } else {
      _department = widget.departments.isNotEmpty ? widget.departments.first : null;
      _designation = widget.designations.isNotEmpty ? widget.designations.first : null;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _address, _salary, _bank, _pan, _aadhaar, _emergency]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDob ? _dob : _joiningDate,
      firstDate: DateTime(1960),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isDob ? _dob = picked : _joiningDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_department == null || _designation == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select department and designation')));
      return;
    }
    final result = Employee(
      id: widget.existing?.id ?? _uuid.v4(),
      empCode: widget.existing?.empCode ?? 'EMP${1000 + DateTime.now().millisecondsSinceEpoch % 900}',
      name: _name.text.trim(),
      gender: _gender,
      dob: _dob,
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      department: _department!,
      designation: _designation!,
      joiningDate: _joiningDate,
      employmentType: _employmentType,
      salary: double.tryParse(_salary.text.trim()) ?? 0,
      bankAccount: _bank.text.trim(),
      pan: _pan.text.trim(),
      aadhaar: _aadhaar.text.trim(),
      emergencyContact: _emergency.text.trim(),
      status: _status,
      avatarColor: widget.existing?.avatarColor ?? 'blue',
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final isEdit = widget.existing != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit Employee' : 'Add Employee',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _row([
                          _field(_name, 'Full Name', validator: _req),
                          _dropdown('Gender', _gender, ['Male', 'Female', 'Other'],
                              (v) => setState(() => _gender = v!)),
                        ]),
                        _row([
                          _dateField('Date of Birth', df.format(_dob), () => _pickDate(true)),
                          _dateField(
                              'Joining Date', df.format(_joiningDate), () => _pickDate(false)),
                        ]),
                        _row([
                          _field(_email, 'Email', validator: _req, keyboard: TextInputType.emailAddress),
                          _field(_phone, 'Phone', validator: _req, keyboard: TextInputType.phone),
                        ]),
                        _field(_address, 'Address', validator: _req),
                        const SizedBox(height: 12),
                        _row([
                          _dropdown('Department', _department, widget.departments,
                              (v) => setState(() => _department = v)),
                          _dropdown('Designation', _designation, widget.designations,
                              (v) => setState(() => _designation = v)),
                        ]),
                        _row([
                          _dropdown(
                              'Employment Type',
                              _employmentType,
                              EmploymentType.values,
                              (v) => setState(() => _employmentType = v!),
                              labelBuilder: (t) => empTypeLabel(t)),
                          _field(_salary, 'Monthly Salary (₹)',
                              validator: _req, keyboard: TextInputType.number),
                        ]),
                        _row([
                          _field(_bank, 'Bank Account', validator: _req),
                          _field(_pan, 'PAN Number', validator: _req),
                        ]),
                        _row([
                          _field(_aadhaar, 'Aadhaar (masked)', validator: _req),
                          _field(_emergency, 'Emergency Contact',
                              validator: _req, keyboard: TextInputType.phone),
                        ]),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _dropdown(
                              'Status',
                              _status,
                              EmployeeStatus.values,
                              (v) => setState(() => _status = v!),
                              labelBuilder: (s) => employeeStatusLabel(s),
                              width: 220),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                        onPressed: _submit, child: Text(isEdit ? 'Save Changes' : 'Add Employee')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _row(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: LayoutBuilder(builder: (ctx, c) {
        if (c.maxWidth < 420) {
          return Column(children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList());
        }
        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      }),
    );
  }

  Widget _field(TextEditingController c, String label,
      {String? Function(String?)? validator, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        validator: validator,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dateField(String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value),
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>(String label, T? value, List<T> items, ValueChanged<T?> onChanged,
      {String Function(T)? labelBuilder, double? width}) {
    final content = DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(labelBuilder != null ? labelBuilder(e) : e.toString())))
          .toList(),
      onChanged: onChanged,
    );
    final field = Padding(padding: const EdgeInsets.only(bottom: 14), child: content);
    return width != null ? SizedBox(width: width, child: field) : field;
  }
}

String empTypeLabel(EmploymentType t) {
  switch (t) {
    case EmploymentType.fullTime:
      return 'Full Time';
    case EmploymentType.partTime:
      return 'Part Time';
    case EmploymentType.contract:
      return 'Contract';
    case EmploymentType.intern:
      return 'Intern';
  }
}

String employeeStatusLabel(EmployeeStatus s) {
  switch (s) {
    case EmployeeStatus.active:
      return 'Active';
    case EmployeeStatus.inactive:
      return 'Inactive';
    case EmployeeStatus.onLeave:
      return 'On Leave';
  }
}
