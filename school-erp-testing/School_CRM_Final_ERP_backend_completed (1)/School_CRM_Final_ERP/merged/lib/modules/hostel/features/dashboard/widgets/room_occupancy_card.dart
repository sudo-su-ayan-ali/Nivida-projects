import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';

class RoomOccupancyCard extends StatelessWidget {
  final int total;
  final int occupied;
  final int vacant;
  final int maintenance;
  final int reserved;

  const RoomOccupancyCard({
    super.key,
    required this.total,
    required this.occupied,
    required this.vacant,
    required this.maintenance,
    required this.reserved,
  });

  double _pct(int v) => total == 0 ? 0 : (v / total) * 100;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Room Occupancy Overview',
            actionLabel: 'View All Rooms',
            onAction: () => context.go('/hostel/rooms'),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final narrow = constraints.maxWidth < 380;
            final chart = SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 55,
                      sections: [
                        PieChartSectionData(value: occupied.toDouble(), color: AppColors.success, radius: 26, showTitle: false),
                        PieChartSectionData(value: vacant.toDouble(), color: AppColors.primary, radius: 26, showTitle: false),
                        PieChartSectionData(value: maintenance.toDouble(), color: AppColors.warning, radius: 26, showTitle: false),
                        if (reserved > 0)
                          PieChartSectionData(value: reserved.toDouble(), color: AppColors.danger, radius: 26, showTitle: false),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$total', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const Text('Total Rooms', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            );
            final legend = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _legendRow('Occupied', AppColors.success, occupied),
                const SizedBox(height: 14),
                _legendRow('Vacant', AppColors.primary, vacant),
                const SizedBox(height: 14),
                _legendRow('Maintenance', AppColors.warning, maintenance),
                const SizedBox(height: 14),
                _legendRow('Reserved', AppColors.danger, reserved),
              ],
            );

            if (narrow) {
              return Column(children: [Center(child: chart), const SizedBox(height: 20), legend]);
            }
            return Row(
              children: [
                chart,
                const SizedBox(width: 32),
                Expanded(child: legend),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _legendRow(String label, Color color, int value) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500))),
        Text('$value (${_pct(value).toStringAsFixed(2)}%)',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}
