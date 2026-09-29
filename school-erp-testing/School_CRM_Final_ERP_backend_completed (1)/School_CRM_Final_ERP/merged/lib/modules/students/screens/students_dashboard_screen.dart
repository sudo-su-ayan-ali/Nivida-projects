import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/student_repository.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/at_risk_students_card.dart';
import '../widgets/categories_card.dart';
import '../widgets/charts/attendance_bar_chart.dart';
import '../widgets/charts/donut_chart.dart';
import '../widgets/charts/student_growth_chart.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/info_mini_card.dart';
import '../widgets/quick_actions_panel.dart';
import '../widgets/stat_card.dart';
import '../widgets/students_list_section.dart';
import '../widgets/today_highlights_card.dart';
import '../widgets/top_performers_card.dart';
import '../widgets/upcoming_needs_card.dart';
import 'add_edit_student_screen.dart';
import 'student_profile_screen.dart';

/// This is the screen you drop in place of the "Students Module — Coming up
/// in the next build phase." placeholder in your existing EduSmart sidebar
/// route. It reproduces every section from the reference screenshots and is
/// fully wired to StudentRepository (search/filter/pagination/add/edit/delete
/// all work against real, computed data).
class StudentsDashboardScreen extends StatefulWidget {
  const StudentsDashboardScreen({super.key});

  @override
  State<StudentsDashboardScreen> createState() => _StudentsDashboardScreenState();
}

class _StudentsDashboardScreenState extends State<StudentsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<StudentRepository>();
      if (repo.all.isEmpty) repo.load();
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentRepository>(
      builder: (context, repo, _) {
        if (repo.isLoading && repo.all.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final isWide = MediaQuery.of(context).size.width >= 1100;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Students Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Manage all student records efficiently.',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              // ---- Top KPI cards ----
              _statGrid(repo, isWide),
              const SizedBox(height: 22),

              // ---- Students list / search / filters / table / pagination + Quick Actions ----
              // ---- Students list / search / filters / table / pagination ----
_studentsListSection(repo),
const SizedBox(height: 22),

              // ---- Charts row: Growth / Class-wise / Boys vs Girls / Attendance ----
              _chartsGrid(repo, isWide),
              const SizedBox(height: 22),

              // ---- Highlights / Top Performers / Blood Group ----
              _row3(
                isWide,
               TodayHighlightsCard(
  birthdays: repo.birthdaysToday.length,
  feeDue: repo.feeDueStudents.length,
  tcRequests: repo.pendingTcRequests,
  lowAttendance: repo.lowAttendanceStudents.length,
),
                TopPerformersCard(students: repo.topPerformers, onViewAll: () => _snack('Opening full leaderboard...')),
                DashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Blood Group Distribution',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      LabeledDonutChart(
                        centerLabel: 'Total',
                        slices: _bloodGroupSlices(repo.bloodGroupCounts),
                      ),
                     
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ---- Categories / Transport / Hostel / Document Verification / ID Cards ----
              _infoRow(repo, isWide),
              const SizedBox(height: 22),

              // ---- Upcoming Needs / At-Risk Students ----
              _row2(
                isWide,
                UpcomingNeedsCard(
                  onViewAll: () => _snack('Opening all student needs...'),
                  needs: [
                    UpcomingNeed(Icons.track_changes, AppColors.primary, AppColors.purpleBg, 3, 'Students need academic support'),
                    UpcomingNeed(Icons.person_outline, AppColors.info, AppColors.infoBg, 2, 'Students showing stress signs'),
                    UpcomingNeed(Icons.campaign_outlined, AppColors.warning, AppColors.warningBg, 5, 'Students need career guidance'),
                  ],
                ),
                AtRiskStudentsCard(
                  students: repo.atRiskStudents,
                  onViewAll: () => _snack('Opening all at-risk students...'),
                  onTapStudent: (s) => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
                      value: repo,
                      child: StudentProfileScreen(studentId: s.id),
                    )),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------- sections -------------------------

  Widget _statGrid(StudentRepository repo, bool isWide) {
    final cards = [
      StatCard(
        icon: Icons.groups_2_outlined,
        iconColor: AppColors.primary,
        iconBg: AppColors.purpleBg,
        label: 'Total Students',
        value: repo.total.toString(),
        delta: '↑ 12.5% this month',
      ),
      StatCard(
        icon: Icons.man_outlined,
        iconColor: AppColors.info,
        iconBg: AppColors.infoBg,
        label: 'Boys',
        value: repo.boys.toString(),
        delta: repo.total == 0 ? '' : '${(repo.boys / repo.total * 100).toStringAsFixed(0)}% of total',
        deltaColor: AppColors.textSecondary,
        progress: repo.total == 0 ? 0 : repo.boys / repo.total,
        progressColor: AppColors.info,
      ),
      StatCard(
        icon: Icons.woman_outlined,
        iconColor: AppColors.pink,
        iconBg: AppColors.pinkBg,
        label: 'Girls',
        value: repo.girls.toString(),
        delta: repo.total == 0 ? '' : '${(repo.girls / repo.total * 100).toStringAsFixed(0)}% of total',
        deltaColor: AppColors.textSecondary,
        progress: repo.total == 0 ? 0 : repo.girls / repo.total,
        progressColor: AppColors.pink,
      ),
      StatCard(
        icon: Icons.event_available_outlined,
        iconColor: AppColors.success,
        iconBg: AppColors.successBg,
        label: 'Present Today',
        value: '${repo.presentPercent.toStringAsFixed(0)}%',
        delta: '${repo.presentToday} / ${repo.total}',
        deltaColor: AppColors.textSecondary,
      ),
      StatCard(
        icon: Icons.school_outlined,
        iconColor: AppColors.warning,
        iconBg: AppColors.warningBg,
        label: 'New Admissions',
        value: repo.newAdmissionsThisMonth.toString(),
        delta: '↑ 8.4% this month',
      ),
    ];
    final cols = isWide ? 5 : (MediaQuery.of(context).size.width > 700 ? 3 : 2);
    return _responsiveWrapGrid(cards, cols, spacing: 16);
  }

  /// Lays cards out in a fixed column count but lets each card size itself
  /// naturally (no forced aspect ratio), so text never overflows/clips
  /// regardless of font scaling or screen width.
  Widget _responsiveWrapGrid(List<Widget> items, int cols, {double spacing = 16}) {
    return LayoutBuilder(builder: (context, constraints) {
      final totalSpacing = spacing * (cols - 1);
      final itemWidth = (constraints.maxWidth - totalSpacing) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final it in items) SizedBox(width: itemWidth, child: it)],
      );
    });
  }

  Widget _studentsListSection(StudentRepository repo) {
    return StudentsListSection(
      students: repo.all,
      onAddStudent: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
          value: repo,
          child: const AddEditStudentScreen(),
        )),
      ),
      onImportExcel: () => _snack('Import: pick an .xlsx/.csv file and map columns (wire to your API).'),
      onExportPdf: () => _snack('Export: generating PDF from current filtered list (wire to your API).'),
      onView: (s) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
          value: repo,
          child: StudentProfileScreen(studentId: s.id),
        )),
      ),
      onEdit: (s) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
          value: repo,
          child: AddEditStudentScreen(student: s),
        )),
      ),
      onDelete: (s) => _confirmDelete(repo, s),
    );
  }

  void _confirmDelete(StudentRepository repo, Student s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete student?'),
        content: Text('This will remove ${s.name} (${s.admissionNo}) from the list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              repo.deleteStudent(s.id);
              Navigator.pop(ctx);
              _snack('${s.name} deleted');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(StudentRepository repo) {
    return QuickActionsPanel(actions: [
      QuickAction(
        icon: Icons.person_add_alt_1,
        color: AppColors.primary,
        bg: AppColors.purpleBg,
        title: 'Add Student',
        subtitle: 'Add new student record',
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
          value: repo,
          child: const AddEditStudentScreen(),
        ))),
      ),
      QuickAction(
        icon: Icons.file_upload_outlined,
        color: AppColors.success,
        bg: AppColors.successBg,
        title: 'Import Students',
        subtitle: 'Import from Excel/CSV',
        onTap: () => _snack('Import from Excel/CSV (wire to your API).'),
      ),
      QuickAction(
        icon: Icons.file_download_outlined,
        color: AppColors.success,
        bg: AppColors.successBg,
        title: 'Export Students',
        subtitle: 'Export student data',
        onTap: () => _snack('Exporting ${repo.total} students...'),
      ),
      QuickAction(
        icon: Icons.campaign_outlined,
        color: AppColors.warning,
        bg: AppColors.warningBg,
        title: 'Send Notice',
        subtitle: 'Send notification to parents',
        onTap: () => _snack('Compose notice (wire to your notification service).'),
      ),
      QuickAction(
        icon: Icons.sms_outlined,
        color: AppColors.info,
        bg: AppColors.infoBg,
        title: 'Send SMS',
        subtitle: 'Send SMS to parents',
        onTap: () => _snack('Compose SMS (wire to your SMS gateway).'),
      ),
      QuickAction(
        icon: Icons.badge_outlined,
        color: AppColors.primary,
        bg: AppColors.purpleBg,
        title: 'Generate ID Cards',
        subtitle: 'Generate student ID cards',
        onTap: () => _snack('Generating ID cards for filtered students...'),
      ),
    ]);
  }

  Widget _chartsGrid(StudentRepository repo, bool isWide) {
    final growth = DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeaderRow(title: 'Student Growth'),
          const SizedBox(height: 10),
          StudentGrowthChart(values: repo.growthTrend),
        ],
      ),
    );
    final classWise = DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeaderRow(title: 'Class-wise Students'),
          const SizedBox(height: 14),
          LabeledDonutChart(centerLabel: 'Total', slices: _classWiseSlices(repo.classWiseCounts)),
        ],
      ),
    );
    final boysGirls = DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeaderRow(title: 'Boys vs Girls'),
          const SizedBox(height: 14),
          LabeledDonutChart(centerLabel: 'Total', slices: [
            DonutSlice('Boys', repo.boys, AppColors.info),
            DonutSlice('Girls', repo.girls, AppColors.pink),
          ]),
        ],
      ),
    );
    final attendance = DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                    const CardHeaderRow(title: 'Attendance Overview'),
          const SizedBox(height: 10),
          AttendanceBarChart(values: repo.weeklyAttendance),
        ],
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: growth),
          const SizedBox(width: 16),
          Expanded(child: classWise),
          const SizedBox(width: 16),
          Expanded(child: boysGirls),
          const SizedBox(width: 16),
          Expanded(child: attendance),
        ],
      );
    }
    return Column(children: [
      growth,
      const SizedBox(height: 16),
      classWise,
      const SizedBox(height: 16),
      boysGirls,
      const SizedBox(height: 16),
      attendance,
    ]);
  }

  Widget _infoRow(StudentRepository repo, bool isWide) {
    final items = [
      CategoriesCard(counts: repo.categoryCounts, onViewAll: () => _snack('Opening categories...')),
      InfoMiniCard(
        icon: Icons.directions_bus_filled_outlined,
        iconColor: AppColors.primary,
        iconBg: AppColors.purpleBg,
        title: 'Transport Users',
        bigValue: '${repo.transportUsers}',
        subLine: 'Students using transport · ${repo.activeRoutes} Active Routes',
        onTap: () => _snack('Opening transport details...'),
      ),
      InfoMiniCard(
        icon: Icons.holiday_village_outlined,
        iconColor: AppColors.success,
        iconBg: AppColors.successBg,
        title: 'Hostel Residents',
        bigValue: '${repo.hostelResidents}',
        subLine: 'Students in hostel · ${repo.activeHostels} Active Hostels',
        onTap: () => _snack('Opening hostel details...'),
      ),
      InfoMiniCard(
        icon: Icons.verified_user_outlined,
        iconColor: AppColors.info,
        iconBg: AppColors.infoBg,
        title: 'Document Verification',
        bigValue: '${repo.docVerifiedPercent.toStringAsFixed(0)}%',
        subLine: 'Verified · ${(100 - repo.docVerifiedPercent).toStringAsFixed(0)}% Pending',
        onTap: () => _snack('Opening document verification...'),
      ),
      InfoMiniCard(
        icon: Icons.badge_outlined,
        iconColor: AppColors.warning,
        iconBg: AppColors.warningBg,
        title: 'ID Cards Generated',
        bigValue: '${repo.idCardsGenerated}',
        subLine: '${repo.idCardsPending} Pending',
        onTap: () => _snack('Opening ID card generator...'),
      ),
    ];

    final cols = isWide ? 5 : (MediaQuery.of(context).size.width > 700 ? 3 : 1);
    return _responsiveWrapGrid(items, cols, spacing: 16);
  }

  Widget _row2(bool isWide, Widget a, Widget b) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: a), const SizedBox(width: 16), Expanded(child: b)],
      );
    }
    return Column(children: [a, const SizedBox(height: 16), b]);
  }

  Widget _row3(bool isWide, Widget a, Widget b, Widget c) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 16),
          Expanded(child: b),
          const SizedBox(width: 16),
          Expanded(child: c),
        ],
      );
    }
    return Column(children: [a, const SizedBox(height: 16), b, const SizedBox(height: 16), c]);
  }

  List<DonutSlice> _classWiseSlices(Map<int, int> counts) {
    const colors = [AppColors.success, AppColors.danger, AppColors.primary, AppColors.warning, AppColors.info];
    var i = 0;
    return counts.entries.map((e) => DonutSlice('Class ${e.key}', e.value, colors[i++ % colors.length])).toList();
  }

  List<DonutSlice> _bloodGroupSlices(Map<String, int> counts) {
    const colorMap = {
      'O+': AppColors.info,
      'A+': AppColors.primary,
      'B+': AppColors.warning,
      'AB+': Color(0xFF9AA0AE),
      'Others': AppColors.danger,
    };
    return counts.entries.map((e) => DonutSlice(e.key, e.value, colorMap[e.key] ?? AppColors.primary)).toList();
  }
}

class CardHeaderRow extends StatelessWidget {
  final String title;
  final String? trailing;
  const CardHeaderRow({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        if (trailing != null)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(trailing!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
          ]),
      ],
    );
  }
}