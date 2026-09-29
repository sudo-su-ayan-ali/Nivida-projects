import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/responsive_grid.dart';
import '../widgets/nav_menu_card.dart';
import 'nav_indices.dart';

/// Department-scoped overview for an HOD — narrower than the Principal's
/// whole-school view, wider than a single teacher's own classes.
class HodDashboardScreen extends StatelessWidget {
  const HodDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final allClasses = app.classNames;
    // Demo scoping: an HOD oversees a subset of classes within their
    // department rather than the whole school.
    final deptClasses = allClasses.length > 2 ? allClasses.sublist(0, (allClasses.length / 2).ceil()) : allClasses;
    final deptAverage = deptClasses.isEmpty
        ? 0.0
        : deptClasses.fold<double>(0, (a, c) => a + app.gradebookClassAverage(c)) / deptClasses.length;
    final deptStudents = app.students.where((s) => deptClasses.contains(s.className)).length;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(app.department, style: AppTextStyles.greetingTitle),
            const SizedBox(height: 4),
            Text('Department overview • ${deptClasses.length} classes under your charge', style: AppTextStyles.greetingSubtitle),
            const SizedBox(height: 18),
            ResponsiveGrid(
              minItemWidth: 210,
              maxColumns: 4,
              children: [
                _kpiTile(icon: Icons.groups_outlined, color: AppColors.purple, bg: AppColors.purpleBg, value: '$deptStudents', label: 'Dept. Students'),
                _kpiTile(icon: Icons.class_outlined, color: AppColors.blue, bg: AppColors.blueBg, value: '${deptClasses.length}', label: 'Classes Overseen'),
                _kpiTile(icon: Icons.grade_outlined, color: AppColors.green, bg: AppColors.greenBg, value: '${deptAverage.toStringAsFixed(0)}%', label: 'Dept. Avg Score'),
                _kpiTile(icon: Icons.beach_access_outlined, color: AppColors.orange, bg: AppColors.orangeBg, value: '${app.pendingApprovals.length}', label: 'Leave Approvals'),
              ],
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Classes in this Department', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 14),
                  if (deptClasses.isEmpty)
                    Text('No classes assigned yet.', style: AppTextStyles.itemSub)
                  else
                    for (final c in deptClasses) _classRow(app, c),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ResponsiveGrid(
              minItemWidth: 300,
              maxColumns: 3,
              children: [
                _actionCard(
                  context,
                  icon: Icons.beach_access_outlined,
                  color: AppColors.orange,
                  bg: AppColors.orangeBg,
                  title: 'Leave Approvals',
                  value: '${app.pendingApprovals.length} pending in queue',
                  onTap: () => app.setNavIndex(kLeavePayrollNavIndex),
                ),
                _actionCard(
                  context,
                  icon: Icons.folder_shared_outlined,
                  color: AppColors.teal,
                  bg: AppColors.tealBg,
                  title: 'Document Vault',
                  value: '${app.pendingDocumentsCount} awaiting verification',
                  onTap: () => app.setNavIndex(kDocumentVaultNavIndex),
                ),
                _actionCard(
                  context,
                  icon: Icons.insert_chart_outlined_rounded,
                  color: AppColors.blue,
                  bg: AppColors.blueBg,
                  title: 'Department Reports',
                  value: 'Attendance, fees & performance',
                  onTap: () => app.setNavIndex(kReportsNavIndex),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Sidebar has been removed from the app shell — every page it
            // used to link to (plus Logout) now lives here, at the very
            // bottom of the dashboard, as a widget of its own.
            NavMenuCard(isMobile: isMobile),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  Widget _classRow(AppState app, String className) {
    final avg = app.gradebookClassAverage(className);
    final count = app.students.where((s) => s.className == className).length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(className, style: AppTextStyles.itemTitle),
                Text('$count students', style: AppTextStyles.itemSub),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 90,
              child: LinearProgressIndicator(
                value: (avg / 100).clamp(0, 1),
                minHeight: 7,
                backgroundColor: AppColors.scaffoldBg,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 40, child: Text('${avg.toStringAsFixed(0)}%', textAlign: TextAlign.end, style: AppTextStyles.itemTitle.copyWith(fontSize: 12.5))),
        ],
      ),
    );
  }

  Widget _kpiTile({required IconData icon, required Color color, required Color bg, required String value, required String label}) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, bgColor: bg, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.statValue.copyWith(fontSize: 18)),
                Text(label, style: AppTextStyles.itemSub, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, {required IconData icon, required Color color, required Color bg, required String title, required String value, required VoidCallback onTap}) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, bgColor: bg, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.itemTitle),
                Text(value, style: AppTextStyles.itemSub, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}
