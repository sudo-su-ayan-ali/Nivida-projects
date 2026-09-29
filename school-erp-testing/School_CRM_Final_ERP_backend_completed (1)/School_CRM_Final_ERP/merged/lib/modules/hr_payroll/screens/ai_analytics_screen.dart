import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AiAnalyticsScreen extends StatelessWidget {
  const AiAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final insights = <_Insight>[
      _Insight(
        icon: Icons.trending_up,
        color: AppColors.success,
        title: 'Attendance Trend',
        text:
            'Attendance has improved by 3.4% compared with last month, with ${state.staffBreakdown['Teaching Staff']} teaching staff maintaining the highest consistency.',
      ),
      _Insight(
        icon: Icons.groups_outlined,
        color: AppColors.primary,
        title: 'Workforce Distribution',
        text:
'Teaching department has the highest headcount at ${state.topDepartmentsByHeadcount.values.isEmpty ? 0 : state.topDepartmentsByHeadcount.values.first} employees, representing the largest share of the workforce.',
      ),
      _Insight(
        icon: Icons.beach_access_outlined,
        color: AppColors.warning,
        title: 'Leave Trends',
        text: 'Leave requests increased by 8% this month, driven mostly by Casual and Medical Leave categories.',
      ),
      _Insight(
        icon: Icons.person_remove_outlined,
        color: AppColors.danger,
        title: 'Turnover Prediction',
        text:
            'Based on attendance and engagement patterns, predicted turnover risk remains low (under 4%) for the current quarter.',
      ),
      _Insight(
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.purple,
        title: 'Payroll Insights',
        text:
            'Payroll costs have grown steadily over the last 6 months, tracking in line with headcount growth and scheduled increments.',
      ),
      _Insight(
        icon: Icons.emoji_events_outlined,
        color: AppColors.teal,
        title: 'Department Performance',
        text: 'Departments with structured shift schedules show 12% better punctuality on average.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'AI Analytics',
          subtitle: 'Workforce insights and predictive analytics',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.purpleLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.purple.withOpacity(0.25)),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, size: 16, color: AppColors.purple),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'These insights are demo analytics generated from mock data for illustration purposes, not a live AI/ML backend.',
                  style: TextStyle(fontSize: 12, color: AppColors.purple, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 1000 ? 3 : (c.maxWidth > 600 ? 2 : 1);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: insights.map((i) => _InsightCard(insight: i)).toList(),
          );
        }),
        const SizedBox(height: 20),
        ChartCard(
          title: 'Attendance vs Leave Correlation (Mock Trend)',
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 88), FlSpot(1, 90), FlSpot(2, 86), FlSpot(3, 92), FlSpot(4, 91), FlSpot(5, 94)],
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 8), FlSpot(1, 6), FlSpot(2, 11), FlSpot(3, 7), FlSpot(4, 9), FlSpot(5, 5)],
                    isCurved: true,
                    color: AppColors.warning,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
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

class _Insight {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  _Insight({required this.icon, required this.color, required this.title, required this.text});
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: insight.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(insight.icon, color: insight.color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(insight.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 6),
          Expanded(
            child: Text(insight.text,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
