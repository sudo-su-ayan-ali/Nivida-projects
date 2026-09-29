import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/attendance_record.dart';

class MarkAttendanceDialog extends StatefulWidget {
  final List<AttendanceRecord> students;
  final void Function(Map<String, AttendanceStatus> statuses, Map<String, String> remarks) onSave;

  const MarkAttendanceDialog({super.key, required this.students, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    required List<AttendanceRecord> students,
    required void Function(Map<String, AttendanceStatus>, Map<String, String>) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: MarkAttendanceDialog(students: students, onSave: onSave),
      ),
    );
  }

  @override
  State<MarkAttendanceDialog> createState() => _MarkAttendanceDialogState();
}

class _MarkAttendanceDialogState extends State<MarkAttendanceDialog> {
  late final Map<String, AttendanceStatus> _statuses = {
    for (final s in widget.students) s.id: s.status,
  };
  final Map<String, TextEditingController> _remarkControllers = {};
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    for (final s in widget.students) {
      _remarkControllers[s.id] = TextEditingController(text: s.remarks == '-' ? '' : s.remarks);
    }
  }

  @override
  void dispose() {
    for (final c in _remarkControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<AttendanceRecord> get _visibleStudents {
    if (_search.isEmpty) return widget.students;
    final q = _search.toLowerCase();
    return widget.students
        .where((s) => s.studentName.toLowerCase().contains(q) || s.rollNo.contains(q))
        .toList();
  }

  void _markAllVisiblePresent() {
    setState(() {
      for (final s in _visibleStudents) {
        _statuses[s.id] = AttendanceStatus.present;
      }
      _error = null;
    });
  }

  void _save() {
    if (_statuses.length != widget.students.length) {
      setState(() => _error = 'Please set a status for every student.');
      return;
    }
    widget.onSave(_statuses, {for (final e in _remarkControllers.entries) e.key: e.value.text});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleStudents;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Mark Attendance', style: AppText.pageTitle, textAlign: TextAlign.left),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: AppText.tableCell,
                      decoration: InputDecoration(
                        hintText: 'Search student by name or roll no...',
                        hintStyle: AppText.tableCellMuted,
                        prefixIcon: const Icon(Icons.search_rounded, size: 19, color: AppColors.textSecondary),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: visible.isEmpty ? null : _markAllVisiblePresent,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 17),
                    label: const Text('Mark all Present', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Flexible(
              child: visible.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No students match your search', style: AppText.cardLabel)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const Divider(height: 24, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final s = visible[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary.withOpacity(0.12),
                                  child: Text(s.studentName.substring(0, 1),
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text('${s.studentName}  ·  Roll ${s.rollNo}', style: AppText.tableCell),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: AttendanceStatus.values.map((status) {
                                final selected = _statuses[s.id] == status;
                                return ChoiceChip(
                                  label: Text(status.label),
                                  selected: selected,
                                  onSelected: (_) => setState(() {
                                    _statuses[s.id] = status;
                                    _error = null;
                                  }),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: selected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                  backgroundColor: AppColors.background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    side: const BorderSide(color: AppColors.border),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _remarkControllers[s.id],
                              style: AppText.tableCell,
                              decoration: InputDecoration(
                                hintText: 'Remarks (optional)',
                                hintStyle: AppText.tableCellMuted,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12.5)),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${widget.students.length} students · ${_statuses.length} marked',
                          style: AppText.cardLabel),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
                            ),
                            child: const Text('Cancel', style: AppText.button),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
                              elevation: 0,
                            ),
                            child: const Text('Save Attendance', style: AppText.button),
                          ),
                        ],
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
}
