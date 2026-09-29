import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/constants/app_spacing.dart";
import "../../../models/alert_item.dart";
import "../../../shared/widgets/app_card.dart";

class AlertsCard extends StatelessWidget {
  final List<AlertItem> alerts;
  const AlertsCard({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
                    const SectionHeader(title: "Today's Alerts"),
          const SizedBox(height: 12),
          ...alerts.map((a) => _AlertTile(alert: a)),
        ],
      ),
    );
  }
}

class _AlertTile extends StatefulWidget {
  final AlertItem alert;
  const _AlertTile({required this.alert});
  @override
  State<_AlertTile> createState() => _AlertTileState();
}

class _AlertTileState extends State<_AlertTile> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.alert;
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: hovering ? a.color.withOpacity(0.08) : a.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: a.color.withOpacity(0.16), shape: BoxShape.circle),
                child: Icon(a.icon, size: 18, color: a.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: a.color)),
                    const SizedBox(height: 2),
                    Text(a.description, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(a.time, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
