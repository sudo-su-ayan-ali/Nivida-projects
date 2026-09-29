import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/responsive_grid.dart';
import '../widgets/nav_menu_card.dart';
import 'nav_indices.dart';

/// Whole-school overview for Principal / Admin — the "important missing
/// piece" the school couldn't deploy without: a bird's-eye view across
/// every class, not just one teacher's own.
class PrincipalDashboardScreen extends StatelessWidget {
  const PrincipalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final classAverages = app.classPerformanceBreakdown();
    final classNames = classAverages.keys.toList();

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${app.currentRole.label} Overview', style: AppTextStyles.greetingTitle),
            const SizedBox(height: 4),
            Text('Whole-school snapshot across every class & department', style: AppTextStyles.greetingSubtitle),
            const SizedBox(height: 18),
            ResponsiveGrid(
              minItemWidth: 210,
              maxColumns: 5,
              children: [
                _kpiTile(icon: Icons.groups_outlined, color: AppColors.purple, bg: AppColors.purpleBg, value: '${app.students.length}', label: 'Total Students'),
                _kpiTile(icon: Icons.badge_outlined, color: AppColors.blue, bg: AppColors.blueBg, value: '${app.totalStaff}', label: 'Total Staff'),
                _kpiTile(icon: Icons.how_to_reg_outlined, color: AppColors.green, bg: AppColors.greenBg, value: '${app.schoolAttendancePercent.toStringAsFixed(0)}%', label: 'Attendance Today'),
                _kpiTile(icon: Icons.receipt_long_outlined, color: AppColors.orange, bg: AppColors.orangeBg, value: '${app.feeCollectionPercent.toStringAsFixed(0)}%', label: 'Fee Collection'),
                _kpiTile(icon: Icons.grade_outlined, color: AppColors.pink, bg: AppColors.pinkBg, value: '${app.schoolAverageExamPerformance.toStringAsFixed(0)}%', label: 'Avg Exam Score'),
              ],
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Class-Wise Exam Performance', style: AppTextStyles.sectionTitle),
                      InkWell(
                        onTap: () => app.setNavIndex(kReportsNavIndex),
                        child: Text('Open Reports →', style: AppTextStyles.viewAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 220,
                    child: classNames.isEmpty
                        ? Center(child: Text('No class data yet.', style: AppTextStyles.itemSub))
                        : BarChart(
                            BarChartData(
                              maxY: 100,
                              alignment: BarChartAlignment.spaceAround,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 25,
                                getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 1),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 36,
                                    interval: 25,
                                    getTitlesWidget: (v, meta) => Text('${v.toInt()}%', style: AppTextStyles.caption),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (v, meta) {
                                      final idx = v.toInt();
                                      if (idx < 0 || idx >= classNames.length) return const SizedBox();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(classNames[idx], style: AppTextStyles.caption),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => AppColors.textPrimary,
                                  getTooltipItem: (group, groupIdx, rod, rodIdx) => BarTooltipItem(
                                    '${rod.toY.toStringAsFixed(0)}%',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (int i = 0; i < classNames.length; i++)
                                  BarChartGroupData(x: i, barRods: [
                                    BarChartRodData(
                                      toY: classAverages[classNames[i]] ?? 0,
                                      color: AppColors.primary,
                                      width: 22,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ]),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ResponsiveGrid(
              minItemWidth: 280,
              maxColumns: 4,
              children: [
                _actionCard(
                  context,
                  icon: Icons.beach_access_outlined,
                  color: AppColors.orange,
                  bg: AppColors.orangeBg,
                  title: 'Leave Approvals',
                  value: '${app.pendingApprovals.length} pending',
                  onTap: () => app.setNavIndex(kLeavePayrollNavIndex),
                ),
                _actionCard(
                  context,
                  icon: Icons.folder_shared_outlined,
                  color: AppColors.teal,
                  bg: AppColors.tealBg,
                  title: 'Document Vault',
                  value: '${app.pendingDocumentsCount} to verify • ${app.missingDocumentsCount} missing',
                  onTap: () => app.setNavIndex(kDocumentVaultNavIndex),
                ),
                _actionCard(
                  context,
                  icon: Icons.insert_chart_outlined_rounded,
                  color: AppColors.blue,
                  bg: AppColors.blueBg,
                  title: 'Class-Wide Reports',
                  value: 'Build a class report or a per-student PTM report',
                  onTap: () => app.setNavIndex(kReportsNavIndex),
                ),
                _actionCard(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  color: AppColors.purple,
                  bg: AppColors.purpleBg,
                  title: 'Access Control',
                  value: '${app.pendingAccessRequests.length} pending request${app.pendingAccessRequests.length == 1 ? '' : 's'}',
                  onTap: () => app.setNavIndex(kAccessControlNavIndex),
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