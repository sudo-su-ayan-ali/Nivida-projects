import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? trend;
  final bool trendUp;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(isDark ? 0.16 : 0.10), blurRadius: 26, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent.withOpacity(0.22), accent.withOpacity(0.08)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              if (trend != null)
                Row(
                  children: [
                    Icon(trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 14, color: trendUp ? const Color(0xFF2ED9A8) : const Color(0xFFFF5C7A)),
                    const SizedBox(width: 2),
                    Text(trend!,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: trendUp ? const Color(0xFF2ED9A8) : const Color(0xFFFF5C7A))),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: theme.textTheme.headlineSmall, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }
}
