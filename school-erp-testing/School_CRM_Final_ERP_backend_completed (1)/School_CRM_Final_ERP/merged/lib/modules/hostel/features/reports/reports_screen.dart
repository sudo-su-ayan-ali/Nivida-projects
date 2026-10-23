import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String year = '2024-25';
  String block = 'All Blocks';

  static const _reports = [
    ('Student Report', Icons.groups_rounded, AppColors.primary, 'Demographics, admissions, and status breakdown.'),
    ('Room Occupancy Report', Icons.bed_rounded, AppColors.success, 'Block-wise occupancy and vacancy analysis.'),
    ('Attendance Report', Icons.fact_check_rounded, AppColors.info, 'Daily and monthly attendance trends.'),
    ('Leave Report', Icons.event_note_rounded, AppColors.warning, 'Leave frequency and approval statistics.'),
    ('Fee Collection Report', Icons.account_balance_wallet_rounded, AppColors.success, 'Collected vs pending fees by period.'),
    ('Pending Fees Report', Icons.hourglass_bottom_rounded, AppColors.danger, 'Students with outstanding dues.'),
    ('Mess Report', Icons.restaurant_rounded, AppColors.purple, 'Meal attendance and expense summary.'),
    ('Complaint Report', Icons.report_problem_rounded, AppColors.danger, 'Complaint volume by category and status.'),
    ('Maintenance Report', Icons.build_rounded, AppColors.info, 'Request turnaround and staff performance.'),
    ('Visitor Report', Icons.badge_rounded, AppColors.primary, 'Visitor logs and frequency by student.'),
    ('Staff Report', Icons.badge_outlined, AppColors.purple, 'Staff roles, attendance, and status.'),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context, max: 3);
    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBreadcrumb(items: const ['Reports']),
          const SizedBox(height: 10),
          const Text('Reports', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Generate and export detailed hostel operations reports.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterDropdown(label: 'Academic Year', value: year, options: const ['2024-25', '2023-24', '2025-26'], onChanged: (v) => setState(() => year = v!)),
                FilterDropdown(label: 'Block', value: block, options: const ['All Blocks', 'Block A', 'Block B', 'Block C', 'Block D'], onChanged: (v) => setState(() => block = v!)),
                SecondaryButton(label: 'Custom Date Range', icon: Icons.date_range_rounded, onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reports.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, i) {
              final r = _reports[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: (r.$3 as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Icon(r.$2 as IconData, color: r.$3 as Color, size: 20),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(r.$1 as String, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Expanded(child: Text(r.$4 as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    Row(children: [
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Exporting ${r.$1} as PDF...')),
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 15),
                        label: const Text('PDF', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Exporting ${r.$1} as CSV...')),
                          );
                        },
                        icon: const Icon(Icons.table_chart_rounded, size: 15),
                        label: const Text('CSV', style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}
