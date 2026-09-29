import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Common white rounded card wrapper used throughout the dashboard,
/// matching the reference screenshots' card style.
class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// "Section Title" + trailing dropdown/link, e.g. "Student Growth  [This Year v]"
class CardHeader extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  const CardHeader({super.key, required this.title, this.trailingText, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        if (trailingText != null)
          InkWell(
            onTap: onTrailingTap,
            child: Row(
              children: [
                Text(trailingText!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
      ],
    );
  }
}
