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
import '../widgets/dialogs/action_dialogs.dart';

class GradebookScreen extends StatefulWidget {
  const GradebookScreen({super.key});

  @override
  State<GradebookScreen> createState() => _GradebookScreenState();
}

class _GradebookScreenState extends State<GradebookScreen> {
  String? _selectedClass;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final classes = app.classNames;
    final selectedClass = _selectedClass ?? (classes.isNotEmpty ? classes.first : '');
    final students = app.studentsFiltered(className: selectedClass);
    final trend = selectedClass.isEmpty ? const <double>[] : app.classAverageTrend(selectedClass);

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gradebook', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('Track marks, trends & generate report cards', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: students.isEmpty ? null : () => _exportMarksheet(context, selectedClass, students, app),
                  icon: const Icon(Icons.ios_share_rounded, size: 16),
                  label: const Text('Export Marksheet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 260,
              child: AppDropdown<String>(
                label: 'Class',
                value: selectedClass,
                items: classes,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => _selectedClass = v),
              ),
            ),
            const SizedBox(height: 18),
            if (selectedClass.isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Class Average Trend', style: AppTextStyles.sectionTitle),
                        Text('${app.gradebookClassAverage(selectedClass).round()}% now', style: AppTextStyles.itemTitle.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 160,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  final labels = ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 5', 'Now'];
                                  if (idx < 0 || idx >= labels.length) return const SizedBox();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(labels[idx], style: AppTextStyles.caption),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [for (int i = 0; i < trend.length; i++) FlSpot(i.toDouble(), trend[i])],
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(show: true, color: AppColors.primaryLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            if (students.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No students in this class.', style: AppTextStyles.itemSub)),
              )
            else
              ResponsiveGrid(
                minItemWidth: 320,
                maxColumns: 3,
                children: [for (final s in students) _GradebookCard(student: s)],
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  void _exportMarksheet(BuildContext context, String className, List<StudentItem> students, AppState app) {
    final buffer = StringBuffer('Student,Class,Overall %,Grade\n');
    for (final s in students) {
      final pct = app.overallPercent(s.id);
      buffer.writeln('${s.name},${s.className},${pct.round()}%,${app.letterGrade(pct)}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    showAppSnack(context, 'Marksheet for $className copied — paste into Excel/Sheets', icon: Icons.ios_share_rounded);
  }
}

class _GradebookCard extends StatelessWidget {
  final StudentItem student;
  const _GradebookCard({required this.student});

  Color _gradeColor(String grade) {
    if (grade == 'A+' || grade == 'A') return AppColors.green;
    if (grade == 'B+' || grade == 'B') return AppColors.blue;
    if (grade == 'C' || grade == 'D') return AppColors.orange;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pct = app.overallPercent(student.id);
    final grade = app.letterGrade(pct);
    final records = app.recordsFor(student.id);

    return AppCard(
      onTap: () => _openDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(seed: student.avatarSeed, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: AppTextStyles.itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${records.length} assessments recorded', style: AppTextStyles.itemSub),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _gradeColor(grade).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(grade, style: TextStyle(color: _gradeColor(grade), fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: AppColors.scaffoldBg,
              valueColor: AlwaysStoppedAnimation(_gradeColor(grade)),
            ),
          ),
          const SizedBox(height: 6),
          Text('Overall: ${pct.round()}%', style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showAppFormDialog(
      context: context,
      title: student.name,
      child: _GradebookDetailBody(student: student),
    );
  }
}

class _GradebookDetailBody extends StatelessWidget {
  final StudentItem student;
  const _GradebookDetailBody({required this.student});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final records = app.recordsFor(student.id);
    final pct = app.overallPercent(student.id);
    final grade = app.letterGrade(pct);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${student.className} • Overall: ${pct.round()}% ($grade)', style: AppTextStyles.itemTitle),
          ],
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No assessments recorded yet.', style: AppTextStyles.itemSub))
        else
          for (final r in records)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title, style: AppTextStyles.itemTitle.copyWith(fontSize: 13)),
                        Text('${r.category} • ${r.date}', style: AppTextStyles.itemSub),
                      ],
                    ),
                  ),
                  Text('${r.obtained.round()}/${r.maxMarks.round()}', style: AppTextStyles.itemTitle.copyWith(fontSize: 13)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => app.deleteAssessment(student.id, r.id),
                    child: const Icon(Icons.close, size: 16, color: AppColors.red),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  showAddAssessmentDialog(context, studentId: student.id, studentName: student.name);
                },
                icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                label: const Text('Add Marks', style: TextStyle(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppPrimaryButton(
                label: 'Report Card',
                icon: Icons.description_outlined,
                onPressed: () {
                  Navigator.of(context).pop();
                  _openReportCard(context, student);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openReportCard(BuildContext context, StudentItem student) {
    showAppFormDialog(
      context: context,
      title: 'Report Card',
      child: _ReportCardBody(student: student),
    );
  }
}

class _ReportCardBody extends StatelessWidget {
  final StudentItem student;
  const _ReportCardBody({required this.student});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final records = app.recordsFor(student.id);
    final pct = app.overallPercent(student.id);
    final grade = app.letterGrade(pct);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('EduSmart ERP — Report Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 8),
              Text(student.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
              Text(student.className, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12.5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final r in records)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text('${r.title} (${r.category})', style: AppTextStyles.itemSub)),
                Text('${r.obtained.round()}/${r.maxMarks.round()} (${r.percent.round()}%)', style: AppTextStyles.itemTitle.copyWith(fontSize: 12.5)),
              ],
            ),
          ),
        const Divider(color: AppColors.border, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Overall Percentage', style: AppTextStyles.itemTitle),
            Text('${pct.round()}%', style: AppTextStyles.itemTitle.copyWith(color: AppColors.primary, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Grade', style: AppTextStyles.itemTitle),
            Text(grade, style: AppTextStyles.itemTitle.copyWith(color: AppColors.primary, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: AppPrimaryButton(
            label: 'Copy Report',
            icon: Icons.copy_rounded,
            onPressed: () {
              final buffer = StringBuffer();
              buffer.writeln('EduSmart ERP — Report Card');
              buffer.writeln('Student: ${student.name}  |  Class: ${student.className}');
              buffer.writeln('---');
              for (final r in records) {
                buffer.writeln('${r.title} (${r.category}): ${r.obtained.round()}/${r.maxMarks.round()} — ${r.percent.round()}%');
              }
              buffer.writeln('---');
              buffer.writeln('Overall: ${pct.round()}%  |  Grade: $grade');
              Clipboard.setData(ClipboardData(text: buffer.toString()));
              showAppSnack(context, 'Report card copied to clipboard', icon: Icons.copy_rounded);
            },
          ),
        ),
      ],
    );
  }
}
