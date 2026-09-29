import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/constants/app_spacing.dart";
import "../../../shared/widgets/app_card.dart";
import "../../../shared/widgets/status_badge.dart";

/// Extra #2: Live gate check-in/check-out feed — hostels run on knowing
/// exactly who is in/out of the building in real time, separate from
/// nightly attendance.
class CheckinCheckoutCard extends StatelessWidget {
  const CheckinCheckoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      ("Rohan Kumar", "B-205", "Out", "06:40 PM", "Evening walk"),
      ("Aarav Sharma", "A-103", "In", "07:05 PM", "Returned from class"),
      ("Vivek Patel", "C-302", "Out", "05:50 PM", "Sports ground"),
      ("Aditya Singh", "A-101", "In", "07:20 PM", "Returned from library"),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: "Live Gate Check-In / Check-Out"),
          const SizedBox(height: 8),
          ...entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    StatusBadge(status: e.$3 == "In" ? "Present" : "Late"),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${e.$1} · ${e.$2}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(e.$5, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(e.$4, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
