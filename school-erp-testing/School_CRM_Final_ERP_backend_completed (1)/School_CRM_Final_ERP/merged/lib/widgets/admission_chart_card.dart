import '../data/dashboard_repository.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class AdmissionChartCard extends StatelessWidget {
  final DashboardRepository repo;
  const AdmissionChartCard({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final months = repo.admissionMonths;
    final values = repo.admissionCounts;
    if (months.isEmpty || values.isEmpty) {
      return const GlassCard(
        child: SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxVal < 10 ? 10.0 : (maxVal * 1.2);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         const CardHeader(
    title: 'Students Admission'),
          const SizedBox(height: 6),
                  Text('${repo.totalAdmissionsThisSession}',
              style: AppText.h1.copyWith(fontSize: 26)),
          Text('New Admissions', style: AppText.caption),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                                minY: 0,
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (chartMaxY / 3).ceilToDouble(),
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.borderLight,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (chartMaxY / 3).ceilToDouble(),
                      getTitlesWidget: (v, meta) => Text('${v.toInt()}',
                          style: AppText.caption.copyWith(fontSize: 10)),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(months[i],
                              style:
                                  AppText.caption.copyWith(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primaryPurpleDark,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${months[s.x.toInt()]}\n${s.y.toInt()} Admissions',
                              const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < values.length; i++)
                        FlSpot(i.toDouble(), values[i]),
                    ],
                    isCurved: true,
                    color: AppColors.primaryPurple,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryPurple.withOpacity(0.28),
                          AppColors.primaryPurple.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
