import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final gradeCounts = <String, int>{};
    for (final r in store.results) {
      gradeCounts[r.overallGrade] = (gradeCounts[r.overallGrade] ?? 0) + 1;
    }
    final passCount = store.results.where((r) => r.pass).length;
    final total = store.results.isEmpty ? 1 : store.results.length;
    final passPct = (passCount / total * 100);

    final bookStatusCounts = <String, int>{};
    for (final b in store.books) {
      bookStatusCounts[b.status.label] = (bookStatusCounts[b.status.label] ?? 0) + 1;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Analytics & Reports', subtitle: 'Performance, evaluation progress, and operational analytics'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grade Distribution', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('Pass % so far: ${passPct.toStringAsFixed(1)}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                        SizedBox(
                          height: 220,
                          child: gradeCounts.isEmpty
                              ? const Center(child: Text('Compute results to see distribution.', style: TextStyle(color: AppColors.textSecondary)))
                              : PieChart(PieChartData(
                                  sections: gradeCounts.entries
                                      .map((e) => PieChartSectionData(value: e.value.toDouble(), title: '${e.key}\n${e.value}', radius: 70, titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)))
                                      .toList(),
                                  sectionsSpace: 2,
                                )),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Answer Book Status Overview', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: bookStatusCounts.isEmpty
                              ? const Center(child: Text('No books generated yet.'))
                              : BarChart(BarChartData(
                                  barGroups: bookStatusCounts.entries
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value.toDouble(), color: AppColors.primary, width: 14, borderRadius: BorderRadius.circular(3))]))
                                      .toList(),
                                  titlesData: const FlTitlesData(
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                                )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Examiner Workload', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...{
                    for (final b in store.books.where((b) => b.examinerId != null)) b.examinerId!: store.books.where((x) => x.examinerId == b.examinerId).length
                  }.entries.map((e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person_outline, color: AppColors.primary),
                        title: Text(store.demoUsers.firstWhere((u) => u.id == e.key, orElse: () => AppUser(id: e.key, name: e.key, email: '', role: AppRole.examiner)).name),
                        trailing: Text('${e.value} scripts'),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
