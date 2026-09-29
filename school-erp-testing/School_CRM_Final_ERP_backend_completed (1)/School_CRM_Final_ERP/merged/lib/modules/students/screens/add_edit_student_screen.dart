import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/student_repository.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

/// Multi-section Add/Edit Student form:
/// Personal · Academic · Parents/Guardians · Address · Transport · Hostel · Documents
class AddEditStudentScreen extends StatefulWidget {
  final Student? student; // null => Add mode
  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  late final _name = TextEditingController(text: widget.student?.name ?? '');
  late final _email = TextEditingController(text: widget.student?.email ?? '');
  late final _mobile = TextEditingController(text: widget.student?.mobile ?? '');
  late final _address = TextEditingController(text: widget.student?.address ?? '');
  late final _parentName = TextEditingController(text: widget.student?.parentName ?? '');
  late final _parentMobile = TextEditingController(text: widget.student?.parentMobile ?? '');
  late final _hostelName = TextEditingController(text: widget.student?.hostelName ?? '');
  late final _transportRoute = TextEditingController(text: widget.student?.transportRoute ?? '');

  int _classNum = 6;
  String _section = 'A';
  String _gender = 'Male';
  String _bloodGroup = 'O+';
  String _category = 'General';
  StudentStatus _status = StudentStatus.active;
  bool _usesTransport = false;
  bool _livesInHostel = false;
  bool _submitting = false;

  bool get _isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    if (s != null) {
      _classNum = s.classNum;
      _section = s.section;
      _gender = s.gender;
      _bloodGroup = s.bloodGroup;
      _category = s.category;
      _status = s.status;
      _usesTransport = s.usesTransport;
      _livesInHostel = s.livesInHostel;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _mobile, _address, _parentName, _parentMobile, _hostelName, _transportRoute]) {
      c.dispose();
    }
    super.dispose();
  }

  static const _steps = [
    'Personal',
    'Academic',
    'Parents/Guardians',
    'Address',
    'Transport',
    'Hostel',
    'Documents',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(_isEdit ? 'Edit Student' : 'Add Student'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTabs(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _stepContent(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (_step > 0)
                        OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
                      const Spacer(),
                      if (_step < _steps.length - 1)
                        ElevatedButton(onPressed: () => setState(() => _step++), child: const Text('Next'))
                      else
                        ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(_isEdit ? 'Save Changes' : 'Add Student'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == _step;
          return InkWell(
            onTap: () => setState(() => _step = i),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppColors.primary : AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(_steps[i],
                  style: TextStyle(
                      color: active ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return _grid([
          _text('Full Name', _name, required: true),
          _text('Email', _email),
          _text('Mobile No.', _mobile, required: true, keyboard: TextInputType.phone),
          _dropdown('Gender', _gender, const ['Male', 'Female'], (v) => setState(() => _gender = v!)),
          _dropdown('Blood Group', _bloodGroup, const ['O+', 'A+', 'B+', 'AB+', 'Others'], (v) => setState(() => _bloodGroup = v!)),
          _dropdown('Status', _status == StudentStatus.active ? 'Active' : 'Inactive', const ['Active', 'Inactive'],
              (v) => setState(() => _status = v == 'Active' ? StudentStatus.active : StudentStatus.inactive)),
        ]);
      case 1:
        return _grid([
          _dropdown('Class', 'Class $_classNum', [for (var c = 1; c <= 12; c++) 'Class $c'],
              (v) => setState(() => _classNum = int.parse(v!.split(' ').last))),
          _dropdown('Section', _section, const ['A', 'B', 'C'], (v) => setState(() => _section = v!)),
          _dropdown('Category', _category, const ['General', 'OBC', 'SC', 'ST'], (v) => setState(() => _category = v!)),
        ]);
      case 2:
        return _grid([
          _text('Parent/Guardian Name', _parentName, required: true),
          _text('Parent Mobile No.', _parentMobile, keyboard: TextInputType.phone),
        ]);
      case 3:
        return _grid([
          _text('Full Address', _address, maxLines: 3),
        ]);
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Uses School Transport'),
              value: _usesTransport,
              onChanged: (v) => setState(() => _usesTransport = v),
            ),
            if (_usesTransport) _text('Transport Route', _transportRoute),
          ],
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Lives in Hostel'),
              value: _livesInHostel,
              onChanged: (v) => setState(() => _livesInHostel = v),
            ),
            if (_livesInHostel) _text('Hostel Name', _hostelName),
          ],
        );
      case 6:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Documents', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final doc in ['Birth Certificate', 'Aadhar Card', 'Previous Marksheet', 'Photo'])
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Attach $doc (wire to file picker + storage API).'))),
                    icon: const Icon(Icons.upload_file_outlined, size: 16),
                    label: Text(doc),
                  ),
              ],
            ),
          ],
        );
    }
  }

  Widget _grid(List<Widget> fields) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 620 ? 2 : 1;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [for (final f in fields) SizedBox(width: cols == 2 ? (c.maxWidth - 16) / 2 : c.maxWidth, child: f)],
      );
    });
  }

  Widget _text(String label, TextEditingController ctrl, {bool required = false, int maxLines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: required ? '$label *' : label),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    );
  }

  Widget _dropdown(String label, String value, List<String> items, void Function(String?) onChanged) {
    // Agar current value list mein nahi hai (jaise DB mein koi purana/alag value
    // save ho gaya ho), to use bhi options mein add kar do — warna
    // DropdownButtonFormField crash ho jaata hai ("exactly one item with value").
    final options = items.contains(value) ? items : [value, ...items];
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [for (final i in options) DropdownMenuItem(value: i, child: Text(i))],
      onChanged: onChanged,
    );
  }

  void _submit() async {
  if (!_formKey.currentState!.validate()) {
    setState(() => _step = 0);
    return;
  }
  setState(() => _submitting = true);
  final repo = context.read<StudentRepository>();

  try {
    if (_isEdit) {
      final updated = widget.student!.copyWith(
        name: _name.text.trim(),
        email: _email.text.trim(),
        mobile: _mobile.text.trim(),
        classNum: _classNum,
        section: _section,
        gender: _gender,
        bloodGroup: _bloodGroup,
        category: _category,
        status: _status,
        address: _address.text.trim(),
        parentName: _parentName.text.trim(),
        parentMobile: _parentMobile.text.trim(),
        usesTransport: _usesTransport,
        transportRoute: _usesTransport ? _transportRoute.text.trim() : null,
        livesInHostel: _livesInHostel,
        hostelName: _livesInHostel ? _hostelName.text.trim() : null,
      );
      await repo.updateStudent(updated);   // <-- AWAIT ADD KIYA
    } else {
      final newStudent = Student(
        id: 'S${DateTime.now().microsecondsSinceEpoch}',
        admissionNo: 'ADM${DateTime.now().millisecondsSinceEpoch}', // <-- unique-safe banaya, neeche explain hai
        name: _name.text.trim(),
        email: _email.text.trim(),
        classNum: _classNum,
        section: _section,
        mobile: _mobile.text.trim(),
        parentName: _parentName.text.trim(),
        parentMobile: _parentMobile.text.trim(),
        status: _status,
        gender: _gender,
        bloodGroup: _bloodGroup,
        category: _category,
        dob: DateTime.now().subtract(Duration(days: 365 * (10 + (_classNum - 6)))),
        admissionDate: DateTime.now(),
        address: _address.text.trim(),
        usesTransport: _usesTransport,
        transportRoute: _usesTransport ? _transportRoute.text.trim() : null,
        livesInHostel: _livesInHostel,
        hostelName: _livesInHostel ? _hostelName.text.trim() : null,
        documentsVerified: false,
        idCardGenerated: false,
        attendancePercent: 100,
        examAveragePercent: 0,
        feeDue: 0,
        riskLevel: RiskLevel.none,
        riskReason: '',
        isBirthdayToday: false,
      );
      await repo.addStudent(newStudent);   // <-- AWAIT ADD KIYA
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Student updated successfully' : 'Student added successfully')),
    );
    Navigator.of(context).pop();
  } catch (e) {
    // ---- YE NAYA CATCH BLOCK HAI — ab error chhupega nahi ----
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: student save nahi hua — $e'),
        backgroundColor: Colors.red,
      ),
    );
    // Navigator.pop() yahan NAHI karenge — form open rahega taaki user dobara try kar sake
  }
}
}