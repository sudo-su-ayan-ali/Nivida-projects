import '../../data/hostel_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../models/student.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/confirm_dialog.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  final String? studentId;
  const AddStudentScreen({super.key, this.studentId});
  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final guardianName = TextEditingController();
  final guardianPhone = TextEditingController();
  final address = TextEditingController();
  final email = TextEditingController();
  late final TextEditingController roomCtrl;
  String gender = 'Male';
  String className = 'Class 9';
  String section = 'A';
  String block = 'Block A - Aravali';
  String bloodGroup = 'O+';
  DateTime? dateOfBirth;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    roomCtrl = TextEditingController(text: 'A-100');
  }

  void _loadExistingStudent() {
    if (widget.studentId == null || _initialized) return;
    final students = ref.read(studentsProvider).value;
    if (students == null) return;
    final s = students.where((st) => st.id == widget.studentId).firstOrNull;
    if (s != null) {
      _initialized = true;
      name.text = s.name;
      phone.text = s.phone;
      email.text = s.email;
      guardianName.text = s.guardianName;
      guardianPhone.text = s.guardianPhone;
      address.text = s.address;
      roomCtrl.text = s.room;
      if (s.gender.isNotEmpty && ['Male', 'Female', 'Other'].contains(s.gender)) {
        gender = s.gender;
      }
      if (s.bloodGroup.isNotEmpty && ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].contains(s.bloodGroup)) {
        bloodGroup = s.bloodGroup;
      }
      if (s.className.isNotEmpty && ['Class 9', 'Class 10', 'Class 11', 'Class 12'].contains(s.className)) {
        className = s.className;
      }
      if (s.section.isNotEmpty && ['A', 'B', 'C'].contains(s.section)) {
        section = s.section;
      }
      if (s.block.isNotEmpty) {
        final options = ['Block A - Aravali', 'Block B - Nilgiri', 'Block C - Vindhya', 'Block D - Satpura'];
        final matched = options.firstWhere(
          (b) => b.toLowerCase().contains(s.block.toLowerCase()) || s.block.toLowerCase().contains(b.toLowerCase()),
          orElse: () => block,
        );
        block = matched;
      }
      dateOfBirth = DateTime(DateTime.now().year - (s.age > 0 ? s.age : 16), 1, 1);
    }
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    guardianName.dispose();
    guardianPhone.dispose();
    address.dispose();
    email.dispose();
    roomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isEditing = widget.studentId != null;
    _loadExistingStudent();

    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBreadcrumb(items: ['Student Management', isEditing ? 'Edit Student' : 'Add Student']),
          const SizedBox(height: 10),
          Text(isEditing ? 'Edit Student' : 'Add New Student', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(isEditing ? 'Update student details and hostel room assignment.' : 'Fill in the details below to admit a new student to the hostel.', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionCard('Personal Information', Icons.person_rounded, [
                  _field('Full Name', name, isDesktop, required: true),
                  _dropdownField('Gender', gender, ['Male', 'Female', 'Other'], (v) => setState(() => gender = v!), isDesktop),
                  _field('Phone Number', phone, isDesktop, required: true, keyboardType: TextInputType.phone),
                  _field('Email Address', email, isDesktop, keyboardType: TextInputType.emailAddress),
                  _dobField(isDesktop),
                  _dropdownField('Blood Group', bloodGroup, ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'], (v) => setState(() => bloodGroup = v!), isDesktop),
                ], isDesktop),
                const SizedBox(height: AppSpacing.xl),
                _sectionCard('Academic Information', Icons.school_rounded, [
                  _dropdownField('Class', className, ['Class 9', 'Class 10', 'Class 11', 'Class 12'], (v) => setState(() => className = v!), isDesktop),
                  _dropdownField('Section', section, ['A', 'B', 'C'], (v) => setState(() => section = v!), isDesktop),
                ], isDesktop),
                const SizedBox(height: AppSpacing.xl),
                _sectionCard('Hostel Information', Icons.apartment_rounded, [
                  _dropdownField('Block', block, ['Block A - Aravali', 'Block B - Nilgiri', 'Block C - Vindhya', 'Block D - Satpura'], (v) => setState(() => block = v!), isDesktop),
                  _field('Room Number', roomCtrl, isDesktop),
                ], isDesktop),
                const SizedBox(height: AppSpacing.xl),
                _sectionCard('Emergency Contact', Icons.contact_emergency_rounded, [
                  _field('Guardian Name', guardianName, isDesktop, required: true),
                  _field('Guardian Phone', guardianPhone, isDesktop, required: true, keyboardType: TextInputType.phone),
                  _field('Home Address', address, isDesktop, maxLines: 2, fullWidth: true),
                ], isDesktop),
                const SizedBox(height: AppSpacing.xl),
                _sectionCard('Documents', Icons.folder_rounded, [
                  _uploadPlaceholder('Student Photo'),
                  _uploadPlaceholder('Aadhaar / ID Proof'),
                  _uploadPlaceholder('Previous School Certificate'),
                ], isDesktop),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SecondaryButton(label: 'Cancel', onPressed: () => context.go('/students')),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      label: isEditing ? 'Update Student' : 'Save Student',
                      icon: Icons.check_rounded,
                    onPressed: () async {
  if (!(_formKey.currentState?.validate() ?? false)) return;
  if (!isEditing && dateOfBirth == null) {
    showAppSnackBar(context, 'Please select the student\'s Date of Birth.');
    return;
  }

  try {
    final dobStr = dateOfBirth != null
        ? '${dateOfBirth!.year.toString().padLeft(4, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}'
        : null;

    if (isEditing) {
      await HostelService().updateHostelStudentFull(
        hostelStudentId: widget.studentId!,
        name: name.text.trim(),
        phone: phone.text.trim(),
        email: email.text.trim(),
        gender: gender,
        guardianName: guardianName.text.trim(),
        guardianPhone: guardianPhone.text.trim(),
        address: address.text.trim(),
        bloodGroup: bloodGroup,
        blockName: block,
        roomNumber: roomCtrl.text.trim(),
        className: className,
        sectionName: section,
        dateOfBirth: dobStr,
      );
      ref.invalidate(studentsProvider);
      if (context.mounted) {
        showAppSnackBar(context, 'Student ${name.text.trim()} updated successfully.');
        context.go('/students');
      }
    } else {
      await HostelService().addHostelStudentFull(
        name: name.text.trim(),
        phone: phone.text.trim(),
        email: email.text.trim(),
        gender: gender,
        guardianName: guardianName.text.trim(),
        guardianPhone: guardianPhone.text.trim(),
        address: address.text.trim(),
        bloodGroup: bloodGroup,
        blockName: block,
        roomNumber: roomCtrl.text.trim(),
        dateOfBirth: dobStr!,
      );
      ref.invalidate(studentsProvider);
      if (context.mounted) {
        showAppSnackBar(context, 'Student ${name.text.trim()} added successfully.');
        context.go('/students');
      }
    }
  } catch (e) {
    if (context.mounted) {
      showAppSnackBar(context, 'Failed to ${isEditing ? "update" : "add"} student: $e', isError: true);
    }
  }
},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> fields, bool isDesktop) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: fields,
          ),
        ],
      ),
    );
  }

  Widget _dobField(bool isDesktop) {
    final label = dateOfBirth == null
        ? 'Select date'
        : '${dateOfBirth!.day.toString().padLeft(2, '0')}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.year}';
    return SizedBox(
      width: isDesktop ? 260 : double.infinity,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2010, 1, 1),
            firstDate: DateTime(1995, 1, 1),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => dateOfBirth = picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
          ),
          child: Text(label, style: TextStyle(color: dateOfBirth == null ? AppColors.textSecondary : AppColors.textPrimary)),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, bool isDesktop,
      {bool required = false, TextInputType? keyboardType, int maxLines = 1, bool fullWidth = false, ValueChanged<String>? onChanged}) {
    final width = fullWidth || !isDesktop ? double.infinity : 320.0;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(text: TextSpan(text: label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), children: [
            if (required) const TextSpan(text: ' *', style: TextStyle(color: AppColors.danger)),
          ])),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null : null,
            decoration: InputDecoration(hintText: 'Enter $label'.toLowerCase()),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField(String label, String value, List<String> options, ValueChanged<String?> onChanged, bool isDesktop) {
    final width = isDesktop ? 320.0 : double.infinity;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _uploadPlaceholder(String label) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Row(children: [
              const Icon(Icons.upload_file_rounded, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Expanded(child: Text('Click to upload or drag file', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted))),
            ]),
          ),
        ],
      ),
    );
  }
}
