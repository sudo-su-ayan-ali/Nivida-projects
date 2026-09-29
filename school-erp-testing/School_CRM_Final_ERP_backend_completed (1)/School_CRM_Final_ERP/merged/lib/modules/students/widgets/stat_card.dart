import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Top KPI card: icon + label + big number + delta line.
/// Matches "Total Students / Boys / Girls / Present Today / New Admissions".
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String? delta;
  final Color? deltaColor;
  final double? progress; // 0..1, optional bottom bar (Boys/Girls cards)
  final Color? progressColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.delta,
    this.deltaColor,
    this.progress,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Text(delta!, style: TextStyle(color: deltaColor ?? AppColors.success, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.border,
                color: progressColor ?? AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
