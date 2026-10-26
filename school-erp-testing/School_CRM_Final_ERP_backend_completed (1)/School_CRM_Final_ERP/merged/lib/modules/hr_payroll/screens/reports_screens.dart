import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../data/hr_export_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HrReportsScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const HrReportsScreen({super.key, this.args = const {}});

  @override
  State<HrReportsScreen> createState() => _HrReportsScreenState();
}

class _HrReportsScreenState extends State<HrReportsScreen> {
  String _reportType = 'Employee Report';
  String? _department;

  final _reportTypes = const [
    'Employee Report',
    'Attendance Report',
    'Leave Report',
    'Department Report',
    'Joining / Exit Report',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.args['reportType'] is String &&
        _reportTypes.contains(widget.args['reportType'])) {
      _reportType = widget.args['reportType'] as String;
    }
    if (widget.args['department'] is String) {
      _department = widget.args['department'] as String;
    }
  }

  @override
  void didUpdateWidget(HrReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.args['reportType'] is String &&
        widget.args['reportType'] != oldWidget.args['reportType'] &&
        _reportTypes.contains(widget.args['reportType'])) {
      setState(() => _reportType = widget.args['reportType'] as String);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final depts = state.topDepartmentsByHeadcount;
    final maxCount = depts.values.isEmpty ? 1 : depts.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'HR Reports',
          subtitle: 'Employee, attendance, leave and department reports',
          actions: [
            SecondaryButton(
              label: 'Export',
              icon: Icons.download_outlined,
              onPressed: () async {
                await HrExportService.exportHrReportCsv(
                  reportType: _reportType,
                  department: _department,
                  state: state,
                );
                if (context.mounted) {
                  showAppToast(context, '$_reportType exported to CSV');
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Wrap(spacing: 14, runSpacing: 14, children: [
            FilterDropdown<String>(
              hint: 'Report Type',
              value: _reportType,
              items: _reportTypes,
              labelBuilder: (v) => v,
              onChanged: (v) => setState(() => _reportType = v ?? _reportType),
            ),
            FilterDropdown<String>(
              hint: 'Department',
              value: _department,
              items: state.departments.map((d) => d.name).toList(),
              labelBuilder: (v) => v,
              onChanged: (v) => setState(() => _department = v),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 900 ? 4 : (c.maxWidth > 500 ? 2 : 1);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 2.5,
            children: [
              _StatMini(label: 'Total Employees', value: '${state.totalEmployees}', color: AppColors.primary),
              _StatMini(label: 'Avg Attendance', value: '${state.attendanceTodayPercent.toStringAsFixed(0)}%', color: AppColors.success),
              _StatMini(label: 'Leave Requests', value: '${state.leaves.length}', color: AppColors.warning),
              _StatMini(label: 'Departments', value: '${state.totalDepartments}', color: AppColors.purple),
            ],
          );
        }),
        const SizedBox(height: 18),
        ChartCard(
          title: 'Department-wise Headcount',
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                maxY: maxCount * 1.3,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= depts.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(depts.keys.elementAt(idx),
                              style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < depts.length; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                          toY: depts.values.elementAt(i).toDouble(),
                          color: AppColors.primary,
                          width: 20,
                          borderRadius: BorderRadius.circular(4)),
                    ]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PayrollReportsScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const PayrollReportsScreen({super.key, this.args = const {}});

  @override
  State<PayrollReportsScreen> createState() => _PayrollReportsScreenState();
}

class _PayrollReportsScreenState extends State<PayrollReportsScreen> {
  String _reportType = 'Monthly Payroll';
  final _reportTypes = const ['Monthly Payroll', 'Salary Report', 'Deduction Report', 'Tax Report', 'Payslip Report'];

  @override
  void initState() {
    super.initState();
    if (widget.args['reportType'] is String &&
        _reportTypes.contains(widget.args['reportType'])) {
      _reportType = widget.args['reportType'] as String;
    }
  }

  @override
  void didUpdateWidget(PayrollReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.args['reportType'] is String &&
        widget.args['reportType'] != oldWidget.args['reportType'] &&
        _reportTypes.contains(widget.args['reportType'])) {
      setState(() => _reportType = widget.args['reportType'] as String);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final trends = state.payrollTrends6Months;
    final labels = state.payrollTrendLabels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Payroll Reports',
          subtitle: 'Salary, deduction and tax reports',
          actions: [
            SecondaryButton(
              label: 'Export',
              icon: Icons.download_outlined,
              onPressed: () async {
                await HrExportService.exportPayrollReportCsv(
                  reportType: _reportType,
                  state: state,
                );
                if (context.mounted) {
                  showAppToast(context, '$_reportType exported to CSV');
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: FilterDropdown<String>(
            hint: 'Report Type',
            value: _reportType,
            items: _reportTypes,
            labelBuilder: (v) => v,
            onChanged: (v) => setState(() => _reportType = v ?? _reportType),
          ),
        ),
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
              _StatMini(label: 'Total Payroll (This Month)', value: '₹${state.totalPayrollThisMonth.toStringAsFixed(0)}', color: AppColors.success),
              _StatMini(label: 'Total Deductions', value: '₹${state.payrollRecords.fold(0.0, (a, b) => a + b.deductions).toStringAsFixed(0)}', color: AppColors.danger),
              _StatMini(label: 'Pending Payments', value: '₹${state.pendingPayments.toStringAsFixed(0)}', color: AppColors.warning),
            ],
          );
        }),
        const SizedBox(height: 18),
        ChartCard(
          title: 'Payroll Trend (6 Months)',
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
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
                        if (idx < 0 || idx >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(labels[idx], style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (var i = 0; i < trends.length; i++) FlSpot(i.toDouble(), trends[i])],
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 2.6,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: AppColors.successLight),
                  ),
                ],
              ),
            ),
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
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
