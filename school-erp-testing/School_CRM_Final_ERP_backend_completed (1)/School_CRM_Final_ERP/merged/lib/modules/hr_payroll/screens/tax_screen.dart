import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';

class TaxScreen extends StatelessWidget {
  const TaxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final records = state.taxRecords;
    final totalTax = records.fold(0.0, (a, b) => a + b.tax);
    final totalTds = records.fold(0.0, (a, b) => a + b.tds);
    final totalIncome = records.fold(0.0, (a, b) => a + b.annualIncome);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Tax Management', subtitle: 'Manage employee tax and TDS calculations'),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 500 ? 2 : 1);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 2.6,
            children: [
              _StatMini(label: 'Total Annual Income', value: '₹${totalIncome.toStringAsFixed(0)}', color: AppColors.primary),
              _StatMini(label: 'Total Tax Liability', value: '₹${totalTax.toStringAsFixed(0)}', color: AppColors.danger),
              _StatMini(label: 'Monthly TDS', value: '₹${totalTds.toStringAsFixed(0)}', color: AppColors.warning),
            ],
          );
        }),
        const SizedBox(height: 18),
        ChartCard(
          title: 'Tax Distribution by Employee',
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= records.length) return const SizedBox();
                        final name = records[idx].employeeName.split(' ').first;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(name, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < records.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                          toY: records[i].tax, color: AppColors.danger, width: 20, borderRadius: BorderRadius.circular(4)),
                    ]),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const ['Employee', 'Financial Year', 'Annual Income', 'Taxable Income', 'Tax', 'Monthly TDS', 'Status'],
            emptyMessage: 'No tax records available',
            rows: [
              for (final t in records)
                DataRow(cells: [
                  DataCell(Text(t.employeeName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(t.financialYear)),
                  DataCell(Text('₹${t.annualIncome.toStringAsFixed(0)}')),
                  DataCell(Text('₹${t.taxableIncome.toStringAsFixed(0)}')),
                  DataCell(Text('₹${t.tax.toStringAsFixed(0)}')),
                  DataCell(Text('₹${t.tds.toStringAsFixed(0)}')),
                  DataCell(StatusBadge.forStatus(t.status)),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatMini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
