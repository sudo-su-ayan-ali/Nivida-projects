import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../routing/app_routes.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String path;
  final Permission? requires;
  const NavItem(this.label, this.icon, this.path, {this.requires});
}

const List<NavItem> kNavItems = [
  NavItem('Dashboard', Icons.dashboard_rounded, AppRoutes.dashboard),
  NavItem('Exam Management', Icons.event_note_rounded, AppRoutes.examManagement, requires: Permission.manageExams),
  NavItem('Exam Calendar', Icons.calendar_month_rounded, AppRoutes.calendar),
  NavItem('Student Eligibility', Icons.how_to_reg_rounded, AppRoutes.eligibility, requires: Permission.manageEligibility),
  NavItem('Question Paper Security', Icons.verified_user_rounded, AppRoutes.paperSecurity, requires: Permission.approveQuestionPapers),
  NavItem('Seating & Invigilators', Icons.event_seat_rounded, AppRoutes.seating, requires: Permission.manageSeating),
  NavItem('Exam Hall Management', Icons.meeting_room_rounded, AppRoutes.examHall, requires: Permission.manageAttendance),
  NavItem('Barcode Security Center', Icons.qr_code_2_rounded, AppRoutes.barcodeCenter, requires: Permission.generateAnonymousBooks),
  NavItem('Answer Book Custody', Icons.inventory_2_rounded, AppRoutes.answerBooks, requires: Permission.generateAnonymousBooks),
  NavItem('Anonymous Evaluation', Icons.visibility_off_rounded, AppRoutes.evaluation, requires: Permission.enterMarks),
  NavItem('Moderation & Marks Lock', Icons.lock_clock_rounded, AppRoutes.moderation, requires: Permission.moderateEvaluation),
  NavItem('Result Processing', Icons.fact_check_rounded, AppRoutes.results, requires: Permission.approveResults),
  NavItem('Grading Engine', Icons.grading_rounded, AppRoutes.gradingEngine, requires: Permission.approveResults),
  NavItem('Report Card Designer', Icons.design_services_rounded, AppRoutes.reportCardDesigner, requires: Permission.approveResults),
  NavItem('Revaluation / Rechecking', Icons.rate_review_rounded, AppRoutes.revaluation, requires: Permission.manageRevaluation),
  NavItem('Admit Cards', Icons.badge_rounded, AppRoutes.admitCards),
  NavItem('Certificates & Transcripts', Icons.workspace_premium_rounded, AppRoutes.certificates, requires: Permission.manageCertificates),
  NavItem('Exam Reschedule / Cancel', Icons.event_busy_rounded, AppRoutes.reschedule, requires: Permission.manageExams),
  NavItem('Substitute Invigilators', Icons.swap_horiz_rounded, AppRoutes.substituteInvigilator, requires: Permission.assignInvigilators),
  NavItem('Digital Exam Instructions', Icons.rule_rounded, AppRoutes.digitalInstructions, requires: Permission.manageNotifications),
  NavItem('Malpractice Management', Icons.report_problem_rounded, AppRoutes.malpractice, requires: Permission.manageMalpractice),
  NavItem('Special Accommodation', Icons.accessible_rounded, AppRoutes.accommodation, requires: Permission.manageAccommodation),
  NavItem('Analytics & Reports', Icons.insights_rounded, AppRoutes.analytics, requires: Permission.viewAnalytics),
  NavItem('Notifications', Icons.notifications_active_rounded, AppRoutes.notifications, requires: Permission.manageNotifications),
  NavItem('Student / Parent Portal', Icons.family_restroom_rounded, AppRoutes.portal),
  NavItem('Archive', Icons.archive_rounded, AppRoutes.archive, requires: Permission.manageArchive),
  NavItem('Backup & Data Security', Icons.backup_rounded, AppRoutes.backup, requires: Permission.manageBackup),
  NavItem('Roles & Permissions', Icons.admin_panel_settings_rounded, AppRoutes.roles, requires: Permission.manageRolesPermissions),
  NavItem('Audit Logs', Icons.history_rounded, AppRoutes.auditLogs, requires: Permission.viewAuditLogs),
];

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;
  const AppShell({super.key, required this.child, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: AppColors.bg, child: child),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != 'Examination Dashboard') ...[
            IconButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back to Dashboard',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          Wrap(spacing: 10, children: actions),
        ],
      ),
    );
  }
}

class StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Duration animationDelay;
  const StatCard({super.key, required this.label, required this.value, required this.icon, this.color = AppColors.primary, this.animationDelay = Duration.zero});

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovering = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.animationDelay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.15),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: _hovering ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
            width: 190,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _hovering ? widget.color.withOpacity(0.6) : AppColors.border, width: _hovering ? 1.4 : 1),
              boxShadow: _hovering
                  ? [BoxShadow(color: widget.color.withOpacity(0.22), blurRadius: 16, offset: const Offset(0, 8))]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: widget.color.withOpacity(_hovering ? 0.2 : 0.12), borderRadius: BorderRadius.circular(9)),
                  child: Icon(widget.icon, color: widget.color, size: 19),
                ),
                const SizedBox(height: 12),
                Text(widget.value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(widget.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const StatusBadge(this.text, {super.key, this.color = AppColors.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const SectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        padding: padding,
        child: child,
      );
}

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_rounded});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(36),
        child: Column(children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ]),
      );
}

Future<bool> confirmDialog(BuildContext context, {required String title, required String message}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(dialogCtx).pop(true), child: const Text('Confirm')),
      ],
    ),
  );
  return res ?? false;
}

void showAppSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: error ? AppColors.danger : AppColors.success,
    behavior: SnackBarBehavior.floating,
  ));
}
