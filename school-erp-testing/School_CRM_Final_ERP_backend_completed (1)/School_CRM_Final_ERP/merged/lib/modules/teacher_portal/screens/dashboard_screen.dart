import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/greeting_section.dart';
import '../widgets/stats_row.dart';
import '../widgets/today_schedule_card.dart';
import '../widgets/recent_assignments_card.dart';
import '../widgets/class_overview_card.dart';
import '../widgets/attendance_overview_card.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_card.dart';
import '../widgets/my_students_card.dart';
import '../widgets/communication_card.dart';
import '../widgets/exams_marks_card.dart';
import '../widgets/action_grid_card.dart';

import '../widgets/promo_cards.dart';
import '../widgets/common/responsive_grid.dart';
import '../widgets/dialogs/action_dialogs.dart';
import '../widgets/common/form_widgets.dart';

import '../widgets/homework_submission_card.dart';
import '../widgets/online_classes_card.dart';
import '../widgets/fee_status_card.dart';
import '../widgets/notice_board_card.dart';
import '../widgets/academic_calendar_card.dart';
import '../widgets/nav_menu_card.dart';
import 'nav_indices.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _handleQuickAction(BuildContext context, String id) {
    final app = context.read<AppState>();
    switch (id) {
      case 'take_attendance':
        app.setNavIndex(kAttendanceNavIndex);
        break;
      case 'create_assignment':
        showAddAssignmentDialog(context);
        break;
      case 'upload_material':
        showAddResourceDialog(
          context,
          title: 'Upload Study Material',
          fieldLabel: 'File / Material Name',
          fieldHint: 'e.g. Trigonometry Notes.pdf',
          secondFieldLabel: 'Class / Description',
          secondFieldHint: 'e.g. Class 10-A',
          onSubmit: (a, v1, v2) => a.addStudyMaterial(v1, v2.isEmpty ? 'Uploaded material' : v2),
        );
        break;
      case 'schedule_test':
        showAddExamDialog(context);
        break;
      case 'record_marks':
        app.setNavIndex(kGradebookNavIndex);
        break;
      case 'send_message':
        showComposeMessageDialog(context);
        break;
      case 'leave_request':
        showLeaveRequestDialog(context);
        break;
      case 'study_materials':
        _showResourceList(context, title: 'Study Materials', items: app.studyMaterials);
        break;
      case 'question_bank':
        _showResourceList(context, title: 'Question Bank', items: app.questionBank);
        break;
      case 'library':
        _showResourceList(context, title: 'Library', items: app.library);
        break;
      case 'grade_book':
        app.setNavIndex(kGradebookNavIndex);
        break;
      case 'syllabus':
        app.setNavIndex(kSyllabusNavIndex);
        break;
      case 'seating':
        app.setNavIndex(kSeatingNavIndex);
        break;
      case 'substitute':
        app.setNavIndex(kSubstituteNavIndex);
        break;
      case 'ptm':
        app.setNavIndex(kPtmNavIndex);
        break;
      case 'lesson_plan':
        showAddResourceDialog(
          context,
          title: 'Add Lesson Plan',
          fieldLabel: 'Lesson Title',
          fieldHint: 'e.g. Introduction to Probability',
          secondFieldLabel: 'Class',
          secondFieldHint: 'e.g. Class 10-A',
          onSubmit: (a, v1, v2) => a.addLessonPlan(v1, v2.isEmpty ? 'Class 10-A' : v2, 'TBD'),
        );
        break;
      case 'calendar':
        app.setNavIndex(kTimetableNavIndex);
        break;
      case 'settings':
        app.setNavIndex(kProfileNavIndex);
        break;
      case 'homework':
        app.setNavIndex(kHomeworkNavIndex);
        break;
      case 'online_class':
        app.setNavIndex(kOnlineClassNavIndex);
        break;
      case 'fees':
        app.setNavIndex(kFeesNavIndex);
        break;
      case 'notice_board':
        app.setNavIndex(kNoticeNavIndex);
        break;
      case 'academic_calendar':
        app.setNavIndex(kAcademicCalendarNavIndex);
        break;
    }
  }

  void _showResourceList(BuildContext context, {required String title, required List items}) {
    showAppFormDialog(
      context: context,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final r in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: r.bgColor, borderRadius: BorderRadius.circular(11)),
                    child: Icon(r.icon, size: 18, color: r.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        Text(r.subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (items.isEmpty) const Text('Nothing here yet.'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 720;
        final isTablet = width >= 720 && width < 1080;
        final statCols = isMobile ? 2 : (isTablet ? 3 : 4);
        final horizontalPad = isMobile ? 14.0 : (isTablet ? 20.0 : 28.0);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingSection(isMobile: isMobile),
              const SizedBox(height: 18),
              StatsRow(columns: statCols),
              const SizedBox(height: 18),

              // Adaptive grid: cards drop to the next row instead of
              // overflowing horizontally when space runs out.
             ResponsiveGrid(
  minItemWidth: 340,
  maxColumns: 4,
  equalizeRowHeight: true,
  children: const [
    TodayScheduleCard(),
    RecentAssignmentsCard(),
    ClassOverviewCard(),
    AttendanceOverviewCard(),
  ],
),
              const SizedBox(height: 18),

                          ResponsiveGrid(
                minItemWidth: 340,
                maxColumns: 4,
                equalizeRowHeight: true,
                children: const [
                  MyStudentsCard(),
                  CommunicationCard(),
                  ExamsMarksCard(),
                ],
              ),
              const SizedBox(height: 18),

                           AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActionGridCard(
                      title: 'Teaching Resources',
                      tiles: context.read<AppState>().teachingResources,
                      columns: isMobile ? 2 : 3,
                      onTileTap: (t) => _handleQuickAction(context, t.id),
                      wrapInCard: false,
                    ),
                    const SizedBox(height: 22),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 22),
                    ActionGridCard(
                      title: 'Quick Actions',
                      tiles: context.read<AppState>().quickActions,
                      columns: isMobile ? 3 : 4,
                      onTileTap: (t) => _handleQuickAction(context, t.id),
                      wrapInCard: false,
                    ),
                    const SizedBox(height: 22),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 22),
                    ActionGridCard(
                      title: 'Other Tools',
                      tiles: context.read<AppState>().otherTools,
                      columns: isMobile ? 2 : 4,
                      onTileTap: (t) => _handleQuickAction(context, t.id),
                      wrapInCard: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

             

                          // New teacher-requested modules: Homework Submission Tracking,
              // Online Classes, Fee Status, Notice Board, Academic Calendar.
              if (isMobile) ...[
                const HomeworkSubmissionCard(),
                const SizedBox(height: 18),
                const OnlineClassesCard(),
                const SizedBox(height: 18),
                const FeeStatusCard(),
                const SizedBox(height: 18),
                const NoticeBoardCard(),
                const SizedBox(height: 18),
                const AcademicCalendarCard(),
              ] else ...[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Expanded(child: HomeworkSubmissionCard()),
                      SizedBox(width: 18),
                      Expanded(child: OnlineClassesCard()),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Expanded(child: FeeStatusCard()),
                      SizedBox(width: 18),
                      Expanded(child: NoticeBoardCard()),
                      SizedBox(width: 18),
                      Expanded(child: AcademicCalendarCard()),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Sidebar has been removed from the app shell — every page it
              // used to link to (plus Logout) now lives here, at the very
              // bottom of the dashboard, as a widget of its own.
              NavMenuCard(isMobile: isMobile),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}