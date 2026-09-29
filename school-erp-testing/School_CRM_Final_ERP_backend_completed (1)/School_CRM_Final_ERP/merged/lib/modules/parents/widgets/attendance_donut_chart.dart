import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';

class AttendanceDonutChart extends StatefulWidget {
  final AttendanceSummary summary;
  final double size;
  const AttendanceDonutChart({super.key, required this.summary, this.size = 180});

  @override
  State<AttendanceDonutChart> createState() => _AttendanceDonutChartState();
}

class _AttendanceDonutChartState extends State<AttendanceDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AttendanceDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary != widget.summary) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 3,
                  centerSpaceRadius: widget.size * 0.32,
                  sections: [
                    PieChartSectionData(
                      value: s.presentPercent * t + 0.001,
                      color: AppColors.success,
                      radius: widget.size * 0.18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: s.latePercent * t + 0.001,
                      color: AppColors.warning,
                      radius: widget.size * 0.18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: s.absentPercent * t + 0.001,
                      color: AppColors.danger,
                      radius: widget.size * 0.18,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(s.presentPercent * t).round()}%',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Average\nAttendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10.5, color: AppColors.muted, height: 1.2),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
