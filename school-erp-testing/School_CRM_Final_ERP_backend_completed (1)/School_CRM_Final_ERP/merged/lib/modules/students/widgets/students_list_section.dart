import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import 'dashboard_card.dart';
import 'status_badge.dart';

/// Full "Students Management" block: header actions, search, filters,
/// table with photo/admission/name/class/section/mobile/parent/status/actions,
/// and pagination — matches the top section of reference image 1.
class StudentsListSection extends StatefulWidget {
  final List<Student> students;
  final VoidCallback onAddStudent;
  final VoidCallback onImportExcel;
  final VoidCallback onExportPdf;
  final void Function(Student) onView;
  final void Function(Student) onEdit;
  final void Function(Student) onDelete;

  const StudentsListSection({
    super.key,
    required this.students,
    required this.onAddStudent,
    required this.onImportExcel,
    required this.onExportPdf,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<StudentsListSection> createState() => _StudentsListSectionState();
}

class _StudentsListSectionState extends State<StudentsListSection> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  int? _class;
  String? _section;
  String? _gender;
  StudentStatus? _status;
  String? _category;
  String? _bloodGroup;
  int _page = 1;
  static const _pageSize = 5;

  List<Student> get _filtered {
    return widget.students.where((s) {
      if (_search.isNotEmpty &&
          !s.name.toLowerCase().contains(_search.toLowerCase()) &&
          !s.admissionNo.toLowerCase().contains(_search.toLowerCase()) &&
          !s.mobile.contains(_search)) {
        return false;
      }
      if (_class != null && s.classNum != _class) return false;
      if (_section != null && s.section != _section) return false;
      if (_gender != null && s.gender != _gender) return false;
      if (_status != null && s.status != _status) return false;
      if (_category != null && s.category != _category) return false;
      if (_bloodGroup != null && s.bloodGroup != _bloodGroup) return false;
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _search = '';
      _class = null;
      _section = null;
      _gender = null;
      _status = null;
      _category = null;
      _bloodGroup = null;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 999999);
    final page = _page.clamp(1, totalPages);
    final start = (page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty ? <Student>[] : filtered.sublist(start, end);

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Students Management',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('Manage all student records efficiently.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              Wrap(
  spacing: 10,
  runSpacing: 10,
  children: [
    ElevatedButton.icon(
      onPressed: widget.onAddStudent,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Student'),
    ),
    OutlinedButton.icon(
      onPressed: widget.onExportPdf,
      icon: const Icon(Icons.description_outlined, size: 18),
      label: const Text('Export PDF'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Search by name, admission no., roll no...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
            onChanged: (v) => setState(() {
              _search = v;
              _page = 1;
            }),
          ),
          const SizedBox(height: 14),

          // Filters
          LayoutBuilder(builder: (context, constraints) {
            final narrow = constraints.maxWidth < 720;
            final filters = <Widget>[
            _dropdown<int>('Class', _class, [for (var c = 1; c <= 12; c++) c],
                  (v) => v == null ? 'All Classes' : 'Class $v', (v) => setState(() { _class = v; _page = 1; })),
              _dropdown<String>('Section', _section, ['A', 'B', 'C'],
                  (v) => v ?? 'All Sections', (v) => setState(() { _section = v; _page = 1; })),
              _dropdown<String>('Gender', _gender, ['Male', 'Female'],
                  (v) => v ?? 'All Genders', (v) => setState(() { _gender = v; _page = 1; })),
              _dropdown<StudentStatus>(
                  'Status',
                  _status,
                  StudentStatus.values,
                  (v) => v == null ? 'All Status' : (v == StudentStatus.active ? 'Active' : 'Inactive'),
                  (v) => setState(() { _status = v; _page = 1; })),
              _dropdown<String>('Category', _category, ['General', 'OBC', 'SC', 'ST'],
                  (v) => v ?? 'All Categories', (v) => setState(() { _category = v; _page = 1; })),
              _dropdown<String>('Blood Group', _bloodGroup, ['O+', 'A+', 'B+', 'AB+', 'Others'],
                  (v) => v ?? 'All Blood Groups', (v) => setState(() { _bloodGroup = v; _page = 1; })),
              SizedBox(
                height: 44,
                child: OutlinedButton(onPressed: _resetFilters, child: const Text('Reset')),
              ),
            ];
            return Wrap(spacing: 10, runSpacing: 10, children: [
              for (final f in filters) SizedBox(width: narrow ? constraints.maxWidth : 160, child: f),
            ]);
          }),
          const SizedBox(height: 20),
          const Text('Students List', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 10),

          // Table
                   // Table
          LayoutBuilder(builder: (context, tableConstraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: tableConstraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.background),
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Photo')),
                    DataColumn(label: Text('Admission No.')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Class')),
                    DataColumn(label: Text('Section')),
                    DataColumn(label: Text('Mobile No.')),
                    DataColumn(label: Text('Parent/Guardian')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
              rows: [
                for (final s in pageItems)
                  DataRow(cells: [
                    DataCell(CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.purpleBg,
                      child: Text(s.name.substring(0, 1), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    )),
                    DataCell(Text(s.admissionNo, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text(s.email, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    )),
                    DataCell(Text(s.classNum.toString())),
                    DataCell(Text(s.section)),
                    DataCell(Text(s.mobile)),
                    DataCell(Text(s.parentName)),
                    DataCell(StatusBadge(status: s.status)),
                    DataCell(Row(children: [
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.info),
                        onPressed: () => widget.onView(s),
                        tooltip: 'View',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.success),
                        onPressed: () => widget.onEdit(s),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                        onPressed: () => widget.onDelete(s),
                        tooltip: 'Delete',
                      ),
                    ])),
                                    ]),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),

          // Pagination
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              Text(
                filtered.isEmpty
                    ? 'No entries found'
                    : 'Showing ${start + 1} to $end of ${filtered.length} entries',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: page > 1 ? () => setState(() => _page = page - 1) : null,
                  ),
                  for (var p = 1; p <= totalPages && p <= 5; p++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => setState(() => _page = p),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p == page ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$p',
                              style: TextStyle(
                                  color: p == page ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  if (totalPages > 5) const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...')),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: page < totalPages ? () => setState(() => _page = page + 1) : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>(String hint, T? value, List<T> items, String Function(T?) label, void Function(T?) onChanged) {
    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        hint: Text(label(null), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        items: [
          for (final it in items) DropdownMenuItem<T>(value: it, child: Text(label(it), style: const TextStyle(fontSize: 13))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
