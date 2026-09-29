import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "../../../core/theme/app_colors.dart";
import "../../../data/providers/app_providers.dart";
import "../../../shared/widgets/app_card.dart";
import "../../../shared/widgets/app_data_table.dart";
import "../../../shared/widgets/status_badge.dart";

class UpcomingLeavesCard extends ConsumerWidget {
  const UpcomingLeavesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaves = ref.watch(leavesProvider).take(5).toList();
    final df = DateFormat("d MMM");

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: "Upcoming Leaves", actionLabel: "View Calendar", onAction: () => context.go("/leaves")),
          const SizedBox(height: 12),
          AppDataTable(
            minWidth: 640,
            columns: const [
              AppTableColumn("Student Name", width: 160),
              AppTableColumn("Room No.", width: 90),
              AppTableColumn("Leave Type", width: 110),
              AppTableColumn("From - To", width: 130),
              AppTableColumn("Status", width: 100),
            ],
            rowCount: leaves.length,
            rowBuilder: (i) {
              final l = leaves[i];
              return [
                CellText(l.studentName, strong: true),
                CellText(l.room),
                CellText(l.leaveType),
                CellText("${df.format(l.from)} - ${df.format(l.to)}"),
                StatusBadge(status: l.status),
              ];
            },
          ),
        ],
      ),
    );
  }
}
