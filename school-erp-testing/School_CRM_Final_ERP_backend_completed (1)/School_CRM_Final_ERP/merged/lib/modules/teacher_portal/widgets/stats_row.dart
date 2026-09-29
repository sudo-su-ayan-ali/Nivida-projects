import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class StatsRow extends StatelessWidget {
  final int columns;
  const StatsRow({super.key, required this.columns});

  void _onStatTap(BuildContext context, String label) {
    final app = context.read<AppState>();
    switch (label) {
      case 'My Classes':
        app.setNavIndex(6); // Timetable
        break;
      case 'Total Students':
        app.setNavIndex(2); // Students
        break;
      case "Today's Attendance":
        app.setNavIndex(1); // Attendance
        break;
      case 'Pending Assignments':
        app.setNavIndex(3); // Assignments
        break;
      case 'Upcoming Exams':
        app.setNavIndex(4); // Exams
        break;
      case "Today's Lessons":
        app.setNavIndex(6); // Timetable
        break;
      case 'Unread Messages':
        app.setNavIndex(5); // Messages
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<AppState>().stats;
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 14.0;
      final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: stats
            .map((s) => SizedBox(width: width, child: _StatCard(stat: s, onTap: () => _onStatTap(context, s.label))))
            .toList(),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final StatItem stat;
  final VoidCallback? onTap;
  const _StatCard({required this.stat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: stat.icon, color: stat.color, bgColor: stat.bgColor, size: 40),
            ],
          ),
          const SizedBox(height: 12),
          Text(stat.value, style: AppTextStyles.statValue),
          const SizedBox(height: 2),
          Text(stat.label, style: AppTextStyles.statLabel),
          const SizedBox(height: 2),
          Text(stat.sub, style: AppTextStyles.statSub),
        ],
      ),
    );
  }
}
