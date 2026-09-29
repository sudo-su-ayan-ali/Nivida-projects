import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final double? changePercent;
  final bool isPositive;
  final VoidCallback? onViewAll;

  const StatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.changePercent,
    this.isPositive = true,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (changePercent != null) ...[
                Icon(isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 14, color: isPositive ? AppColors.success : AppColors.danger),
                const SizedBox(width: 2),
                Text('${changePercent!.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isPositive ? AppColors.success : AppColors.danger)),
                const Spacer(),
              ] else
                const Spacer(),
              if (onViewAll != null)
                InkWell(
                  onTap: onViewAll,
                  child: const Text('View All',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
