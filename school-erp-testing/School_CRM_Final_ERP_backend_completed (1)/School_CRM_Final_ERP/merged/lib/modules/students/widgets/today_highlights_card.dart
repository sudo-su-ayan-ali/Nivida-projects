import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_card.dart';

class _HighlightRow {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  const _HighlightRow(this.icon, this.iconColor, this.iconBg, this.title, this.subtitle);
}

/// "Today's Highlights" card: birthdays, fee due, TC requests, low attendance.
class TodayHighlightsCard extends StatelessWidget {
  final int birthdays;
  final int feeDue;
  final int tcRequests;
  final int lowAttendance;

  const TodayHighlightsCard({
    super.key,
    required this.birthdays,
    required this.feeDue,
    required this.tcRequests,
    required this.lowAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _HighlightRow(Icons.card_giftcard, AppColors.warning, AppColors.warningBg, 'Birthdays Today', '$birthdays Students'),
      _HighlightRow(Icons.currency_rupee, AppColors.danger, AppColors.dangerBg, 'Fee Due', '$feeDue Students'),
      _HighlightRow(Icons.description_outlined, AppColors.info, AppColors.infoBg, 'TC Requests', '$tcRequests Requests'),
      _HighlightRow(Icons.access_time, AppColors.pink, AppColors.pinkBg, 'Attendance < 75%', '$lowAttendance Students'),
    ];
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Highlights",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: r.iconBg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(r.icon, color: r.iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary)),
                      Text(r.subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
