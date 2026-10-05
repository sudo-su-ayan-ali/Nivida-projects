import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_data.dart';
import '../models/teacher.dart';
import '../theme/app_colors.dart';

/// Demo single-institution id used consistently across the app's
/// Supabase inserts (see students/inventory modules) until real
/// multi-tenant institution selection is wired up.
const String _kInstitutionId = 'd0000000-0000-0000-0000-000000000001';

/// Modal used for both "Add Teacher" and "Edit Teacher". Returns the
/// resulting [Teacher] via Navigator.pop when saved, or null on cancel.
class TeacherFormDialog extends StatefulWidget {
  final Teacher? existing;
  const TeacherFormDialog({super.key, this.existing});

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _subject;
  late String _dept;
  late String _status;

  bool get _editing => widget.existing != null;
  bool _saving = false;
  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _name = TextEditingController(text: t?.name ?? '');
    _email = TextEditingController(text: t?.email ?? '');
    _phone = TextEditingController(text: t?.phone ?? '');
    _subject = TextEditingController(text: t?.subject ?? '');
    _dept = t?.department ?? kDeptHeadcount.keys.first;
    _status = t?.status ?? 'Active';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _subject.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final base = widget.existing;
      Teacher result;
      if (base != null) {
        // Edit: persist the changed fields to Supabase, then hand back
        // the updated record so callers never touch stale data.
        final updated = base.copyWith(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          department: _dept,
          subject: _subject.text.trim(),
          status: _status,
        );
        await _client
            .from('teachers')
            .update(updated.toMap())
            .eq('id', updated.id);
        result = updated;
      } else {
        // Add: let the database assign the real id (and created_at);
        // avatar seed/birthday are cosmetic placeholders used elsewhere
        // in the dashboard's birthday-card widget.
        final now = DateTime.now();
        String instId = _kInstitutionId;
        try {
          final userId = _client.auth.currentUser?.id;
          if (userId != null) {
            final profile = await _client
                .from('profiles')
                .select('institution_id')
                .eq('id', userId)
                .maybeSingle();
            if (profile?['institution_id'] != null) {
              instId = profile!['institution_id'] as String;
            }
          }
        } catch (_) {}

        final row = <String, dynamic>{
          'emp_id': 'TCH${now.millisecondsSinceEpoch}',
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'department': _dept,
          'subject': _subject.text.trim(),
          'status': _status,
          'avatar_seed': _name.text.trim(),
          'birth_day': 1 + (now.millisecond % 28),
          'birth_month': 'JUN',
        };
        dynamic inserted;
        try {
          final rowWithTenant = Map<String, dynamic>.from(row)
            ..['institution_id'] = instId;
          inserted = await _client.from('teachers').insert(rowWithTenant).select().single();
        } on PostgrestException catch (e) {
          if (e.code == 'PGRST204' ||
              e.code == '42703' ||
              e.message.contains('institution_id') ||
              e.message.contains('instruction_id')) {
            inserted = await _client.from('teachers').insert(row).select().single();
          } else {
            rethrow;
          }
        }
        result = Teacher.fromMap(inserted as Map<String, dynamic>);
      }
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save teacher: $e')),
      );
    }
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_editing ? 'Edit Teacher' : 'Add New Teacher',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.text)),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20)),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: _dec('Full Name', 'e.g. Mr. Rahul Sharma'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _email,
                        decoration: _dec('Email', 'teacher@greenfield.edu.in'),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: _dec('Phone', '98XXXXXXXX'),
                        validator: (v) => (v == null || v.trim().length < 8) ? 'Enter a valid phone number' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _dept,
                        decoration: _dec('Department', ''),
                        items: kDeptHeadcount.keys
                            .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) => setState(() => _dept = v!),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _subject,
                        decoration: _dec('Subject', 'e.g. Physics'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: _dec('Status', ''),
                        items: const [
                          DropdownMenuItem(value: 'Active', child: Text('Active', style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: 'On Leave', child: Text('On Leave', style: TextStyle(fontSize: 13))),
                        ],
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : const Text('Save Teacher', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}