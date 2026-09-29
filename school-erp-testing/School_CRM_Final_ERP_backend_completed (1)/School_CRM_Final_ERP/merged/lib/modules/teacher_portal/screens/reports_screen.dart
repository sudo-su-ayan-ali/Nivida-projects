import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/common/responsive_grid.dart';

/// Feature 4 — Class-Wide Analytics & Report Builder.
/// Two modes: a "Class Report" (pick a report type, a class scope & a date
/// range for a whole-class analytics summary) and a "Student Report" (pick
/// one student and generate a detailed, PTM-ready analytics report, laid
/// out for A4 printing) — the decision-making + PTM prep tool that was
/// completely missing when charts only ever covered one class at a time.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

const List<String> _kReportTypes = ['Full Summary', 'Attendance Trend', 'Fee Collection', 'Exam Performance'];
const List<String> _kRanges = ['This Week', 'This Month', 'This Term'];
const List<String> _kReportModes = ['Class Report', 'Student Report'];

class _ReportsScreenState extends State<ReportsScreen> {
  String _mode = 'Class Report';

  String _reportType = 'Full Summary';
  String _scope = 'All Classes';
  String _range = 'This Month';

  bool _generated = false;
  String _genType = '';
  String _genScope = '';
  String _genRange = '';

  String _studentClass = '';
  String? _studentId;
  String? _genStudentId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final classes = ['All Classes', ...app.classNames];
    if (!classes.contains(_scope)) _scope = 'All Classes';

    // Keep the Student Report picker's defaults in sync with real data,
    // the same way _scope is kept in sync with `classes` above.
    final studentClasses = app.classNames;
    if (!studentClasses.contains(_studentClass)) {
      _studentClass = studentClasses.isNotEmpty ? studentClasses.first : '';
    }
    final studentsInClass = _studentClass.isEmpty ? <String>[] : app.studentsFiltered(className: _studentClass).map((s) => s.id).toList();
    if (!studentsInClass.contains(_studentId)) {
      _studentId = studentsInClass.isNotEmpty ? studentsInClass.first : null;
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class-Wide Analytics & Report Builder', style: AppTextStyles.greetingTitle),
            const SizedBox(height: 4),
            Text('Whole-class summaries, or a detailed, printable A4 report for one student at a time — ready for PTM', style: AppTextStyles.greetingSubtitle),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: [
                for (final m in _kReportModes)
                  ChoiceChip(
                    label: Text(m),
                    selected: _mode == m,
                    onSelected: (_) => setState(() => _mode = m),
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(color: _mode == m ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12.5),
                    backgroundColor: AppColors.scaffoldBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (_mode == 'Class Report') ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report Filters', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        SizedBox(
                          width: 230,
                          child: AppDropdown<String>(label: 'Report Type', value: _reportType, items: _kReportTypes, itemLabel: (t) => t, onChanged: (v) => setState(() => _reportType = v ?? _reportType)),
                        ),
                        SizedBox(
                          width: 230,
                          child: AppDropdown<String>(label: 'Class', value: _scope, items: classes, itemLabel: (c) => c, onChanged: (v) => setState(() => _scope = v ?? _scope)),
                        ),
                        SizedBox(
                          width: 230,
                          child: AppDropdown<String>(label: 'Date Range', value: _range, items: _kRanges, itemLabel: (r) => r, onChanged: (v) => setState(() => _range = v ?? _range)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 220,
                      child: AppPrimaryButton(
                        label: 'Generate Report',
                        icon: Icons.auto_graph_rounded,
                        onPressed: () => setState(() {
                          _generated = true;
                          _genType = _reportType;
                          _genScope = _scope;
                          _genRange = _range;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_generated) _ReportPreview(app: app, reportType: _genType, scope: _genScope, range: _genRange) else _EmptyState(),
            ] else ...[
              _StudentReportFilters(
                app: app,
                studentClass: _studentClass,
                studentId: _studentId,
                onClassChanged: (v) => setState(() {
                  _studentClass = v;
                  _studentId = null;
                }),
                onStudentChanged: (v) => setState(() => _studentId = v),
                onGenerate: _studentId == null
                    ? null
                    : () => setState(() => _genStudentId = _studentId),
              ),
              const SizedBox(height: 18),
              if (_genStudentId != null)
                _StudentReportPreview(app: app, studentId: _genStudentId!)
              else
                _EmptyState(message: 'Pick a class & student above, then generate their PTM report'),
            ],
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({this.message = 'Pick your filters above and generate a report'});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.insert_chart_outlined_rounded, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.itemSub),
          ],
        ),
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  final AppState app;
  final String reportType;
  final String scope;
  final String range;
  const _ReportPreview({required this.app, required this.reportType, required this.scope, required this.range});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Document" style header — evokes a printable PDF report.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EduSmart School — $reportType', style: AppTextStyles.greetingTitle.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Scope: $scope  •  Range: $range  •  Generated: Just now', style: AppTextStyles.itemSub),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: app.buildReportCsv(reportType: reportType, scope: scope)));
                  showAppSnack(context, 'Report copied — paste into Excel/Sheets or a PDF tool', icon: Icons.ios_share_rounded);
                },
                icon: const Icon(Icons.ios_share_rounded, size: 15),
                label: const Text('Export'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.border),
          ResponsiveGrid(
            minItemWidth: 190,
            maxColumns: 4,
            children: [
              _kpi('Attendance', '${app.schoolAttendancePercent.toStringAsFixed(0)}%', AppColors.green, AppColors.greenBg, Icons.how_to_reg_outlined),
              _kpi('Fee Collection', '${app.feeCollectionPercent.toStringAsFixed(0)}%', AppColors.orange, AppColors.orangeBg, Icons.receipt_long_outlined),
              _kpi('Avg Exam Score', '${app.schoolAverageExamPerformance.toStringAsFixed(0)}%', AppColors.pink, AppColors.pinkBg, Icons.grade_outlined),
              _kpi('Students in Scope', '${scope == 'All Classes' ? app.students.length : app.students.where((s) => s.className == scope).length}', AppColors.blue, AppColors.blueBg, Icons.groups_outlined),
            ],
          ),
          const SizedBox(height: 24),
          if (reportType == 'Attendance Trend' || reportType == 'Full Summary') ...[
            Text('Attendance Trend', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            SizedBox(height: 180, child: _attendanceChart()),
            const SizedBox(height: 24),
          ],
          if (reportType == 'Exam Performance' || reportType == 'Full Summary') ...[
            Text('Exam Performance by Class', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: _performanceChart()),
            const SizedBox(height: 24),
          ],
          if (reportType == 'Fee Collection' || reportType == 'Full Summary') ...[
            Text('Fee Collection Breakdown', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            _feeTable(),
          ],
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.statValue.copyWith(fontSize: 18, color: color)),
          Text(label, style: AppTextStyles.itemSub),
        ],
      ),
    );
  }

  Widget _attendanceChart() {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1)),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34, interval: 25, getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: AppTextStyles.caption))),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, m) {
                final idx = v.toInt();
                if (idx < 0 || idx >= app.weeklyAttendanceLabels.length) return const SizedBox();
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(app.weeklyAttendanceLabels[idx], style: AppTextStyles.caption));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppColors.green,
            barWidth: 3,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(radius: 3.5, color: AppColors.green, strokeColor: Colors.white, strokeWidth: 2)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.green.withOpacity(0.2), AppColors.green.withOpacity(0)])),
            spots: List.generate(app.weeklyAttendance.length, (i) => FlSpot(i.toDouble(), app.weeklyAttendance[i])),
          ),
        ],
      ),
    );
  }

  Widget _performanceChart() {
    final breakdown = app.classPerformanceBreakdown(className: scope);
    final names = breakdown.keys.toList();
    if (names.isEmpty) return Center(child: Text('No performance data yet.', style: AppTextStyles.itemSub));
    return BarChart(
      BarChartData(
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34, interval: 25, getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: AppTextStyles.caption))),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, m) {
                final idx = v.toInt();
                if (idx < 0 || idx >= names.length) return const SizedBox();
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(names[idx], style: AppTextStyles.caption));
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItem: (group, groupIdx, rod, rodIdx) => BarTooltipItem('${rod.toY.toStringAsFixed(0)}%', const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ),
        barGroups: [
          for (int i = 0; i < names.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: breakdown[names[i]] ?? 0, color: AppColors.primary, width: 22, borderRadius: BorderRadius.circular(6))]),
        ],
      ),
    );
  }

  Widget _feeTable() {
    final records = scope == 'All Classes' ? app.feeRecords : app.feeRecords.where((f) {
        final s = app.studentById(f.studentId);
        return s?.className == scope;
      }).toList();
    final paid = records.where((f) => f.status == 'Paid').length;
    final total = records.length;
    final collected = records.where((f) => f.status == 'Paid').fold(0.0, (a, f) => a + f.amount);
    final pending = records.where((f) => f.status != 'Paid').fold(0.0, (a, f) => a + f.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _feeStat('Collected', '₹${collected.toStringAsFixed(0)}', AppColors.green)),
            const SizedBox(width: 12),
            Expanded(child: _feeStat('Pending', '₹${pending.toStringAsFixed(0)}', AppColors.red)),
            const SizedBox(width: 12),
            Expanded(child: _feeStat('Paid Students', '$paid / $total', AppColors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _feeStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.itemTitle.copyWith(fontSize: 16, color: color)),
          Text(label, style: AppTextStyles.itemSub),
        ],
      ),
    );
  }
}

/// Class + student picker for the "Student Report" mode.
class _StudentReportFilters extends StatelessWidget {
  final AppState app;
  final String studentClass;
  final String? studentId;
  final ValueChanged<String> onClassChanged;
  final ValueChanged<String> onStudentChanged;
  final VoidCallback? onGenerate;

  const _StudentReportFilters({
    required this.app,
    required this.studentClass,
    required this.studentId,
    required this.onClassChanged,
    required this.onStudentChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final classes = app.classNames;
    final studentsInClass = studentClass.isEmpty ? <String>[] : app.studentsFiltered(className: studentClass).map((s) => s.id).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Student', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              SizedBox(
                width: 230,
                child: classes.isEmpty
                    ? Text('No classes yet.', style: AppTextStyles.itemSub)
                    : AppDropdown<String>(
                        label: 'Class',
                        value: studentClass,
                        items: classes,
                        itemLabel: (c) => c,
                        onChanged: (v) => onClassChanged(v ?? studentClass),
                      ),
              ),
              SizedBox(
                width: 260,
                child: studentsInClass.isEmpty
                    ? Text('No students in this class.', style: AppTextStyles.itemSub)
                    : AppDropdown<String>(
                        label: 'Student',
                        value: studentId ?? studentsInClass.first,
                        items: studentsInClass,
                        itemLabel: (id) => app.studentById(id)?.name ?? id,
                        onChanged: (v) => onStudentChanged(v ?? studentsInClass.first),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 260,
            child: AppPrimaryButton(
              label: 'Generate Student Report',
              icon: Icons.assignment_ind_outlined,
              onPressed: onGenerate,
            ),
          ),
        ],
      ),
    );
  }
}

/// A detailed, single-student analytics report laid out for A4 printing —
/// meant to be handed to (or shown to) a parent at a PTM.
class _StudentReportPreview extends StatefulWidget {
  final AppState app;
  final String studentId;
  const _StudentReportPreview({required this.app, required this.studentId});

  @override
  State<_StudentReportPreview> createState() => _StudentReportPreviewState();
}

class _StudentReportPreviewState extends State<_StudentReportPreview> {
  late final TextEditingController _remarkCtrl;

  @override
  void initState() {
    super.initState();
    _remarkCtrl = TextEditingController(text: widget.app.remarkFor(widget.studentId));
  }

  @override
  void didUpdateWidget(covariant _StudentReportPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentId != widget.studentId) {
      _remarkCtrl.text = widget.app.remarkFor(widget.studentId);
    }
  }

  @override
  void dispose() {
    _remarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final student = app.studentById(widget.studentId);
    if (student == null) {
      return AppCard(child: Text('Student not found.', style: AppTextStyles.itemSub));
    }

    final records = app.recordsFor(student.id);
    final overall = app.overallPercent(student.id);
    final grade = app.letterGrade(overall);
    final classAvg = app.gradebookClassAverage(student.className);
    final attendancePct = app.studentAttendancePercent(student.id);
    final fee = app.feeRecords.where((f) => f.studentId == student.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.description_outlined, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text('A4 print layout — use your device\'s Print (Ctrl/Cmd + P) on this page', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 10),
        // A4 page proportions at 96dpi (~794px wide) so this reads exactly
        // like the printed sheet a parent would take home from PTM.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 794),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EduSmart School', style: AppTextStyles.greetingTitle.copyWith(fontSize: 19)),
                          const SizedBox(height: 2),
                          Text('Student Performance & Analytics Report', style: AppTextStyles.itemTitle.copyWith(color: AppColors.primary)),
                          Text('Prepared for Parent-Teacher Meeting (PTM)', style: AppTextStyles.itemSub),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: app.buildStudentReportText(student.id)));
                          showAppSnack(context, 'Report copied — paste into a doc/PDF, or print this page directly', icon: Icons.ios_share_rounded);
                        },
                        icon: const Icon(Icons.print_outlined, size: 15),
                        label: const Text('Export / Print'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: AppColors.border),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InitialsAvatar(seed: student.name, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name, style: AppTextStyles.greetingTitle.copyWith(fontSize: 17)),
                            const SizedBox(height: 2),
                            Text('Class: ${student.className}   •   Student ID: ${student.id}', style: AppTextStyles.itemSub),
                          ],
                        ),
                      ),
                      Text('Generated: Just now', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ResponsiveGrid(
                    minItemWidth: 170,
                    maxColumns: 4,
                    children: [
                      _kpi('Attendance (term)', '${attendancePct.toStringAsFixed(0)}%', AppColors.green, AppColors.greenBg, Icons.how_to_reg_outlined),
                      _kpi('Overall Score', '${overall.toStringAsFixed(0)}%', AppColors.blue, AppColors.blueBg, Icons.grade_outlined),
                      _kpi('Grade', grade, AppColors.purple, AppColors.purpleBg, Icons.workspace_premium_outlined),
                      _kpi('Class Average', '${classAvg.toStringAsFixed(0)}%', AppColors.pink, AppColors.pinkBg, Icons.groups_outlined),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text('Assessment-Wise Performance', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    Text('No assessments recorded yet.', style: AppTextStyles.itemSub)
                  else ...[
                    _recordsTable(records),
                    const SizedBox(height: 24),
                    SizedBox(height: 190, child: _recordsChart(records)),
                  ],
                  const SizedBox(height: 26),
                  Text('Fee Status', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  if (fee.isEmpty)
                    Text('No fee record on file.', style: AppTextStyles.itemSub)
                  else
                    Row(
                      children: [
                        Expanded(child: _feeStat('Status', fee.first.status, fee.first.status == 'Paid' ? AppColors.green : AppColors.red)),
                        const SizedBox(width: 12),
                        Expanded(child: _feeStat('Due Date', fee.first.dueDate, AppColors.textPrimary)),
                        const SizedBox(width: 12),
                        Expanded(child: _feeStat('Amount', '₹${fee.first.amount.toStringAsFixed(0)}', AppColors.blue)),
                      ],
                    ),
                  const SizedBox(height: 26),
                  Text('Teacher\'s Remarks', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _remarkCtrl,
                    maxLines: 3,
                    onChanged: (v) => app.setStudentRemark(student.id, v),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add notes for the parent to read at PTM…',
                      filled: true,
                      fillColor: AppColors.scaffoldBg,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Center(child: Text('EduSmart School • Class-Wide Analytics & Report Builder • Page 1 of 1', style: AppTextStyles.caption)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpi(String label, String value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.statValue.copyWith(fontSize: 18, color: color)),
          Text(label, style: AppTextStyles.itemSub),
        ],
      ),
    );
  }

  Widget _feeStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.itemTitle.copyWith(fontSize: 16, color: color)),
          Text(label, style: AppTextStyles.itemSub),
        ],
      ),
    );
  }

  Widget _recordsTable(List<AssessmentRecord> records) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.4),
        1: FlexColumnWidth(1.4),
        2: FlexColumnWidth(1.4),
        3: FlexColumnWidth(1.2),
        4: FlexColumnWidth(1.2),
      },
      border: TableBorder(
        horizontalInside: const BorderSide(color: AppColors.border),
        bottom: const BorderSide(color: AppColors.border),
      ),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.scaffoldBg),
          children: [
            _tableHeadCell('Assessment'),
            _tableHeadCell('Category'),
            _tableHeadCell('Date'),
            _tableHeadCell('Marks'),
            _tableHeadCell('%'),
          ],
        ),
        for (final r in records)
          TableRow(
            children: [
              _tableCell(r.title, bold: true),
              _tableCell(r.category),
              _tableCell(r.date),
              _tableCell('${r.obtained.toStringAsFixed(0)}/${r.maxMarks.toStringAsFixed(0)}'),
              _tableCell('${r.percent.toStringAsFixed(0)}%'),
            ],
          ),
      ],
    );
  }

  Widget _tableHeadCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(text, style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    );
  }

  Widget _tableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(text, style: bold ? AppTextStyles.itemTitle.copyWith(fontSize: 12.5) : AppTextStyles.itemSub),
    );
  }

  Widget _recordsChart(List<AssessmentRecord> records) {
    return BarChart(
      BarChartData(
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34, interval: 25, getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: AppTextStyles.caption))),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, m) {
                final idx = v.toInt();
                if (idx < 0 || idx >= records.length) return const SizedBox();
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(records[idx].category, style: AppTextStyles.caption));
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItem: (group, groupIdx, rod, rodIdx) => BarTooltipItem('${rod.toY.toStringAsFixed(0)}%', const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ),
        barGroups: [
          for (int i = 0; i < records.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: records[i].percent, color: AppColors.primary, width: 22, borderRadius: BorderRadius.circular(6))]),
        ],
      ),
    );
  }
}