import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/attendance_record.dart';
import 'status_badge.dart';

enum _SortField { name, roll, cls, section, status }

/// Fixed pixel widths for each table column. A horizontally-scrollable Row
/// must use fixed widths (not Expanded/flex) for its cells, since Expanded
/// requires a bounded incoming width constraint — which a horizontal
/// SingleChildScrollView deliberately does not provide.
class _ColW {
  _ColW._();
  static const checkbox = 36.0;
  static const student = 230.0;
  static const rollNo = 80.0;
  static const studentClass = 110.0;
  static const section = 70.0;
  static const status = 250.0;
  static const checkIn = 110.0;
  static const checkOut = 110.0;
  static const remarks = 160.0;
  static const action = 160.0;
  static double get total =>
      checkbox + student + rollNo + studentClass + section + status + checkIn + checkOut + remarks + action;
}

class AttendanceTable extends StatefulWidget {
  final List<AttendanceRecord> records;
  final ValueChanged<AttendanceRecord> onView;
  final void Function(AttendanceRecord record, AttendanceStatus newStatus) onUpdateStatus;
  final void Function(AttendanceRecord record) onNotifyParent;
  final void Function(List<AttendanceRecord> records, AttendanceStatus newStatus) onBulkUpdateStatus;

  const AttendanceTable({
    super.key,
    required this.records,
    required this.onView,
    required this.onUpdateStatus,
    required this.onNotifyParent,
    required this.onBulkUpdateStatus,
  });

  @override
  State<AttendanceTable> createState() => _AttendanceTableState();
}

class _AttendanceTableState extends State<AttendanceTable> {
  String _query = '';
  String _classFilter = 'All Classes';
  String _sectionFilter = 'All Sections';
  AttendanceStatus? _statusFilter;
  _SortField _sortField = _SortField.roll;
  bool _sortAsc = true;

  /// Real class/section options derived from the currently-loaded records
  /// (which come from Supabase), so the filter list never drifts from
  /// what's actually in the database.
  List<String> get _classesInRecords {
    final set = {for (final r in widget.records) r.studentClass}..removeWhere((c) => c.isEmpty);
    final list = set.toList()..sort();
    return list;
  }

  List<String> get _sectionsInRecords {
    final set = {for (final r in widget.records) r.section}..removeWhere((s) => s.isEmpty);
    final list = set.toList()..sort();
    return list;
  }
  int _page = 1;
  static const _pageSize = 5;

  // Advanced filters, toggled from the "Filter" popover.
  bool _onlyWithRemarks = false;
  bool _onlyLateCheckIn = false; // check-in at/after 9:00 AM

  final Set<String> _selectedIds = {};

  List<AttendanceRecord> get _filtered {
    var list = widget.records.where((r) {
      final matchesQuery = _query.isEmpty ||
          r.studentName.toLowerCase().contains(_query.toLowerCase()) ||
          r.rollNo.contains(_query);
      final matchesClass = _classFilter == 'All Classes' || r.studentClass == _classFilter;
      final matchesSection = _sectionFilter == 'All Sections' || r.section == _sectionFilter;
      final matchesStatus = _statusFilter == null || r.status == _statusFilter;
      final matchesRemarks = !_onlyWithRemarks || (r.remarks.trim().isNotEmpty && r.remarks != '-');
      final matchesLate = !_onlyLateCheckIn || _isLateCheckIn(r.checkIn);
      return matchesQuery && matchesClass && matchesSection && matchesStatus && matchesRemarks && matchesLate;
    }).toList();

    int cmp(AttendanceRecord a, AttendanceRecord b) {
      switch (_sortField) {
        case _SortField.name:
          return a.studentName.compareTo(b.studentName);
        case _SortField.roll:
         return a.rollNo.compareTo(b.rollNo);
        case _SortField.cls:
          return a.studentClass.compareTo(b.studentClass);
        case _SortField.section:
          return a.section.compareTo(b.section);
        case _SortField.status:
          return a.status.index.compareTo(b.status.index);
      }
    }

    list.sort((a, b) => _sortAsc ? cmp(a, b) : cmp(b, a));
    return list;
  }

  bool _isLateCheckIn(String checkIn) {
    if (checkIn == '-') return false;
    final match = RegExp(r'(\d{2}):(\d{2}) (AM|PM)').firstMatch(checkIn);
    if (match == null) return false;
    var hour = int.parse(match.group(1)!);
    final period = match.group(3)!;
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return hour >= 9;
  }

  List<AttendanceRecord> get _pageItems {
    final f = _filtered;
    final start = (_page - 1) * _pageSize;
    if (start >= f.length) return [];
    final end = (start + _pageSize).clamp(0, f.length).toInt();
    return f.sublist(start, end);
  }

  int get _totalPages {
    final f = _filtered.length;
    return f == 0 ? 1 : ((f - 1) / _pageSize).floor() + 1;
  }

  void _resetPage() => setState(() => _page = 1);

  void _toggleSort(_SortField field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc = true;
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _query = '';
      _classFilter = 'All Classes';
      _sectionFilter = 'All Sections';
      _statusFilter = null;
      _onlyWithRemarks = false;
      _onlyLateCheckIn = false;
      _page = 1;
    });
  }

  Future<void> _openFilterMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy + box.size.height + 6, offset.dx, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        CheckedPopupMenuItem(
          value: 'remarks',
          checked: _onlyWithRemarks,
          child: const Text('Only students with remarks'),
        ),
        CheckedPopupMenuItem(
          value: 'lateCheckIn',
          checked: _onlyLateCheckIn,
          child: const Text('Only check-in at/after 9:00 AM'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'clear', child: Text('Clear all filters')),
      ],
    );
    if (result == 'remarks') {
      setState(() => _onlyWithRemarks = !_onlyWithRemarks);
      _resetPage();
    } else if (result == 'lateCheckIn') {
      setState(() => _onlyLateCheckIn = !_onlyLateCheckIn);
      _resetPage();
    } else if (result == 'clear') {
      _clearAllFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final pageItems = _pageItems;
    final selectedRecords = widget.records.where((r) => _selectedIds.contains(r.id)).toList();

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Recent Attendance Records', style: AppText.sectionTitle)),
              if (_activeFilterCount > 0)
                _ClearFiltersChip(count: _activeFilterCount, onTap: _clearAllFilters),
            ],
          ),
          const SizedBox(height: 16),
          _Toolbar(
            query: _query,
            classFilter: _classFilter,
            sectionFilter: _sectionFilter,
            statusFilter: _statusFilter,
            classOptions: _classesInRecords,
            sectionOptions: _sectionsInRecords,
            onQuery: (v) {
              setState(() => _query = v);
              _resetPage();
            },
            onClass: (v) {
              setState(() => _classFilter = v);
              _resetPage();
            },
            onSection: (v) {
              setState(() => _sectionFilter = v);
              _resetPage();
            },
            onStatus: (v) {
              setState(() => _statusFilter = v);
              _resetPage();
            },
            onFilterTap: () => _openFilterMenu(context),
          ),
          if (selectedRecords.isNotEmpty) ...[
            const SizedBox(height: 12),
            _BulkActionBar(
              count: selectedRecords.length,
              onMark: (status) {
                widget.onBulkUpdateStatus(selectedRecords, status);
                setState(() => _selectedIds.clear());
              },
              onNotify: () {
                for (final r in selectedRecords) {
                  widget.onNotifyParent(r);
                }
                setState(() => _selectedIds.clear());
              },
              onClear: () => setState(() => _selectedIds.clear()),
            ),
          ],
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const _EmptyState()
          else
            SizedBox(
              height: 500,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _TableBody(
                  records: filtered,
                  sortField: _sortField,
                  sortAsc: _sortAsc,
                  onSort: _toggleSort,
                  onView: widget.onView,
                  onUpdateStatus: widget.onUpdateStatus,
                  onNotifyParent: widget.onNotifyParent,
                  selectedIds: _selectedIds,
                  onToggleSelect: (id) => setState(() {
                    if (_selectedIds.contains(id)) {
                      _selectedIds.remove(id);
                    } else {
                      _selectedIds.add(id);
                    }
                  }),
                  allSelected: filtered.isNotEmpty && filtered.every((r) => _selectedIds.contains(r.id)),
                  onToggleSelectAll: (checked) => setState(() {
                    if (checked) {
                      _selectedIds.addAll(filtered.map((r) => r.id));
                    } else {
                      _selectedIds.removeAll(filtered.map((r) => r.id));
                    }
                  }),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text('Showing all ${filtered.length} entries', style: AppText.cardLabel),
        ],
      ),
    );
  }

  int get _activeFilterCount {
    var n = 0;
    if (_query.isNotEmpty) n++;
    if (_classFilter != 'All Classes') n++;
    if (_sectionFilter != 'All Sections') n++;
    if (_statusFilter != null) n++;
    if (_onlyWithRemarks) n++;
    if (_onlyLateCheckIn) n++;
    return n;
  }
}

class _ClearFiltersChip extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _ClearFiltersChip({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.infoBg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close_rounded, size: 13, color: AppColors.info),
            const SizedBox(width: 4),
            Text('$count filter${count > 1 ? 's' : ''} · clear',
                style: const TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  final int count;
  final ValueChanged<AttendanceStatus> onMark;
  final VoidCallback onNotify;
  final VoidCallback onClear;

  const _BulkActionBar({
    required this.count,
    required this.onMark,
    required this.onNotify,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          Text('$count selected', style: AppText.tableCell.copyWith(fontWeight: FontWeight.w700)),
          for (final s in AttendanceStatus.values)
            OutlinedButton(
              onPressed: () => onMark(s),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Mark ${s.label}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          TextButton.icon(
            onPressed: onNotify,
            icon: const Icon(Icons.notifications_outlined, size: 16),
            label: const Text('Notify Parents', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
          ),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary, padding: EdgeInsets.zero),
            child: const Text('Clear selection', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final String query;
  final String classFilter;
  final String sectionFilter;
  final AttendanceStatus? statusFilter;
  final List<String> classOptions;
  final List<String> sectionOptions;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onClass;
  final ValueChanged<String> onSection;
  final ValueChanged<AttendanceStatus?> onStatus;
  final VoidCallback onFilterTap;

  const _Toolbar({
    required this.query,
    required this.classFilter,
    required this.sectionFilter,
    required this.statusFilter,
    required this.classOptions,
    required this.sectionOptions,
    required this.onQuery,
    required this.onClass,
    required this.onSection,
    required this.onStatus,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final searchField = SizedBox(
        width: constraints.maxWidth < 700 ? double.infinity : 260,
        child: TextField(
          onChanged: onQuery,
          style: AppText.tableCell,
          decoration: InputDecoration(
            hintText: 'Search by name, roll no...',
            hintStyle: AppText.tableCellMuted,
            prefixIcon: const Icon(Icons.search_rounded, size: 19, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      );

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          searchField,
          _pillDropdown('All Classes', classFilter, ['All Classes', ...classOptions], onClass),
          _pillDropdown('All Sections', sectionFilter, ['All Sections', ...sectionOptions], onSection),
          _statusDropdown(),
          Builder(
            builder: (context) => OutlinedButton.icon(
              onPressed: onFilterTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
              ),
              icon: const Icon(Icons.filter_list_rounded, size: 18),
              label: const Text('Filter', style: AppText.button),
            ),
          ),
        ],
      );
    });
  }

  Widget _pillDropdown(String hint, String value, List<String> options, ValueChanged<String> onChanged) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: AppText.tableCell,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _statusDropdown() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AttendanceStatus?>(
          value: statusFilter,
          hint: const Text('All Status', style: AppText.tableCell),
          style: AppText.tableCell,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Status')),
            ...AttendanceStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
          ],
          onChanged: onStatus,
        ),
      ),
    );
  }
}

class _TableBody extends StatelessWidget {
  final List<AttendanceRecord> records;
  final _SortField sortField;
  final bool sortAsc;
  final void Function(_SortField) onSort;
  final ValueChanged<AttendanceRecord> onView;
  final void Function(AttendanceRecord, AttendanceStatus) onUpdateStatus;
  final void Function(AttendanceRecord) onNotifyParent;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleSelect;
  final bool allSelected;
  final ValueChanged<bool> onToggleSelectAll;

  const _TableBody({
    required this.records,
    required this.sortField,
    required this.sortAsc,
    required this.onSort,
    required this.onView,
    required this.onUpdateStatus,
    required this.onNotifyParent,
    required this.selectedIds,
    required this.onToggleSelect,
    required this.allSelected,
    required this.onToggleSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / _ColW.total;

        final table = Column(
          children: [
            _HeaderRow(
              scale: scale,
              sortField: sortField,
              sortAsc: sortAsc,
              onSort: onSort,
              allSelected: allSelected,
              onToggleSelectAll: onToggleSelectAll,
            ),
            const Divider(height: 1, color: AppColors.border),
            for (final r in records)
              _DataRow(
                scale: scale,
                record: r,
                onView: () => onView(r),
                onUpdateStatus: (s) => onUpdateStatus(r, s),
                onNotifyParent: () => onNotifyParent(r),
                selected: selectedIds.contains(r.id),
                onToggleSelect: () => onToggleSelect(r.id),
              ),
          ],
        );

        return table; // no horizontal scroll — table always shrinks/grows to fit width
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final _SortField sortField;
  final bool sortAsc;
  final double scale;
  final void Function(_SortField) onSort;
  final bool allSelected;
  final ValueChanged<bool> onToggleSelectAll;

  const _HeaderRow({
    required this.scale,
    required this.sortField,
    required this.sortAsc,
    required this.onSort,
    required this.allSelected,
    required this.onToggleSelectAll,
  });

 Widget _cell(String label, double width, {_SortField? field}) {
    final sortable = field != null;
    final active = sortable && field == sortField;
    return SizedBox(
      width: width * scale,
      child: InkWell(
        onTap: sortable ? () => onSort(field) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppText.tableHeader),
              if (sortable) ...[
                const SizedBox(width: 3),
                Icon(
                  active
                      ? (sortAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded)
                      : Icons.unfold_more_rounded,
                  size: 14,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
       SizedBox(
          width: _ColW.checkbox * scale,
          child: Checkbox(
            value: allSelected,
            onChanged: (v) => onToggleSelectAll(v ?? false),
            activeColor: AppColors.primary,
          ),
        ),
       _cell('Student', _ColW.student, field: _SortField.name),
        _cell('Roll No.', _ColW.rollNo, field: _SortField.roll),
        _cell('Class', _ColW.studentClass, field: _SortField.cls),
        _cell('Section', _ColW.section, field: _SortField.section),
        _cell('Check In', _ColW.checkIn),
        _cell('Check Out', _ColW.checkOut),
        _cell('Remarks', _ColW.remarks),
        _cell('Action', _ColW.action),
        _cell('Attendance Mark', _ColW.status, field: _SortField.status),
      ],
    );
  }
}

class _DataRow extends StatefulWidget {
  final double scale;
  final AttendanceRecord record;
  final VoidCallback onView;
  final ValueChanged<AttendanceStatus> onUpdateStatus;
  final VoidCallback onNotifyParent;
  final bool selected;
  final VoidCallback onToggleSelect;

  const _DataRow({
    required this.scale,
    required this.record,
    required this.onView,
    required this.onUpdateStatus,
    required this.onNotifyParent,
    required this.selected,
    required this.onToggleSelect,
  });

  @override
  State<_DataRow> createState() => _DataRowState();
}
class _DataRowState extends State<_DataRow> {
  bool _hovering = false;

@override
  Widget build(BuildContext context) {
    final r = widget.record;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        color: widget.selected
            ? AppColors.primary.withOpacity(0.05)
            : (_hovering ? AppColors.background : Colors.transparent),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _ColW.checkbox * widget.scale,
              child: Checkbox(
                value: widget.selected,
                onChanged: (_) => widget.onToggleSelect(),
                activeColor: AppColors.primary,
              ),
            ),
            SizedBox(
              width: _ColW.student * widget.scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Text(
                        r.studentName.isNotEmpty ? r.studentName.substring(0, 1) : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(r.studentName, style: AppText.tableCell, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: _ColW.rollNo * widget.scale, child: Text(r.rollNo, style: AppText.tableCellMuted)),
            SizedBox(width: _ColW.studentClass * widget.scale, child: Text(r.studentClass, style: AppText.tableCellMuted)),
            SizedBox(width: _ColW.section * widget.scale, child: Text(r.section, style: AppText.tableCellMuted)),
            SizedBox(width: _ColW.checkIn * widget.scale, child: Text(r.checkIn, style: AppText.tableCellMuted)),
            SizedBox(width: _ColW.checkOut * widget.scale, child: Text(r.checkOut, style: AppText.tableCellMuted)),
            SizedBox(
              width: _ColW.remarks * widget.scale,
              child: Text(r.remarks, style: AppText.tableCellMuted, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(
              width: _ColW.action * widget.scale,
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: widget.onView,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => _showRowMenu(context),
                      icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                      splashRadius: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: _ColW.status * widget.scale,
              child: _StatusRadioGroup(
                value: r.status,
                onChanged: widget.onUpdateStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRowMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx + box.size.width - 40, offset.dy, offset.dx, offset.dy),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: const [
        PopupMenuItem(value: 'edit', child: Text('Edit Status')),
        PopupMenuItem(value: 'history', child: Text('View History')),
        PopupMenuItem(value: 'notify', child: Text('Notify Parent')),
      ],
    );

    if (!context.mounted) return;

    switch (selected) {
      case 'edit':
        _showEditStatusSheet(context);
        break;
      case 'history':
        _showHistoryDialog(context);
        break;
      case 'notify':
        widget.onNotifyParent();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Parent notified for ${widget.record.studentName}'),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
    }
  }

  void _showEditStatusSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update status — ${widget.record.studentName}', style: AppText.sectionTitle),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AttendanceStatus.values.map((s) {
            final selected = widget.record.status == s;
            return ChoiceChip(
              label: Text(s.label),
              selected: selected,
              onSelected: (_) {
                widget.onUpdateStatus(s);
                Navigator.of(context).pop();
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                side: const BorderSide(color: AppColors.border),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    // Deterministic mock history derived from the student's id, so re-opening
    // the dialog for the same student always shows the same pattern.
    final seed = widget.record.id.hashCode;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final pattern = List.generate(5, (i) {
      final v = (seed + i * 13) % 10;
      if (v < 7) return AttendanceStatus.present;
      if (v < 8) return AttendanceStatus.late;
      if (v < 9) return AttendanceStatus.leave;
      return AttendanceStatus.absent;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Last 5 days — ${widget.record.studentName}', style: AppText.sectionTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < days.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 44, child: Text(days[i], style: AppText.cardLabel)),
                    const SizedBox(width: 8),
                    StatusBadge(status: pattern[i]),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
class _StatusRadioGroup extends StatelessWidget {
  final AttendanceStatus value;
  final ValueChanged<AttendanceStatus> onChanged;
  const _StatusRadioGroup({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AttendanceStatus.values.map((s) {
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: InkWell(
            onTap: () => onChanged(s),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Radio<AttendanceStatus>(
                    value: s,
                    groupValue: value,
                    onChanged: (v) {
                      if (v != null) onChanged(v);
                    },
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: const [
          Icon(Icons.search_off_rounded, size: 42, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('No records found', style: AppText.sectionTitle),
          SizedBox(height: 4),
          Text('Try adjusting your search or filters', style: AppText.cardLabel),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _Pagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final start = total == 0 ? 0 : (page - 1) * pageSize + 1;
    final end = ((page) * pageSize).clamp(0, total).toInt();

    List<Widget> pageButtons() {
      final widgets = <Widget>[];
      final pages = <int>{1, totalPages, page, page - 1, page + 1}
          .where((p) => p >= 1 && p <= totalPages)
          .toList()
        ..sort();

      int? prev;
      for (final p in pages) {
        if (prev != null && p - prev > 1) {
          widgets.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: AppText.tableCellMuted),
          ));
        }
        widgets.add(_PageButton(label: '$p', selected: p == page, onTap: () => onPageChanged(p)));
        prev = p;
      }
      return widgets;
    }

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Text('Showing $start to $end of $total entries', style: AppText.cardLabel),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavButton(icon: Icons.chevron_left_rounded, onTap: page > 1 ? () => onPageChanged(page - 1) : null),
            const SizedBox(width: 6),
            ...pageButtons(),
            const SizedBox(width: 6),
            _NavButton(
                icon: Icons.chevron_right_rounded,
                onTap: page < totalPages ? () => onPageChanged(page + 1) : null),
          ],
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PageButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: enabled ? AppColors.textPrimary : AppColors.border),
      ),
    );
  }
}