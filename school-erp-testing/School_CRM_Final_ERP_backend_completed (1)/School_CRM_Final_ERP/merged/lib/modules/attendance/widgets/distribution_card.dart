import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';

class DistributionSlice {
  final String label;
  final int count;
  final Color color;
  const DistributionSlice(this.label, this.count, this.color);
}

class DistributionCard extends StatefulWidget {
  final List<DistributionSlice> slices;
  final int totalStudents;
  final int centerPercent;

  const DistributionCard({
    super.key,
    required this.slices,
    required this.totalStudents,
    required this.centerPercent,
  });

  @override
  State<DistributionCard> createState() => _DistributionCardState();
}

class _DistributionCardState extends State<DistributionCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  int? _touchedIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.slices.fold<int>(0, (sum, s) => sum + s.count);

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance Distribution', style: AppText.sectionTitle),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeOutCubic.transform(_controller.value);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 58,
                        startDegreeOffset: -90,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              _touchedIndex = response?.touchedSection?.touchedSectionIndex;
                            });
                          },
                        ),
                                               sections: total == 0
                            ? [
                                PieChartSectionData(
                                  value: 1,
                                  color: AppColors.border,
                                  radius: 28,
                                  showTitle: false,
                                ),
                              ]
                            : [
                                for (int i = 0; i < widget.slices.length; i++)
                                  PieChartSectionData(
                                    value: widget.slices[i].count * t,
                                    color: widget.slices[i].color,
                                    radius: _touchedIndex == i ? 34 : 28,
                                    showTitle: false,
                                  ),
                              ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(widget.centerPercent * t).round()}%',
                            style: AppText.pageTitle.copyWith(fontSize: 26)),
                        const SizedBox(height: 2),
                        const Text('Total Attendance', style: AppText.cardLabel),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          ...widget.slices.map((s) {
            final pct = total == 0 ? 0 : (s.count / total * 100).round();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s.label, style: AppText.tableCell)),
                  Text('${s.count} ($pct%)', style: AppText.tableCell.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }),
          const Divider(height: 26, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Students', style: AppText.cardLabel),
              Text('${widget.totalStudents}', style: AppText.sectionTitle),
            ],
          ),
        ],
      ),
    );
  }
}
