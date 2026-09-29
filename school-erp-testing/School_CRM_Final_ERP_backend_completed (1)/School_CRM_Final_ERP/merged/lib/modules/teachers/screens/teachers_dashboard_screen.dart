import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/birthday_card.dart';
import '../widgets/dashboard_cards.dart';
import '../widgets/department_chart_card.dart';
import '../widgets/quick_action_dialogs.dart';
import '../widgets/teacher_form_dialog.dart';
import '../widgets/teacher_list_panel.dart';
import '../widgets/top_header.dart';

/// Root screen: sidebar + header shell wrapping the scrollable dashboard
/// body (summary cards, quick actions, teacher list, charts, bottom stats).
///
/// This screen owns all shared state: the teacher roster, the Teacher
/// List's search/filter/sort/page state (so the header search box and
/// the department legend can both drive the same table), and the
/// light/dark chrome toggle.
class TeachersDashboardScreen extends StatefulWidget {
  const TeachersDashboardScreen({super.key});

  @override
  State<TeachersDashboardScreen> createState() =>
      _TeachersDashboardScreenState();
}

class _TeachersDashboardScreenState extends State<TeachersDashboardScreen> {
  final _teacherListKey = GlobalKey();

  late List<Teacher> _teachers;

  // Teacher List controlled state — shared by the header search box,
  // the department legend, and the panel itself.
  String _query = '';
  String? _deptFilter;
  String? _statusFilter;
  TeacherSortKey _sortKey = TeacherSortKey.none;
  bool _sortAsc = true;
  int _page = 1;
  static const int _pageSize = 5;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _teachers = [];
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final client = Supabase.instance.client;
    String? institutionId;
    try {
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        final profile = await client
            .from('profiles')
            .select('institution_id')
            .eq('id', userId)
            .maybeSingle();
        institutionId = profile?['institution_id'] as String?;
      }
    } catch (_) {}

    var query = client.from('teachers').select();
    if (institutionId != null) {
      query = query.eq('institution_id', institutionId);
    }
    final data = await query.order('created_at');
    setState(() {
      _teachers = (data as List)
          .map((row) => Teacher.fromMap(row as Map<String, dynamic>))
          .toList();
      _isLoading = false;
    });
  }

  List<StatTile> get _summaryTiles {
    final active = _teachers.where((t) => t.status == 'Active').length;
    final onLeave = _teachers.where((t) => t.status == 'On Leave').length;
    final depts = _teachers.map((t) => t.department).toSet().length;
    return [
      StatTile(
        icon: Icons.people_alt_rounded,
        value: '${_teachers.length}',
        label: 'Total Teachers',
        accent: AppColors.primary,
        bg: const Color(0xFFEEF0FF),
      ),
      StatTile(
        icon: Icons.grid_view_rounded,
        value: '$depts',
        label: 'Departments',
        accent: AppColors.success,
        bg: const Color(0xFFDFF7EC),
      ),
      StatTile(
        icon: Icons.event_available_rounded,
        value: '$active',
        label: 'Present Today',
        accent: AppColors.blue,
        bg: const Color(0xFFE4EEFF),
      ),
      StatTile(
        icon: Icons.schedule_rounded,
        value: '$onLeave',
        label: 'On Leave',
        accent: AppColors.warning,
        bg: const Color(0xFFFFF1DE),
      ),
      StatTile(
        icon: Icons.person_add_alt_1_rounded,
        value: '2',
        label: 'New This Month',
        accent: AppColors.secondary,
        bg: const Color(0xFFF1E8FF),
      ),
    ];
  }

  List<Teacher> get _filteredTeachers {
    var list = _teachers.where((t) {
      final q = _query.trim().toLowerCase();
      final matchesQ =
          q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.email.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q) ||
          t.empId.toLowerCase().contains(q);
      final matchesDept = _deptFilter == null || t.department == _deptFilter;
      final matchesStatus = _statusFilter == null || t.status == _statusFilter;
      return matchesQ && matchesDept && matchesStatus;
    }).toList();

    if (_sortKey != TeacherSortKey.none) {
      list.sort((a, b) {
        int cmp;
        switch (_sortKey) {
          case TeacherSortKey.name:
            cmp = a.name.compareTo(b.name);
            break;
          case TeacherSortKey.empId:
            cmp = a.empId.compareTo(b.empId);
            break;
          case TeacherSortKey.department:
            cmp = a.department.compareTo(b.department);
            break;
          case TeacherSortKey.status:
            cmp = a.status.compareTo(b.status);
            break;
          case TeacherSortKey.none:
            cmp = 0;
        }
        return _sortAsc ? cmp : -cmp;
      });
    }
    return list;
  }

  // Note: TeacherFormDialog already persists the add/update to Supabase
  // before it pops with the saved record, so these two only need to keep
  // local state in sync with what's already in the database.
  void _addTeacher(Teacher t) => setState(() => _teachers.insert(0, t));
  void _updateTeacher(Teacher t) => setState(() {
    final i = _teachers.indexWhere((x) => x.id == t.id);
    if (i != -1) _teachers[i] = t;
  });

  Future<void> _deleteTeacher(int id) async {
    final previous = List<Teacher>.of(_teachers);
    setState(() => _teachers.removeWhere((t) => t.id == id));
    try {
      await Supabase.instance.client.from('teachers').delete().eq('id', id);
    } catch (e) {
      if (!mounted) return;
      // Roll back the optimistic removal if the delete failed server-side.
      setState(() => _teachers = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete teacher: $e')),
      );
    }
  }

  void _setQuery(String q) => setState(() {
    _query = q;
    _page = 1;
  });

  void _setDeptFilter(String? d) => setState(() {
    _deptFilter = d;
    _page = 1;
  });

  void _setStatusFilter(String? s) => setState(() {
    _statusFilter = s;
    _page = 1;
  });

  void _clearFilters() => setState(() {
    _deptFilter = null;
    _statusFilter = null;
    _page = 1;
  });

  void _toggleSort(TeacherSortKey key) => setState(() {
    if (_sortKey == key) {
      _sortAsc = !_sortAsc;
    } else {
      _sortKey = key;
      _sortAsc = true;
    }
  });

  void _scrollToTeacherList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _teacherListKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onHeaderSearch(String q) {
    _setQuery(q);
    if (q.trim().isNotEmpty) _scrollToTeacherList();
  }

  void _onDeptTap(String dept) {
    setState(() {
      _deptFilter = _deptFilter == dept ? null : dept;
      _page = 1;
    });
    if (_deptFilter != null) _scrollToTeacherList();
  }

  // NOTE: This module's own sidebar (widgets/app_sidebar.dart) has been
  // removed as part of the EduSmart merge — the outer school shell's
  // Sidebar (lib/widgets/sidebar.dart) already provides Teachers/Students/
  // Parents/Attendance navigation, so keeping a second one here would just
  // duplicate it. This screen now renders as a plain content pane: sticky
  // header + scrollable dashboard body.
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 980;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          TopHeader(
            onMenuTap: () {},
            searchValue: _query,
            onSearchChanged: _onHeaderSearch,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(),
                  const SizedBox(height: 24),
                  _buildSummaryRow(),
                  const SizedBox(height: 28),
                  const SectionHeader(
                    title: 'Teaching Tools & Important Links',
                  ),
                  const SizedBox(height: 14),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 28),
                  _buildMainGrid(isNarrow: isNarrow),
                  const SizedBox(height: 28),
                  const SectionHeader(
                    title: 'Additional Important Information',
                  ),
                  const SizedBox(height: 14),
                  _buildBottomStatsGrid(),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '© 2025 EduSmart School ERP · Greenfield Public School',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Teachers Dashboard',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage and view all teacher related information',
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await showDialog<Teacher>(
              context: context,
              builder: (_) => const TeacherFormDialog(),
            );
            if (result != null) _addTeacher(result);
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(
            'Add Teacher',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return AutoGrid(
      spacing: 16,
      runSpacing: 16,
      columnsForWidth: (w) => w > 1100 ? 5 : (w > 700 ? 3 : 2),
      children: _summaryTiles.map((t) => SummaryStatCard(tile: t)).toList(),
    );
  }

  Widget _buildQuickActionsGrid() {
    return AutoGrid(
      spacing: 14,
      runSpacing: 14,
      columnsForWidth: (w) => w > 1300
          ? 8
          : w > 980
          ? 4
          : w > 600
          ? 3
          : 2,
      children: kQuickActions
          .map(
            (a) => QuickActionCard(
              action: a,
              onTap: () => showQuickActionDialog(context, a),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMainGrid({required bool isNarrow}) {
    final leftPanel = KeyedSubtree(
      key: _teacherListKey,
      child: TeacherListPanel(
        filtered: _filteredTeachers,
        query: _query,
        deptFilter: _deptFilter,
        statusFilter: _statusFilter,
        sortKey: _sortKey,
        sortAsc: _sortAsc,
        page: _page,
        pageSize: _pageSize,
        onQueryChanged: _setQuery,
        onDeptFilterChanged: _setDeptFilter,
        onStatusFilterChanged: _setStatusFilter,
        onSortToggle: _toggleSort,
        onPageChanged: (p) => setState(() => _page = p),
        onClearFilters: _clearFilters,
        onUpdate: _updateTeacher,
        onDelete: _deleteTeacher,
      ),
    );
    final rightPanel = Column(
      children: [
        DepartmentChartCard(
          teachers: _teachers,
          selectedDept: _deptFilter,
          onDeptTap: _onDeptTap,
        ),
        const SizedBox(height: 20),
        BirthdayCard(teachers: _teachers),
      ],
    );

    if (isNarrow) {
      return Column(
        children: [leftPanel, const SizedBox(height: 20), rightPanel],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: leftPanel),
        const SizedBox(width: 20),
        Expanded(flex: 3, child: rightPanel),
      ],
    );
  }

  Widget _buildBottomStatsGrid() {
    return AutoGrid(
      spacing: 16,
      runSpacing: 16,
      columnsForWidth: (w) => w > 1100 ? 6 : (w > 700 ? 3 : 2),
      children: kBottomStats
          .map(
            (s) => DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: s.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(s.icon, color: s.accent, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}