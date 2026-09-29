import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/constants/app_spacing.dart";
import "../../../shared/widgets/app_card.dart";

/// Extra #4: Hostel calendar / events strip — inspections, fire drills,
/// cultural nights, exam-quiet-hours. Distinct from Notices (which are
/// announcements) — this is a forward-looking schedule.
class HostelEventsCard extends StatelessWidget {
  const HostelEventsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      ("28", "MAY", "Fire Safety Drill", "All Blocks · 5:00 PM"),
      ("31", "MAY", "Hostel Inspection", "Block A & B · 10:00 AM"),
      ("02", "JUN", "Cultural Night", "Common Hall · 7:00 PM"),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: "Upcoming Hostel Events"),
          const SizedBox(height: 10),
          ...events.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1)),
                          Text(e.$2, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.$3, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(e.$4, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
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
