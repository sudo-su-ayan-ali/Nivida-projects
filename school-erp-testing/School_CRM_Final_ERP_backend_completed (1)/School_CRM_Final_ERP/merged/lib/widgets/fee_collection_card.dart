import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class FeeCollectionCard extends StatelessWidget {
  final double collected;
  final double pending;
  final double overdue;

  const FeeCollectionCard({
    super.key,
    required this.collected,
    required this.pending,
    required this.overdue,
  });
  
    @override
    Widget build(BuildContext context) {
      final total = collected + pending + overdue;
      final collectedPct = total > 0 ? (collected / total) * 100 : 0.0;
      final pendingPct = total > 0 ? (pending / total) * 100 : 0.0;
      final overduePct = total > 0 ? (overdue / total) * 100 : 0.0;

      String formatAmount(double value) {
        return '₹ ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
      }
    

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(
  title: 'Fee Collection Overview',
),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 3,
                    centerSpaceRadius: 58,
                    sections: [
                      PieChartSectionData(
                        value: collectedPct,
                        color: AppColors.success,
                        radius: 26,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: pendingPct,
                        color: AppColors.warning,
                        radius: 26,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: overduePct,
                        color: AppColors.danger,
                        radius: 26,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${collectedPct.toStringAsFixed(0)}%',
    style: AppText.h1.copyWith(fontSize: 26)),
                    Text('Collected', style: AppText.caption),
                  ],
                ),
                
              ],
              
            ),
          ),
          const SizedBox(height: 18),
         _LegendRow(
    color: AppColors.success,
    label: 'Collected',
    amount: '${formatAmount(collected)} (${collectedPct.toStringAsFixed(0)}%)'),
const SizedBox(height: 10),
_LegendRow(
    color: AppColors.warning,
    label: 'Pending',
    amount: '${formatAmount(pending)} (${pendingPct.toStringAsFixed(0)}%)'),
const SizedBox(height: 10),
_LegendRow(
    color: AppColors.danger,
    label: 'Overdue',
    amount: '${formatAmount(overdue)} (${overduePct.toStringAsFixed(0)}%)'),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;
  const _LegendRow({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppText.body)),
        Text(amount, style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
