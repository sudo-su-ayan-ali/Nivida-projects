import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/responsive/responsive.dart";

import "../../../shared/widgets/app_card.dart";
import "../../../shared/widgets/quick_action_button.dart";

/// The app's primary navigation surface — since there's no sidebar or top
/// bar on inner pages, every module in the app is reachable from here.
class QuickActionsCard extends ConsumerWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      (Icons.groups_rounded, AppColors.primary, "Students", "/students"),
      (Icons.person_add_alt_1_rounded, AppColors.primary, "Add Student", "/students/add"),
      (Icons.apartment_rounded, AppColors.purple, "Blocks", "/hostel/blocks"),
      (Icons.bed_rounded, AppColors.success, "Rooms", "/hostel/rooms"),
      (Icons.fact_check_rounded, AppColors.info, "Attendance", "/attendance"),
      (Icons.event_note_rounded, AppColors.warning, "Leave Requests", "/leaves"),
      (Icons.account_balance_wallet_rounded, AppColors.success, "Fees & Payments", "/fees"),
      (Icons.restaurant_rounded, AppColors.warning, "Mess & Food", "/mess"),
      (Icons.report_problem_rounded, AppColors.danger, "Complaints", "/complaints"),
      (Icons.build_rounded, AppColors.warning, "Maintenance", "/maintenance"),
      (Icons.badge_rounded, AppColors.purple, "Visitors", "/visitors"),
      (Icons.campaign_rounded, AppColors.danger, "Notices", "/notices"),
      (Icons.badge_outlined, AppColors.info, "Staff", "/staff"),
      (Icons.bar_chart_rounded, AppColors.primary, "Reports", "/reports"),
      (Icons.settings_rounded, AppColors.textSecondary, "Settings", "/settings"),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: "Quick Actions"),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.gridColumns(context, max: 8),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
         itemBuilder: (context, i) {
  final a = actions[i];
  return QuickActionButton(icon: a.$1, color: a.$2, label: a.$3, onTap: () => context.go(a.$4));
},
          ),
        ],
      ),
    );
  }
}
