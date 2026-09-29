import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/teacher.dart';
import '../theme/app_colors.dart';
import 'dashboard_cards.dart';

/// "Department Wise Teachers" donut chart with a legend, matching the
/// reference design's centered total + colored department key.
class DepartmentChartCard extends StatelessWidget {
  final List<Teacher> teachers;
  final String? selectedDept;
  final ValueChanged<String>? onDeptTap;
  const DepartmentChartCard({super.key, required this.teachers, this.selectedDept, this.onDeptTap});

  Map<String, int> get _counts {
    final map = <String, int>{};
    for (final t in teachers) {
      map[t.department] = (map[t.department] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _counts;
    final total = teachers.length;
    final entries = counts.entries.toList();

    final chart = SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 46,
              sections: [
                for (final e in entries)
                  PieChartSectionData(
                    value: e.value.toDouble(),
                    color: _colorFor(e.key),
                    radius: 24,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$total',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
              const Text('Total',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );

    final legend = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in entries)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onDeptTap == null ? null : () => onDeptTap!(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                margin: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: selectedDept == e.key ? _colorFor(e.key).withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: _colorFor(e.key), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.key,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: selectedDept == e.key ? FontWeight.w800 : FontWeight.w600,
                              color: const Color(0xFF4B5563))),
                    ),
                    const SizedBox(width: 6),
                    Text('${e.value}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Department Wise Teachers'),
          if (selectedDept != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text('Filtering Teacher List by $selectedDept',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
                InkWell(
                  onTap: () => onDeptTap?.call(selectedDept!),
                  child: const Text('Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.danger)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final narrow = constraints.maxWidth < 260;
            if (narrow) {
              return Column(
                children: [
                  Center(child: chart),
                  const SizedBox(height: 16),
                  legend,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                chart,
                const SizedBox(width: 12),
                Expanded(child: legend),
              ],
            );
          }),
        ],
      ),
    );
  }

  static const Map<String, Color> _deptColors = {
    'Mathematics': Color(0xFF5B5CF6),
    'Science': Color(0xFF3B82F6),
    'English': Color(0xFF22C55E),
    'Computer Science': Color(0xFFF59E0B),
    'Social Studies': Color(0xFFEC4899),
    'Physical Education': Color(0xFF14B8A6),
    'Arts': Color(0xFFA855F7),
    'Music': Color(0xFFEF4444),
  };

  Color _colorFor(String dept) => _deptColors[dept] ?? const Color(0xFF94A3B8);
}
