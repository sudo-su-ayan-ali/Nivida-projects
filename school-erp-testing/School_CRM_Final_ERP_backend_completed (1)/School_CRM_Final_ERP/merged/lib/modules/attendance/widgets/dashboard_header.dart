import 'package:flutter/material.dart';
import '../core/theme.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onMarkAttendance;
  final VoidCallback onImport;
  final VoidCallback onExport;

  const DashboardHeader({
    super.key,
    required this.onMarkAttendance,
    required this.onImport,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 760;

      final titleBlock = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Attendance Dashboard', style: AppText.pageTitle),
          SizedBox(height: 6),
          Text(
            'Manage daily attendance, monitor records, track trends, and generate attendance reports.',
            style: AppText.pageSubtitle,
          ),
        ],
      );

      final actions = Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onMarkAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Mark Attendance', style: AppText.button),
          ),
        
        ],
      );

      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [titleBlock, const SizedBox(height: 16), actions],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 16),
          actions,
        ],
      );
    });
  }
}
