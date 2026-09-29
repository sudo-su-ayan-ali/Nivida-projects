import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_record.dart';

class AnalyticsCard extends StatefulWidget {
  final AttendanceRepository repo;
  const AnalyticsCard({super.key, required this.repo});

  @override
  State<AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<AnalyticsCard> {
  TrendRange _range = TrendRange.month;
  late Future<List<AttendanceTrendPoint>> _pointsFuture;

  @override
  void initState() {
    super.initState();
    _pointsFuture = widget.repo.fetchTrend(_range);
  }

  void _onRangeChanged(TrendRange r) {
    setState(() {
      _range = r;
      _pointsFuture = widget.repo.fetchTrend(r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Attendance Analytics', style: AppText.sectionTitle)),
              _RangeTabs(
                value: _range,
                onChanged: _onRangeChanged,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: FutureBuilder<List<AttendanceTrendPoint>>(
              future: _pointsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final points = snapshot.data!;
                if (points.isEmpty) {
                  return const Center(
                    child: Text('No attendance data for this range yet.', style: AppText.cardLabel),
                  );
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _AreaChart(key: ValueKey(_range), points: points),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeTabs extends StatelessWidget {
  final TrendRange value;
  final ValueChanged<TrendRange> onChanged;
  const _RangeTabs({required this.value, required this.onChanged});

  static const _labels = {
    TrendRange.today: 'Today',
    TrendRange.week: 'Week',
    TrendRange.month: 'Month',
    TrendRange.year: 'Year',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TrendRange.values.map((r) {
          final selected = r == value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => onChanged(r),
              borderRadius: BorderRadius.circular(AppRadius.control - 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.control - 2),
                ),
                child: Text(
                  _labels[r]!,
                  style: AppText.button.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AreaChart extends StatelessWidget {
  final List<AttendanceTrendPoint> points;
  const _AreaChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 20,
              getTitlesWidget: (v, meta) => Text('${v.toInt()}%', style: AppText.tableCellMuted),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(points[i].label, style: AppText.tableCellMuted),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            tooltipRoundedRadius: 10,
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
              final i = s.x.toInt();
              final label = (i >= 0 && i < points.length) ? points[i].label : '';
              return LineTooltipItem(
                '$label\nAttendance: ${s.y.toInt()}%',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(radius: 3.5, color: AppColors.primary, strokeWidth: 2, strokeColor: Colors.white),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.30),
                  AppColors.primary.withOpacity(0.02),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }
}