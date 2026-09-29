import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_card.dart';

class UpcomingNeed {
  final IconData icon;
  final Color color;
  final Color bg;
  final int count;
  final String label;
  const UpcomingNeed(this.icon, this.color, this.bg, this.count, this.label);
}

/// "Upcoming Student Needs" — proactive support recommendations list.
class UpcomingNeedsCard extends StatelessWidget {
  final List<UpcomingNeed> needs;
  final VoidCallback? onViewAll;
  const UpcomingNeedsCard({super.key, required this.needs, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming Student Needs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Text('Proactive support recommendations',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          for (final n in needs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: n.bg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(n.icon, color: n.color, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('${n.count} ${n.label}',
                        style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary)),
                  ),
                  
                ],
              ),
            ),
          
        ],
      ),
    );
  }
}
