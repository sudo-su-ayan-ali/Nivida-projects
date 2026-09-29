import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_record.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/filter_bar.dart';
import '../widgets/kpi_card.dart';
import '../widgets/analytics_card.dart';
import '../widgets/distribution_card.dart';
import '../widgets/attendance_table.dart';
import '../widgets/mark_attendance_dialog.dart';
import '../widgets/import_dialog.dart';
import '../widgets/export_dialog.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  State<AttendanceDashboardScreen> createState() =>
      _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  late FilterBarState _filters = FilterBarState(date: DateTime(2026, 5, 10));
  List<AttendanceRecord> _records = [];
  final _repo = AttendanceRepository();
  bool _loading = true;
  bool _refreshing = false;
  DateTime? _lastUpdated;

  // Snapshot of the last-known scoped status counts, used purely to compute
  // real "vs previous" deltas for the KPI cards instead of hardcoding them.
  Map<AttendanceStatus, int>? _previousCounts;
  double? _previousRate;
  int _teachersPresent = 84;
  int _monthlyAverage = 94;

  // Rolling history (last 6 refresh/filter cycles) that feeds the little
  // sparkline drawn inside each KPI card.
  final List<double> _presentHistory = [];
  final List<double> _absentHistory = [];
  final List<double> _lateHistory = [];
  final List<double> _rateHistory = [];

  List<String> _classOptions = [];
  List<String> _sectionOptions = [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    final classes = await _repo.fetchClassOptions();
    final sections = await _repo.fetchSectionOptions();
    if (!mounted) return;
    setState(() {
      _classOptions = classes;
      _sectionOptions = sections;
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _repo.loadForDate(_filters.date);
    if (!mounted) return;
    setState(() {
      _records = _repo.records;
      _loading = false;
      _lastUpdated = DateTime.now();
    });
    _pushHistory();
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    _previousCounts = _statusCounts;
    _previousRate = _attendanceRate;

    await _repo.loadForDate(_filters.date);

    setState(() {
      _records = _repo.records;
      _refreshing = false;
      _lastUpdated = DateTime.now();
      _teachersPresent = (80 + (DateTime.now().millisecond % 10))
          .clamp(75, 90)
          .toInt();
      _monthlyAverage = (91 + (DateTime.now().millisecond % 6))
          .clamp(90, 97)
          .toInt();
    });
    _pushHistory();
    _toast('Dashboard refreshed');
  }

  void _pushHistory() {
    final counts = _statusCounts;
    void push(List<double> list, double value) {
      list.add(value);
      if (list.length > 6) list.removeAt(0);
    }

    push(_presentHistory, (counts[AttendanceStatus.present] ?? 0).toDouble());
    push(_absentHistory, (counts[AttendanceStatus.absent] ?? 0).toDouble());
    push(_lateHistory, (counts[AttendanceStatus.late] ?? 0).toDouble());
    push(_rateHistory, _attendanceRate);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<AttendanceRecord> get _scopedRecords {
    return _records.where((r) {
      final matchesClass =
          _filters.selectedClass == 'All Classes' ||
          r.studentClass == _filters.selectedClass;
      final matchesSection =
          _filters.selectedSection == 'All Sections' ||
          r.section == _filters.selectedSection;
      return matchesClass && matchesSection;
    }).toList();
  }

  Map<AttendanceStatus, int> get _statusCounts {
    final counts = {for (final s in AttendanceStatus.values) s: 0};
    for (final r in _scopedRecords) {
      counts[r.status] = (counts[r.status] ?? 0) + 1;
    }
    return counts;
  }

  double get _attendanceRate {
    final total = _scopedRecords.length;
    if (total == 0) return 0;
    final present = _statusCounts[AttendanceStatus.present] ?? 0;
    return (present / total) * 100;
  }

  double _deltaPct(num current, num? previous) {
    if (previous == null || previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  void _applyFilters(FilterBarState s) {
    // Capture "previous" before the filter changes the scoped data, so the
    // KPI cards still show a meaningful before/after instead of freezing.
    _previousCounts = _statusCounts;
    _previousRate = _attendanceRate;
    setState(() => _filters = s);
    _pushHistory();
  }

  @override
  Widget build(BuildContext context) {
    final counts = _statusCounts;
    final present = counts[AttendanceStatus.present] ?? 0;
    final absent = counts[AttendanceStatus.absent] ?? 0;
    final lateCount = counts[AttendanceStatus.late] ?? 0;
    final leave = counts[AttendanceStatus.leave] ?? 0;
    final rate = _attendanceRate.round();

    final presentDelta = _deltaPct(
      present,
      _previousCounts?[AttendanceStatus.present],
    );
    final absentDelta = _deltaPct(
      absent,
      _previousCounts?[AttendanceStatus.absent],
    );
    final lateDelta = _deltaPct(
      lateCount,
      _previousCounts?[AttendanceStatus.late],
    );
    final rateDelta = _deltaPct(_attendanceRate, _previousRate);

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(24),
      child: _loading
          ? const _LoadingState()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardHeader(
                    onMarkAttendance: _openMarkAttendance,
                    onImport: _openImport,
                    onExport: _openExport,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: cardDecoration(),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilterBar(
                          state: _filters,
                          isRefreshing: _refreshing,
                          onChanged: _applyFilters,
                          onRefresh: _refresh,
                          classOptions: _classOptions,
                          sectionOptions: _sectionOptions,
                        ),
                        if (_lastUpdated != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Last updated ${DateFormat('h:mm:ss a').format(_lastUpdated!)}',
                              style: AppText.cardLabel.copyWith(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _KpiGrid(
                    cards: [
                      KpiCardData(
                        label: 'Present Today',
                        value: present,
                        icon: Icons.groups_rounded,
                        iconColor: AppColors.success,
                        iconBg: AppColors.successBg,
                        deltaPercent: presentDelta,
                        deltaSuffix: 'from last refresh',
                        trend: List.of(_presentHistory),
                      ),
                      KpiCardData(
                        label: 'Absent Today',
                        value: absent,
                        icon: Icons.person_off_rounded,
                        iconColor: AppColors.danger,
                        iconBg: AppColors.dangerBg,
                        deltaPercent: absentDelta,
                        deltaSuffix: 'from last refresh',
                        trend: List.of(_absentHistory),
                      ),
                      KpiCardData(
                        label: 'Late Students',
                        value: lateCount,
                        icon: Icons.access_time_filled_rounded,
                        iconColor: AppColors.warning,
                        iconBg: AppColors.warningBg,
                        deltaPercent: lateDelta,
                        deltaSuffix: 'from last refresh',
                        trend: List.of(_lateHistory),
                      ),
                      KpiCardData(
                        label: 'Attendance Rate',
                        value: rate,
                        isPercent: true,
                        icon: Icons.query_stats_rounded,
                        iconColor: AppColors.info,
                        iconBg: AppColors.infoBg,
                        deltaPercent: rateDelta,
                        deltaSuffix: 'from last refresh',
                        trend: List.of(_rateHistory),
                      ),
                      KpiCardData(
                        label: 'Teachers Present',
                        value: _teachersPresent,
                        icon: Icons.school_rounded,
                        iconColor: AppColors.purple,
                        iconBg: AppColors.purpleBg,
                        deltaPercent: 4.3,
                        deltaSuffix: 'from yesterday',
                      ),
                      KpiCardData(
                        label: 'Monthly Average',
                        value: _monthlyAverage,
                        isPercent: true,
                        icon: Icons.bar_chart_rounded,
                        iconColor: AppColors.cyan,
                        iconBg: AppColors.cyanBg,
                        deltaPercent: 3.6,
                        deltaSuffix: 'from last month',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 980;
                      final analytics = AnalyticsCard(repo: _repo);
                      final distribution = DistributionCard(
                        totalStudents: 1448,
                        centerPercent: rate,
                        slices: [
                          DistributionSlice(
                            'Present',
                            present,
                            AppColors.success,
                          ),
                          DistributionSlice('Absent', absent, AppColors.danger),
                          DistributionSlice(
                            'Late',
                            lateCount,
                            AppColors.warning,
                          ),
                          DistributionSlice('Leave', leave, AppColors.info),
                        ],
                      );
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 65, child: analytics),
                            const SizedBox(width: 20),
                            Expanded(flex: 35, child: distribution),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          analytics,
                          const SizedBox(height: 20),
                          distribution,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AttendanceTable(
                    records: _scopedRecords,
                    onView: _showRecordDetails,
                    onUpdateStatus: _updateSingleStatus,
                    onNotifyParent: _notifyParent,
                    onBulkUpdateStatus: _bulkUpdateStatus,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }

  void _updateSingleStatus(
    AttendanceRecord record,
    AttendanceStatus newStatus,
  ) {
    _repo.markAttendance(
      record.avatarSeed,
      record.studentClass,
      _filters.date,
      newStatus.name,
    );
    setState(() {
      _records = _records
          .map((r) => r.id == record.id ? r.copyWith(status: newStatus) : r)
          .toList();
    });
    _toast('${record.studentName} marked ${newStatus.label}');
  }

  void _bulkUpdateStatus(
    List<AttendanceRecord> records,
    AttendanceStatus newStatus,
  ) {
    final ids = records.map((r) => r.id).toSet();
    setState(() {
      _records = _records
          .map((r) => ids.contains(r.id) ? r.copyWith(status: newStatus) : r)
          .toList();
    });
    _toast('${records.length} students marked ${newStatus.label}');
  }

  void _notifyParent(AttendanceRecord record) {
    // Hook point for a real notification/SMS/email API call.
  }

  void _openMarkAttendance() async {
    final roster = await _repo.loadAllStudentsForMarking();
    if (!mounted) return;
    MarkAttendanceDialog.show(
      context,
      students: roster,
      onSave: (statuses, remarks) {
        for (final entry in statuses.entries) {
          final student = roster.firstWhere((s) => s.id == entry.key);
          _repo.markAttendance(
            student.avatarSeed,
            student.studentClass,
            _filters.date,
            entry.value.name,
          );
        }
        _toast('Attendance saved for ${statuses.length} students');
        _load();
      },
    );
  }

  void _openImport() {
    ImportAttendanceDialog.show(
      context,
      repo: _repo,
      date: _filters.date,
      onImported: (fileName, rows) {
        _load(); // reload real records for the selected date from Supabase
        _toast('Imported $rows records from $fileName');
      },
    );
  }

  void _openExport() {
    ExportReportDialog.show(
      context,
      useCurrentFilters:
          _filters.selectedClass != 'All Classes' ||
          _filters.selectedSection != 'All Sections',
      onExported: (format, filtered) {
        _toast(
          'Report exported as ${format.label}${filtered ? ' (filtered)' : ''}',
        );
      },
    );
  }

  void _showRecordDetails(AttendanceRecord record) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(record.studentName, style: AppText.sectionTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Roll No.', record.rollNo),
            _detailRow('Class', '${record.studentClass} - ${record.section}'),
            _detailRow('Status', record.status.label),
            _detailRow('Check In', record.checkIn),
            _detailRow('Check Out', record.checkOut),
            _detailRow('Remarks', record.remarks),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: AppText.cardLabel)),
          Expanded(child: Text(value, style: AppText.tableCell)),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final List<KpiCardData> cards;
  const _KpiGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 6;
        if (constraints.maxWidth < 560) {
          columns = 2;
        } else if (constraints.maxWidth < 860) {
          columns = 3;
        } else if (constraints.maxWidth < 1180) {
          columns = 4;
        }
        const spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final c in cards)
              SizedBox(
                width: itemWidth,
                child: KpiCard(data: c),
              ),
          ],
        );
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Loading attendance dashboard...', style: AppText.cardLabel),
          ],
        ),
      ),
    );
  }
}