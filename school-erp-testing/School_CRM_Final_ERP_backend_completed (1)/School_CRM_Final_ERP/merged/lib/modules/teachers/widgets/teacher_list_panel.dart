import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/teacher.dart';
import '../theme/app_colors.dart';
import 'dashboard_cards.dart';
import 'teacher_form_dialog.dart';

/// The full "Teacher List" panel: search box, filter popover, a sortable
/// table, row actions (edit / view / delete), and working pagination.
///
/// This is a controlled component: all filter/sort/page state lives in
/// the parent ([TeachersDashboardScreen]) so that the header's global
/// search box and the "Department Wise Teachers" legend can drive the
/// exact same table.
class TeacherListPanel extends StatefulWidget {
  final List<Teacher> filtered;
  final String query;
  final String? deptFilter;
  final String? statusFilter;
  final TeacherSortKey sortKey;
  final bool sortAsc;
  final int page;
  final int pageSize;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String?> onDeptFilterChanged;
  final ValueChanged<String?> onStatusFilterChanged;
  final ValueChanged<TeacherSortKey> onSortToggle;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onClearFilters;
  final ValueChanged<Teacher> onUpdate;
  final ValueChanged<int> onDelete;

  const TeacherListPanel({
    super.key,
    required this.filtered,
    required this.query,
    required this.deptFilter,
    required this.statusFilter,
    required this.sortKey,
    required this.sortAsc,
    required this.page,
    required this.pageSize,
    required this.onQueryChanged,
    required this.onDeptFilterChanged,
    required this.onStatusFilterChanged,
    required this.onSortToggle,
    required this.onPageChanged,
    required this.onClearFilters,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<TeacherListPanel> createState() => _TeacherListPanelState();
}

class _TeacherListPanelState extends State<TeacherListPanel> {
  late final TextEditingController _searchCtrl;
  int? _openMenuForId;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant TeacherListPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_searchCtrl.text != widget.query) {
      _searchCtrl.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String? tempDept = widget.deptFilter;
        String? tempStatus = widget.statusFilter;
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Teachers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text('DEPARTMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(label: 'All', selected: tempDept == null, onTap: () => setSheet(() => tempDept = null)),
                    ...kDeptHeadcount.keys.map((d) => _FilterChip(
                          label: d,
                          selected: tempDept == d,
                          onTap: () => setSheet(() => tempDept = d),
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _FilterChip(label: 'All', selected: tempStatus == null, onTap: () => setSheet(() => tempStatus = null)),
                    _FilterChip(label: 'Active', selected: tempStatus == 'Active', onTap: () => setSheet(() => tempStatus = 'Active')),
                    _FilterChip(label: 'On Leave', selected: tempStatus == 'On Leave', onTap: () => setSheet(() => tempStatus = 'On Leave')),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onClearFilters();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        onPressed: () {
                          widget.onDeptFilterChanged(tempDept);
                          widget.onStatusFilterChanged(tempStatus);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.filtered;
    final totalPages = (filtered.length / widget.pageSize).ceil().clamp(1, 999999);
    final effectivePage = widget.page.clamp(1, totalPages);
    final start = (effectivePage - 1) * widget.pageSize;
    final pageItems = filtered.skip(start).take(widget.pageSize).toList();
    final hasActiveFilter = widget.deptFilter != null || widget.statusFilter != null;

    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Teacher List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
              SizedBox(
                width: 260,
                height: 40,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: widget.onQueryChanged,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or subject...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openFilterSheet,
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: Text(hasActiveFilter ? 'Filter •' : 'Filter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4B5563),
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              if (hasActiveFilter)
                TextButton(
                  onPressed: widget.onClearFilters,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                  child: const Text('Clear filters', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.danger)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 800),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                dataRowMinHeight: 62,
                dataRowMaxHeight: 68,
                columnSpacing: 26,
                horizontalMargin: 12,
                headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF), letterSpacing: 0.2),
                dividerThickness: 0.6,
                columns: [
                  DataColumn(label: const Text('TEACHER'), onSort: (_, __) => widget.onSortToggle(TeacherSortKey.name)),
                  DataColumn(label: const Text('EMP ID'), onSort: (_, __) => widget.onSortToggle(TeacherSortKey.empId)),
                  DataColumn(label: const Text('DEPARTMENT'), onSort: (_, __) => widget.onSortToggle(TeacherSortKey.department)),
                  const DataColumn(label: Text('SUBJECT')),
                  const DataColumn(label: Text('CONTACT')),
                  DataColumn(label: const Text('STATUS'), onSort: (_, __) => widget.onSortToggle(TeacherSortKey.status)),
                  const DataColumn(label: Text('ACTION')),
                ],
                rows: pageItems.isEmpty
                    ? [
                        const DataRow(cells: [
                          DataCell(Text('No teachers found', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                        ])
                      ]
                    : pageItems.map((t) => _buildRow(t)).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                filtered.isEmpty
                    ? 'No entries found'
                    : 'Showing ${start + 1} to ${(start + pageItems.length)} of ${filtered.length} entries',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              _Pagination(
                page: effectivePage,
                totalPages: totalPages,
                onChange: widget.onPageChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(Teacher t) {
    return DataRow(cells: [
      DataCell(SizedBox(
        width: 190,
        child: Row(
          children: [
            InitialsAvatar(seed: t.avatarSeed, radius: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text)),
                  Text(t.email, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      )),
      DataCell(Text(t.empId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF4B5563)))),
      DataCell(Text(t.department, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF4B5563)))),
      DataCell(Text(t.subject, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF4B5563)))),
      DataCell(Text(t.phone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.textSecondary))),
      DataCell(StatusBadge(status: t.status)),
      DataCell(_RowActions(
        open: _openMenuForId == t.id,
        onToggle: () => setState(() => _openMenuForId = _openMenuForId == t.id ? null : t.id),
        onEdit: () async {
          setState(() => _openMenuForId = null);
          final result = await showDialog<Teacher>(
            context: context,
            builder: (_) => TeacherFormDialog(existing: t),
          );
          if (result != null) widget.onUpdate(result);
        },
        onView: () {
          setState(() => _openMenuForId = null);
          showDialog(
            context: context,
            builder: (ctx) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InitialsAvatar(seed: t.avatarSeed, radius: 34),
                      const SizedBox(height: 14),
                      Text(t.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text('${t.subject} · ${t.department}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 14),
                      StatusBadge(status: t.status),
                      const SizedBox(height: 18),
                      _ProfileLine(icon: Icons.badge_outlined, text: t.empId),
                      const SizedBox(height: 8),
                      _ProfileLine(icon: Icons.email_outlined, text: t.email),
                      const SizedBox(height: 8),
                      _ProfileLine(icon: Icons.phone_outlined, text: t.phone),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        onDelete: () async {
          setState(() => _openMenuForId = null);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Remove teacher?'),
              content: Text('Remove ${t.name} from the teacher list?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Remove', style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
          );
          if (confirm == true) widget.onDelete(t.id);
        },
      )),
    ]);
  }
}

class _ProfileLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ProfileLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)))),
      ],
    );
  }
}

class _RowActions extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _RowActions({
    required this.open,
    required this.onToggle,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF9CA3AF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'view') onView();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
        const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_outlined, size: 16), SizedBox(width: 8), Text('View Profile')])),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: AppColors.danger)),
          ]),
        ),
      ],
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onChange;
  const _Pagination({required this.page, required this.totalPages, required this.onChange});

  List<dynamic> _pageList() {
    if (totalPages <= 6) return List.generate(totalPages, (i) => i + 1);
    if (page <= 3) return [1, 2, 3, '...', totalPages];
    if (page >= totalPages - 1) return [1, '...', totalPages - 2, totalPages - 1, totalPages];
    return [1, '...', page, '...', totalPages];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PgBtn(icon: Icons.chevron_left_rounded, onTap: page > 1 ? () => onChange(page - 1) : null),
        ..._pageList().map((p) {
          if (p == '...') {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('…', style: TextStyle(color: Color(0xFFD1D5DB), fontWeight: FontWeight.w800)),
            );
          }
          final active = p == page;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onChange(p as int),
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: active ? AppColors.brandGradient : null,
                  border: active ? null : Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$p',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: active ? Colors.white : const Color(0xFF6B7280))),
              ),
            ),
          );
        }),
        _PgBtn(icon: Icons.chevron_right_rounded, onTap: page < totalPages ? () => onChange(page + 1) : null),
      ],
    );
  }
}

class _PgBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PgBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: onTap == null ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF4B5563))),
      ),
    );
  }
}