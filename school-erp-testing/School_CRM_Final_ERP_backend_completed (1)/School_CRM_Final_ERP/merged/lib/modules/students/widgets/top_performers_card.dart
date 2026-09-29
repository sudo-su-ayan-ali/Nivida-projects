import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import 'dashboard_card.dart';

/// "Top Performers" ranked list with medal-style rank badges.
class TopPerformersCard extends StatelessWidget {
  final List<Student> students;
  final VoidCallback? onViewAll;
  const TopPerformersCard({super.key, required this.students, this.onViewAll});

  static const _rankColors = [AppColors.warning, Color(0xFFB0B4C1), Color(0xFFCD7F32)];

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         const Text('Top Performers',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          for (var i = 0; i < students.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: _rankColors[i % _rankColors.length],
                    child: Text('${i + 1}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.purpleBg,
                    child: Text(students[i].name.substring(0, 1),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(students[i].name,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('Class ${students[i].classNum}${students[i].section}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('${students[i].examAveragePercent.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
