import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DonutSlice {
  final String label;
  final int value;
  final Color color;
  const DonutSlice(this.label, this.value, this.color);
}

/// Reusable donut chart with center total + right-side legend.
/// Used for: Class-wise Students, Boys vs Girls, Blood Group Distribution.
class LabeledDonutChart extends StatelessWidget {
  final List<DonutSlice> slices;
  final String centerLabel;
  final bool legendBelow;

  const LabeledDonutChart({
    super.key,
    required this.slices,
    required this.centerLabel,
    this.legendBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (a, b) => a + b.value);
    final chart = SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
                   PieChart(
            PieChartData(
              sections: slices.isEmpty
                  ? [
                      PieChartSectionData(
                        value: 1,
                        color: AppColors.border,
                        radius: 22,
                        showTitle: false,
                      ),
                    ]
                  : [
                      for (final s in slices)
                        PieChartSectionData(
                          value: s.value.toDouble(),
                          color: s.color,
                          radius: 22,
                          showTitle: false,
                        ),
                    ],
              centerSpaceRadius: 44,
              sectionsSpace: 2,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(total.toString(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text(centerLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );

    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Flexible(
  child: Text.rich(
    TextSpan(children: [
      TextSpan(text: '${s.label}  ', style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
      TextSpan(
        text: '${s.value} (${total == 0 ? 0 : (s.value / total * 100).toStringAsFixed(0)}%)',
        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
      ),
    ]),
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
),
              ],
            ),
          ),
      ],
    );

    if (legendBelow) {
      return Column(children: [chart, const SizedBox(height: 12), legend]);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [chart, Flexible(child: legend)],
    );
  }
}
