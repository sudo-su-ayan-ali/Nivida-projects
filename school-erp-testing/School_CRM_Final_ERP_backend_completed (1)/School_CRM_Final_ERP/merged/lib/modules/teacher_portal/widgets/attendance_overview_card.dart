import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class AttendanceOverviewCard extends StatefulWidget {
  const AttendanceOverviewCard({super.key});

  @override
  State<AttendanceOverviewCard> createState() => _AttendanceOverviewCardState();
}

class _AttendanceOverviewCardState extends State<AttendanceOverviewCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  String _range = 'This Week';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(onTap: () => app.setNavIndex(1), child: Text('Attendance Overview', style: AppTextStyles.sectionTitle)),
              _rangeDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) => LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 25,
                        getTitlesWidget: (v, meta) => Text('${v.toInt()}%', style: AppTextStyles.caption),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= app.weeklyAttendanceLabels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(app.weeklyAttendanceLabels[idx], style: AppTextStyles.caption),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.textPrimary,
                      getTooltipItems: (spots) => spots
                          .map((s) => LineTooltipItem('${s.y.toInt()}%', const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)))
                          .toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(radius: 4, color: AppColors.primary, strokeColor: Colors.white, strokeWidth: 2),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primary.withOpacity(0.22), AppColors.primary.withOpacity(0.0)],
                        ),
                      ),
                      spots: List.generate(
                        app.weeklyAttendance.length,
                        (i) => FlSpot(i.toDouble(), app.weeklyAttendance[i] * _anim.value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  icon: Icons.how_to_reg_outlined,
                  color: AppColors.green,
                  bg: AppColors.greenBg,
                  value: '${app.presentCount}',
                  label: 'Present',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryTile(
                  icon: Icons.person_off_outlined,
                  color: AppColors.red,
                  bg: AppColors.redBg,
                  value: '${app.absentCount}',
                  label: 'Absent',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rangeDropdown() {
    return PopupMenuButton<String>(
      onSelected: (v) => setState(() {
        _range = v;
        _ctrl.forward(from: 0);
      }),
      itemBuilder: (context) => const ['This Week', 'Last Week', 'This Month']
          .map((e) => PopupMenuItem(value: e, child: Text(e, style: AppTextStyles.itemSub)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_range, style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile({required IconData icon, required Color color, required Color bg, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.itemTitle.copyWith(fontSize: 15, color: color)),
              Text(label, style: AppTextStyles.itemSub),
            ],
          ),
        ],
      ),
    );
  }
}