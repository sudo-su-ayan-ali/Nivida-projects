import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/constants/app_spacing.dart";
import "../../../shared/widgets/app_card.dart";
import "../../../shared/widgets/primary_button.dart";

/// Extra #3: Parent communication log — a dedicated audit trail of what
/// was communicated to parents/guardians (leave approvals, fee reminders,
/// incident notices) since this is a frequent compliance need for hostels.
class ParentCommunicationCard extends StatelessWidget {
  const ParentCommunicationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      ("Fee reminder sent", "156 guardians · SMS + Email", AppColors.info, Icons.mail_rounded),
      ("Leave approved notice", "Rohan Kumars guardian · SMS", AppColors.success, Icons.check_circle_rounded),
      ("Health advisory sent", "All guardians · Email", AppColors.warning, Icons.health_and_safety_rounded),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: "Parent / Guardian Communication"),
          const SizedBox(height: 10),
          ...logs.map((l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: l.$3.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Icon(l.$4, size: 16, color: l.$3),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(l.$2, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
         
        ],
      ),
    );
  }
}
